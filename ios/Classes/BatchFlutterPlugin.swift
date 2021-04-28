import Flutter
import UIKit
import Batch

fileprivate struct Consts {
    static let BridgeVersionEnvironmentVar = "batch.bridge.version"
    static let BridgeVersion = "Bridge/1.0"
    
    static let PluginVersionEnvironmentVar = "batch.plugin.version"
    static let PluginVersion = "Flutter/0.0.1"
}

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
    }
    
    private static func registerChannel(name: String, registrar: FlutterPluginRegistrar, pluginInstance: BatchFlutterPlugin) {
        let channel = FlutterMethodChannel(name: name, binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(pluginInstance, channel: channel)
    }

    // MARK: Internal instance variables & methods
    
    private let bridge = Bridge()
    
    public func handle(_ call: FlutterMethodCall, result flutterResult: @escaping FlutterResult) {
        // TODO: Check for setup call
        
        // We only support [String: AnyObject] arguments, or nil.
        // TODO: check if nil/empty action
        
        var bridgeParameters: [String: AnyObject] = [:]
        
        if let callArguments = call.arguments {
            if let dictionaryArguments =  callArguments as? [String: AnyObject] {
                bridgeParameters = dictionaryArguments
            } else {
                // TODO: throw error
                print("Invalid flutter arguments")
            }
        }
        
        bridge.call(rawAction: call.method, parameters: bridgeParameters)
            .continueOn(.asyncMain)
            .then { bridgeResult in
                print("Debug - Got Batch Flutter Call: \(call.method). Result: \(String(describing: bridgeResult))")
                flutterResult(bridgeResult)
            }
            .catch { error in
                if let internalError = error as? BridgeInternalError {
                    if internalError == BridgeInternalError.notImplemented {
                        //TODO: Print
                        flutterResult(FlutterError(code: BridgeError.ErrorCode.unknownBridgeError.rawValue,
                                                   message: "Internal Batch native bridge error (\(internalError)). Please see the console for more info.",
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
            //TODO log
            return true
        }
        
        if !configuration.apply() {
            //TODO log
            return false
        }
        
        didCallSetup = true
        
        if manageBatchLifecycle {
            if let batchAPIKey = configuration.actualAPIKey {
                Batch.start(withAPIKey: batchAPIKey)
                BatchPush.refreshToken()
            } else {
                // TODO: Race condition, log an error
            }
        }
        
        return true
    }
}
