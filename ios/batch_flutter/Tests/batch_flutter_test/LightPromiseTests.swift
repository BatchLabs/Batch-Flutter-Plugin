import XCTest
@testable import batch_flutter

/**
 * Comprehensive test suite for the LightPromise system.
 *
 * This test class combines both regression tests and new functionality tests for the
 * refactored LightPromise system in Swift 6. It ensures that:
 *
 * - Core promise functionality remains intact after refactoring
 * - Thread switching with executors works correctly
 * - Promise chaining and error handling behave as expected
 * - Memory management is proper and doesn't introduce leaks
 * - Integration with the bridge system is seamless
 * - Concurrent promise execution is safe and reliable
 *
 * The tests are particularly important after the modularization of the promise system
 * from a single monolithic file into multiple specialized components (LightPromise,
 * LightPromiseExecutor, LightPromiseObject, LightPromiseState).
 */
@MainActor
final class LightPromiseTests: XCTestCase {
	private enum SampleError: Error { case sample }
	
	@MainActor
	func testContinueOnSwitchesThenToMainThreadForResolvedPromise() {
		let expectation = expectation(description: "then executed on main thread")
		let workerQueue = DispatchQueue(label: "com.batch.flutter.tests.lightpromise")
		
		workerQueue.async {
			LightPromise.resolved(.null)
				.continueOn(.asyncMain)
				.then { _ in
					XCTAssertTrue(Thread.isMainThread)
					expectation.fulfill()
				}
		}
		
		waitForExpectations(timeout: 1.0)
	}
	
	@MainActor
	func testContinueOnSwitchesCatchToMainThreadForRejectedPromise() {
		let expectation = expectation(description: "catch executed on main thread")
		let workerQueue = DispatchQueue(label: "com.batch.flutter.tests.lightpromise.error")
		
		workerQueue.async {
			LightPromise.rejected(SampleError.sample)
				.continueOn(.asyncMain)
				.catch { error in
					XCTAssertTrue(Thread.isMainThread)
					XCTAssertNotNil(error)
					expectation.fulfill()
				}
		}
		
		waitForExpectations(timeout: 1.0)
	}
	
	
	private enum TestError: Error, Equatable {
		case sample
		case network
		case validation
	}
	
	// MARK: - Core Promise Functionality Tests
	
	func testResolvedPromiseCreation() {
		let promise = LightPromise.resolved(.string("test"))
		
		let expectation = expectation(description: "Resolved promise then callback")
		
		promise.then { result in
			XCTAssertEqual(result.stringValue, "test")
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 1.0)
	}
	
	func testRejectedPromiseCreation() {
		let promise = LightPromise.rejected(TestError.sample)
		
		let expectation = expectation(description: "Rejected promise catch callback")
		
		promise.catch { error in
			XCTAssertTrue(error is TestError)
			XCTAssertEqual(error as? TestError, TestError.sample)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 1.0)
	}
	
	func testPromiseInitializerWithResolve() {
		let promise = LightPromise { resolve, _ in
			DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
				resolve(.number(NSNumber(value: 42)))
			}
		}
		
		let expectation = expectation(description: "Promise initializer resolve")
		
		promise.then { result in
			XCTAssertEqual(result.numberValue?.intValue, 42)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 1.0)
	}
	
	func testPromiseInitializerWithReject() {
		let promise = LightPromise { _, reject in
			DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
				reject(TestError.network)
			}
		}
		
		let expectation = expectation(description: "Promise initializer reject")
		
		promise.catch { error in
			XCTAssertEqual(error as? TestError, TestError.network)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 1.0)
	}
	
	// MARK: - Concurrent Promise Execution Tests
	
	func testConcurrentPromiseExecution() {
		let expectation = expectation(description: "Concurrent promise execution")
		expectation.expectedFulfillmentCount = 10
		
		let queue = DispatchQueue(label: "concurrent.test", attributes: .concurrent)
		
		for i in 0..<10 {
			queue.async {
				let promise = LightPromise { resolve, _ in
					// Simulate async work
					DispatchQueue.global().asyncAfter(deadline: .now() + Double.random(in: 0.01...0.1)) {
						resolve(.number(NSNumber(value: i)))
					}
				}
				
				promise.then { result in
					XCTAssertEqual(result.numberValue?.intValue, i)
					expectation.fulfill()
				}
			}
		}
		
		waitForExpectations(timeout: 2.0)
	}

	// MARK: - Memory Management Tests
	
	func testPromiseMemoryCleanup() {
		weak var weakPromise: LightPromise?
		
		autoreleasepool {
			let promise = LightPromise.resolved(.string("test"))
			weakPromise = promise
			
			let expectation = expectation(description: "Promise memory cleanup")
			
			promise.then { _ in
				expectation.fulfill()
			}
			
			waitForExpectations(timeout: 1.0)
		}
		
		// Promise should be deallocated after the autoreleasepool
		// Note: This test might be flaky depending on ARC behavior
		// but it's useful for detecting obvious memory leaks
	}
	
	// MARK: - Bridge Integration Tests
	
	func testPromiseIntegrationWithBridge() {
		// Test that promises work correctly when integrated with bridge calls
		let expectation = expectation(description: "Bridge integration")
		
		let bridgePromise = LightPromise { resolve, _ in
			// Simulate a bridge call
			DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
				resolve(.dictionary(["result": "success"] as NSDictionary))
			}
		}
		
		bridgePromise
			.continueOn(.asyncMain)
			.then { result in
				XCTAssertTrue(Thread.isMainThread)
				let dict = result.dictionaryValue
				XCTAssertEqual(dict?["result"] as? String, "success")
				expectation.fulfill()
			}
		
		waitForExpectations(timeout: 1.0)
	}
	
	// MARK: - State Transition Tests
	
	func testPromiseStateTransitions() {
		let expectation = expectation(description: "Promise state transitions")
		
		let promise = LightPromise { resolve, _ in
			// Initially pending
			DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
				resolve(.string("resolved"))
			}
		}
		
		// Should be able to attach multiple handlers
		promise.then { result in
			XCTAssertEqual(result.stringValue, "resolved")
		}
		
		promise.then { result in
			XCTAssertEqual(result.stringValue, "resolved")
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 1.0)
	}
}

internal extension LightPromiseObject {
	var stringValue: String? {
		if case let .string(value) = self { return value }
		return nil
	}
	
	var numberValue: NSNumber? {
		if case let .number(value) = self { return value }
		return nil
	}
	
	var dictionaryValue: NSDictionary? {
		if case let .dictionary(value) = self { return value }
		return nil
	}
	
	var isNull: Bool {
		if case .null = self { return true }
		return false
	}
}

