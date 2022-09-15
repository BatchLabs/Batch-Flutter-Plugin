import Flutter
import UIKit
import Batch

fileprivate struct Consts {
    static let BridgeVersionEnvironmentVar = "BATCH_BRIDGE_VERSION"
    static let BridgeVersion = "Bridge/1.2"
    
    static let PluginVersionEnvironmentVar = "BATCH_PLUGIN_VERSION"
    static let PluginVersion = "Flutter/1.3.0"
}

/// Batch's Flutter Plugin main class.
/// `BatchFlutterPlugin.setup()` needs be called in
///
/// See `configuration` and `manageBatchLifecycle` for more info on how to configure it.
@objc
public class BatchFlutterPlugin: NSObject, FlutterPlugin {
    
    // MARK: Internal static variables & methods
    
    private static var didCallSetup = false
    
    private static func setupBatchEnvironmentVariables() {
        setenv(Consts.BridgeVersionEnvironmentVar, Consts.BridgeVersion, 1)
        setenv(Consts.PluginVersionEnvironmentVar, Consts.PluginVersion, 1)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = BatchFlutterPlugin()
        registerChannel(name: "batch_flutter", registrar: registrar, pluginInstance: instance)
        registerChannel(name: "batch_flutter.user", registrar: registrar, pluginInstance: instance)
        registerChannel(name: "batch_flutter.push", registrar: registrar, pluginInstance: instance)
        registerChannel(name: "batch_flutter.inbox", registrar: registrar, pluginInstance: instance)
        registerChannel(name: "batch_flutter.messaging", registrar: registrar, pluginInstance: instance)
    }
    
    private static func registerChannel(name: String, registrar: FlutterPluginRegistrar, pluginInstance: BatchFlutterPlugin) {
        let channel = FlutterMethodChannel(name: name, binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(pluginInstance, channel: channel)
    }

    // MARK: Internal instance variables & methods
    
    private let bridge = Bridge()
    
    public func handle(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        if !isSetup {
            let errorMessage = """
                batch_flutter's BatchFlutterPlugin.setup() has not been called.
                Please make sure that you followed the integration steps, and called this method
                in your AppDelegate's didFinishLaunchingWithOptions method.
                """
            BatchFlutterLogger.logDebug(module: "Bridge", message: errorMessage)
            flutterResult(FlutterError(code: BridgeError.ErrorCode.missingSetup.rawValue,
                                       message: errorMessage,
                                       details: nil))
            return
        }
        
        // We only support [String: AnyObject] arguments, or nil.
        var bridgeParameters: [String: AnyObject] = [:]
        
        if let callArguments = call.arguments {
            if let dictionaryArguments =  callArguments as? [String: AnyObject] {
                bridgeParameters = dictionaryArguments
            } else {
                let errorMessage = "Bridge message root arguments were not nil, but not [String: AnyObject]."
                BatchFlutterLogger.logDebug(module: "Bridge", message: errorMessage)
                flutterResult(FlutterError(code: BridgeError.ErrorCode.badArgumentType.rawValue,
                                           message: errorMessage,
                                           details: nil))
                return
            }
        }
        
        bridge.call(rawAction: call.method, parameters: bridgeParameters)
            .continueOn(bridgeExecutorQueue)
            .then { bridgeResult in
                BatchFlutterLogger.logDebug(module: "Bridge", message: "Got Batch Flutter Call: \(call.method). Result: \(String(describing: bridgeResult))")
                flutterResult(bridgeResult)
            }
            .catch { error in
                if let internalError = error as? BridgeInternalError {
                    if internalError == BridgeInternalError.notImplemented {
                        flutterResult(FlutterMethodNotImplemented)
                        return
                    } else {
                        let errorMessage = "Internal Batch native bridge error (\(internalError)). Please see the console for more info."
                        BatchFlutterLogger.logDebug(module: "Bridge", message: errorMessage)
                        flutterResult(FlutterError(code: BridgeError.ErrorCode.unknownBridgeError.rawValue,
                                                   message: errorMessage,
                                                   details: nil))
                        return
                    }
                } else if let bridgeError = error as? BridgeError {
                    flutterResult(FlutterError(code: bridgeError.code.rawValue,
                                               message: bridgeError.description,
                                               details: bridgeError.details))
                    return
                }
                flutterResult(FlutterError(code: BridgeError.ErrorCode.unknownBridgeError.rawValue,
                                           message: "Unknown Batch native bridge error (\(String(describing: error))). Please see the console for more info.",
                                           details: nil))
                return
            }
    }
    
    internal var isSetup: Bool {
        return BatchFlutterPlugin.didCallSetup
    }
    
    /// Allows the tests to deice how the bridge executor callbacks will be ran
    /// This allows simple calls to be tested (not ones that actually require threading)
    internal var bridgeExecutorQueue: LightPromiseExecutor = LightPromiseExecutor.asyncMain
    
    /// Starts the SDK is the plugin is in managed mode. Does nothing otherwise.
    internal static func startManagedNativeSDK() {
        if manageBatchLifecycle {
            if let batchAPIKey = configuration.actualAPIKey {
                Batch.start(withAPIKey: batchAPIKey)
                BatchPush.refreshToken()
            } else {
                BatchFlutterLogger.logDebug(module: "Bridge", message: "Attempted to start Batch without an apikey, which we had beforehand")
            }
        }
    }
    
    // MARK: Public API
    
    /**
     Get the plugin configuration object.
     It will be initialized with fallback default values.
     
     Once `setup()` has been called, changing values in the object returned by thris property will not have any effect.
     */
    public private(set) static var configuration: BatchPluginConfiguration = BatchPluginConfiguration()
    
    /**
     Set whether BatchFlutterPlugin should automatically manage Batch's lifecycle, as in automatically start.
     
     If you add batch_flutter in a hybrid application, you should turn this off and start/configure Batch natively.
     */
    public static var manageBatchLifecycle: Bool = true
    
    /**
     Prepare Batch's Flutter Plugin for use.
     This must be called in `application(_:didFinishLaunchingWithOptions:)`.
     Failure to do so will throw exceptions on the Flutter side of the plugin.
     
     Once setup succeeds, the configuration cannot be changed using the `configuration` property anymore.
     
     If `manageBatchLifecycle` is true, this method will start Batch and refresh the push token.
     
     - Returns: True if the plugin was setup, false othwersie. Returns true on any subsequent call if one setup call succeeded.
     */
    @discardableResult
    public static func setup() -> Bool {
        if didCallSetup {
            BatchFlutterLogger.logPublic(module: "Plugin", message: "BatchFlutterPlugin.setup() has already been called. Ignoring extra setup call.");
            return true
        }
        
        if !configuration.apply() {
            BatchFlutterLogger.logDebug(module: "Plugin", message: "Could not setup BatchFlutterPlugin: your configuration is invalid. Did you set a non-null APIKey using the configuration var or using Info.plist keys?")
            return false
        }
        
        didCallSetup = true
        
        startManagedNativeSDK()
        
        setupBatchEnvironmentVariables()
        
        return true
    }
}
