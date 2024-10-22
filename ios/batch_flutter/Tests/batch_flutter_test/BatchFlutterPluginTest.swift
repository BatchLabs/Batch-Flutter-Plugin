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
    
    func testBridgeErrors() {
        let plugin = ControllableBatchFlutterPlugin()
        plugin.isSetupOverride = true
        plugin.bridgeExecutorQueue = LightPromiseExecutor.synchronous
        
        var notImplementedResult = RecordingFlutterResult()
        plugin.handle(FlutterMethodCall(methodName: "not_implemented", arguments: nil), result: notImplementedResult.asFlutterCallback())
        
        XCTAssertTrue(notImplementedResult.gotResult)
        XCTAssertTrue(notImplementedResult.isNotImplemented)
        
        notImplementedResult = RecordingFlutterResult()
        plugin.handle(FlutterMethodCall(methodName: "", arguments: nil), result: notImplementedResult.asFlutterCallback())
        
        XCTAssertTrue(notImplementedResult.gotResult)
        XCTAssertTrue(notImplementedResult.isNotImplemented)
    }
    
    func testBridgeSuccess() {
        let plugin = ControllableBatchFlutterPlugin()
        plugin.isSetupOverride = true
        plugin.bridgeExecutorQueue = LightPromiseExecutor.synchronous
        
        let helloWorld = "Hello, world!"
        var echoResult = RecordingFlutterResult()
        plugin.handle(FlutterMethodCall(methodName: "echo", arguments: ["value": helloWorld]), result: echoResult.asFlutterCallback())
        
        XCTAssertTrue(echoResult.gotResult)
        XCTAssertEqual(helloWorld, echoResult.lastResult as? String)
        
        echoResult = RecordingFlutterResult()
        plugin.handle(FlutterMethodCall(methodName: "echo", arguments: ["value": nil]), result: echoResult.asFlutterCallback())
        
        XCTAssertTrue(echoResult.gotResult)
        XCTAssertNil(echoResult.lastResult)
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
