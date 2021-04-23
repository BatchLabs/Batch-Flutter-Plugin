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
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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
        
        let bridgeResult = bridge.call(rawAction: call.method, parameters: bridgeParameters)
        print("Debug - Got Batch Flutter Call: \(call.method). Result: \(String(describing: bridgeResult))")
        result(bridgeResult)
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
     
     If `manageBatchLifecycle` is true, this method will start Batch.
     
     - Returns: True if the plugin was setup, false othwersie. Returns true on any subsequent call if one setup call succeeded.
     */
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
            } else {
                // TODO: Race condition, log an error
            }
        }
        
        return true
    }
}
