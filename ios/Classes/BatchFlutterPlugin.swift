import Flutter
import UIKit
import Batch

@objc
public class BatchFlutterPlugin: NSObject, FlutterPlugin {
    
    private static var didCallSetup = false
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "batch_flutter", binaryMessenger: registrar.messenger())
        let instance = BatchFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
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
