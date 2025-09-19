import Foundation

/// Dispatch queue specific key, used to know if we're already in a state mutation and avoid a deadlock
nonisolated(unsafe) fileprivate let promiseStateMutatingQueueKey = DispatchSpecificKey<Any>()

/// Simple promise implementation
/// Does not support the complete Promise spec (for example, there is no recovery mechanism, no chaining, then cannot change values, ...)
internal final class LightPromise: Sendable {
	typealias ThenBlock = @Sendable (LightPromiseObject) -> Void
    typealias CatchBlock = @Sendable (Error?) -> Void

	// Wrapper to safely capture promise callbacks in @Sendable contexts
	struct Callbacks: @unchecked Sendable {
		let resolve: (LightPromiseObject) -> Void
		let reject: (Error) -> Void

		internal init(resolve: @escaping (LightPromiseObject) -> Void, reject: @escaping (Error) -> Void) {
			self.resolve = resolve
			self.reject = reject
		}
	}
    
	enum Status: Sendable {
        case pending
        case resolved(value: LightPromiseObject)
        case rejected(error: Error?)
    }
    
    private let state = LightPromiseState()
    private let stateMutatingQueue = DispatchQueue(label: "com.batch.flutter.LightPromise", qos: .userInitiated)
    
	init(_ promiseWorkBlock: @escaping @Sendable (_ resolve: @escaping @Sendable (LightPromiseObject) -> Void,
                                        _ reject: @escaping @Sendable (Error) -> Void) -> Void) {
		stateMutatingQueue.setSpecific(key: promiseStateMutatingQueueKey, value: ())
        promiseWorkBlock(self._resolve(_:), self._reject(_:))
    }

    //MARK: Public API
    
    static func resolved(_ value: LightPromiseObject) -> LightPromise {
        return LightPromise { resolve, _ in
            resolve(value)
        }
    }
	
    static func rejected(_ error: Error) -> LightPromise {
        return LightPromise { _, reject in
            reject(error)
        }
    }
	
	static var emptySuccess: LightPromise {
		return LightPromise.resolved(.null)
	}
    
    func continueOn(_ newExecutor: LightPromiseExecutor) -> Self {
		usingState {
			self.state.setExecutor(newExecutor)
        }
        return self
    }

    @discardableResult
	func then(_ block: @Sendable @escaping (LightPromiseObject) -> Void) -> Self {
		usingState {
			self.state.addThenBlock(block)
        }
        return self
    }

    @discardableResult
    func `catch`(_ block: @Sendable @escaping (Error?) -> Void) -> Self {
		usingState {
			self.state.addCatchBlock(block)
        }
        return self
    }
    
    //MARK: Private functions
    
    private func _resolve(_ value: LightPromiseObject) {
		usingState {
			self.state.resolve(with: value)
        }
    }

    private func _reject(_ error: Error) {
		usingState {
			self.state.reject(with: error)
        }
    }
    
	private func usingState(_ block: @escaping () -> Void) {
		// If we're already on the stateMutatingQueue, don't deadlock and run this immediatly
		if DispatchQueue.getSpecific(key: promiseStateMutatingQueueKey) != nil {
			block()
		} else {
			stateMutatingQueue.sync {
				block()
			}
		}
	}
}

