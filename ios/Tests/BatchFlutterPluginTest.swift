import Foundation
import XCTest
import Flutter
@testable import batch_flutter

class BatchFlutterPluginTest: XCTestCase {
    func testSetupErrors() {
        let plugin = ControllableBatchFlutterPlugin()
        plugin.isSetupOverride = false
        
        let didNotSetupResult = RecordingFlutterResult()
        plugin.handle(FlutterMethodCall(methodName: "user.getLanguage", arguments: nil), result: didNotSetupResult.asFlutterCallback())
        
        XCTAssertTrue(didNotSetupResult.gotResult)
        XCTAssertTrue(didNotSetupResult.isError(code: BridgeError.ErrorCode.missingSetup))
    }
}

class ControllableBatchFlutterPlugin: BatchFlutterPlugin {
    var isSetupOverride: Bool = false
    
    override var isSetup: Bool {
        return isSetupOverride
    }
}

class RecordingFlutterResult {
    var gotResult: Bool = false
    var lastResult: Any? = nil
    
    func asFlutterCallback() -> ((Any?) -> Void) {
        return { [self] pluginResult in
            gotResult = true
            lastResult = pluginResult
        }
    }
    
    var isNotImplemented: Bool {
        return (lastResult as? NSObject) === FlutterMethodNotImplemented
    }
    
    func isError(code: BridgeError.ErrorCode) -> Bool {
        return (lastResult as? FlutterError)?.code == code.rawValue
    }
    
    func isError(code: String) -> Bool {
        return (lastResult as? FlutterError)?.code == code
    }
}
