import XCTest
import Foundation
@testable import batch_flutter
@preconcurrency import Flutter

/**
 *
 * This test suite addresses the migration to Swift 6 concurrency model and validates that:
 * - Properties marked with `nonisolated(unsafe)` don't cause race conditions
 * - FlutterResultBox provides thread-safe callback encapsulation
 * - @MainActor isolation works correctly across different execution contexts
 * - The refactored promise system maintains thread safety
 *
 * These tests are critical for ensuring the reliability of the Batch Flutter Plugin
 * after the Swift 6 concurrency migration.
 */
final class ConcurrencySafetyTests: XCTestCase {

    // MARK: - nonisolated(unsafe) Properties Tests

	@MainActor
	func testBatchFlutterLoggerEnableDebugLogsThreadSafety() {
        // Test concurrent access to nonisolated(unsafe) enableDebugLogs property
        let expectation = expectation(description: "Concurrent logger access")
        expectation.expectedFulfillmentCount = 100

        let queue = DispatchQueue(label: "logger.test", attributes: .concurrent)

        // Reset to known state
        BatchFlutterLogger.enableDebugLogs = false

        // Concurrent reads and writes to test for race conditions
        for i in 0..<50 {
            queue.async {
                BatchFlutterLogger.enableDebugLogs = (i % 2 == 0)
                expectation.fulfill()
            }

            queue.async {
                let _ = BatchFlutterLogger.enableDebugLogs
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5.0)

        // Verify the property is still accessible and functional
        BatchFlutterLogger.enableDebugLogs = true
        XCTAssertTrue(BatchFlutterLogger.enableDebugLogs)

        BatchFlutterLogger.enableDebugLogs = false
        XCTAssertFalse(BatchFlutterLogger.enableDebugLogs)
    }

    @MainActor
    func testBatchFlutterPluginStaticPropertiesThreadSafety() {
        let expectation = expectation(description: "Concurrent plugin static access")
        expectation.expectedFulfillmentCount = 60

        let queue = DispatchQueue(label: "plugin.statics.test", attributes: .concurrent)

        // Test concurrent access to configuration
        for _ in 0..<20 {
            queue.async {
                Task { @MainActor in
                    let _ = BatchFlutterPlugin.manageBatchLifecycle
                    expectation.fulfill()
                }
            }
        }

        // Test concurrent access to manageBatchLifecycle
        for i in 0..<20 {
            queue.async {
                Task { @MainActor in
                    BatchFlutterPlugin.manageBatchLifecycle = (i % 2 == 0)
                    expectation.fulfill()
                }
            }

            queue.async {
                Task { @MainActor in
                    let _ = BatchFlutterPlugin.manageBatchLifecycle
                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 5.0)
    }

    @MainActor
    func testBatchFlutterPluginSetupConcurrency() {
        // Reset setup state if possible (this is tricky since it's private static)
        // This test verifies that multiple concurrent setup calls don't cause issues
        let expectation = expectation(description: "Concurrent setup calls")
        expectation.expectedFulfillmentCount = 10

        let queue = DispatchQueue(label: "plugin.setup.test", attributes: .concurrent)

        for _ in 0..<10 {
            queue.async {
                Task { @MainActor in
                    let _ = BatchFlutterPlugin.setup()
                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 5.0)
    }

    // MARK: - FlutterResultBox Thread Safety Tests

    @MainActor
    func testFlutterResultBoxThreadSafety() {
        let expectation = expectation(description: "FlutterResultBox concurrent access")
        expectation.expectedFulfillmentCount = 50

        var capturedResults: [String] = []
        let capturedResultsLock = NSLock()

        let flutterResult: FlutterResult = { result in
            capturedResultsLock.lock()
            defer { capturedResultsLock.unlock() }
            if let stringResult = result as? String {
                capturedResults.append(stringResult)
            }
            expectation.fulfill()
        }

        let box = FlutterResultBox(result: flutterResult)
        let queue = DispatchQueue(label: "resultbox.test", attributes: .concurrent)

        // Test concurrent access to the same FlutterResultBox
        for i in 0..<50 {
            queue.async {
                box.result("Test \(i)")
            }
        }

        waitForExpectations(timeout: 5.0)

        // Verify we received all results
        XCTAssertEqual(capturedResults.count, 50)
        XCTAssertTrue(capturedResults.contains("Test 0"))
        XCTAssertTrue(capturedResults.contains("Test 49"))
    }

    @MainActor
    func testMainActorIsolationFromBackgroundThread() {
        let expectation = expectation(description: "MainActor isolation from background")

        DispatchQueue.global(qos: .background).async {
            Task { @MainActor in
                XCTAssertTrue(Thread.isMainThread)
                let _ = BatchFlutterPlugin.setup()
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5.0)
    }

    // MARK: - Promise System Regression Tests

    @MainActor
    func testLightPromiseThreadSwitching() {
        let expectation = expectation(description: "Promise thread switching")
        let backgroundQueue = DispatchQueue(label: "promise.background")

        backgroundQueue.async {
            XCTAssertFalse(Thread.isMainThread)

            LightPromise.resolved(.string("test"))
                .continueOn(.asyncMain)
                .then { result in
                    XCTAssertTrue(Thread.isMainThread)
                    XCTAssertEqual(result.stringValue, "test")
                    expectation.fulfill()
                }
                .catch { error in
                    XCTFail("Promise should not have failed: \(error)")
                    expectation.fulfill()
                }
        }

        waitForExpectations(timeout: 5.0)
    }

    @MainActor
    func testLightPromiseErrorHandlingThreadSwitching() {
        let expectation = expectation(description: "Promise error thread switching")
        let backgroundQueue = DispatchQueue(label: "promise.error.background")

        enum TestError: Error {
            case testCase
        }

        backgroundQueue.async {
            XCTAssertFalse(Thread.isMainThread)

            LightPromise.rejected(TestError.testCase)
                .continueOn(.asyncMain)
                .then { _ in
                    XCTFail("Promise should not have succeeded")
                    expectation.fulfill()
                }
                .catch { error in
                    XCTAssertTrue(Thread.isMainThread)
                    XCTAssertTrue(error is TestError)
                    expectation.fulfill()
                }
        }

        waitForExpectations(timeout: 5.0)
    }

    // MARK: - Bridge Parameter Safety Tests

    @MainActor
    func testBridgeParametersThreadSafety() {
        let expectation = expectation(description: "BridgeParameters concurrent access")
        expectation.expectedFulfillmentCount = 100

        let testData: [String: AnyObject] = [
            "string": "test" as NSString,
            "number": NSNumber(value: 42),
            "bool": NSNumber(value: true)
        ]

        let queue = DispatchQueue(label: "bridgeparams.test", attributes: .concurrent)

        for _ in 0..<50 {
            queue.async {
                let params = BridgeParameters(value: testData)
                XCTAssertEqual(params["string"] as? String, "test")
                XCTAssertEqual(params["number"] as? NSNumber, NSNumber(value: 42))
                expectation.fulfill()
            }

            queue.async {
                let emptyParams = BridgeParameters()
                XCTAssertNil(emptyParams["nonexistent"])
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5.0)
    }

    // MARK: - Memory Safety Tests

    func testFlutterResultBoxMemoryRetention() {
        weak var weakResult: AnyObject?

        autoreleasepool {
            let strongResult: FlutterResult = { result in
                // Capture result to ensure it's retained
                weakResult = result as AnyObject
            }

            let box = FlutterResultBox(result: strongResult)
            box.result("test")

            // At this point, strongResult should still be retained by the box
            XCTAssertNotNil(weakResult)
        }

        // After autoreleasepool, the box should be deallocated
        // but we can't easily test this without more complex setup
    }

    // MARK: - Error Propagation Tests

    @MainActor
    func testConcurrentErrorHandling() {
        let expectation = expectation(description: "Concurrent error handling")
        expectation.expectedFulfillmentCount = 20

        let plugin = ControllableBatchFlutterPlugin()
        plugin.isSetupOverride = true
        plugin.bridgeExecutorQueue = .asyncMain

        let queue = DispatchQueue(label: "error.test", attributes: .concurrent)

        for i in 0..<20 {
            queue.async {
                let call = FlutterMethodCall(methodName: "invalid_method_\(i)", arguments: nil)

                plugin.handle(call) { result in
                    XCTAssertTrue(Thread.isMainThread)
                    // Should receive FlutterMethodNotImplemented
                    XCTAssertTrue((result as? NSObject) === FlutterMethodNotImplemented)
                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 5.0)
    }
}

// MARK: - Test Helpers

extension ConcurrencySafetyTests {

    /**
     * Test helper class that provides controllable plugin behavior for testing.
     *
     * This subclass of BatchFlutterPlugin allows tests to override the setup state,
     * enabling testing of various plugin states without requiring actual SDK initialization.
     * This is essential for isolated unit testing of plugin behavior.
     */
    private class ControllableBatchFlutterPlugin: BatchFlutterPlugin {
        var isSetupOverride: Bool = false

        override var isSetup: Bool {
            return isSetupOverride
        }
    }
}
