import Foundation

/// Dispatch queue specific key, used to know if we're already in a state mutation and avoid a deadlock
fileprivate let promiseStateMutatingQueueKey = DispatchSpecificKey<Any>()

/// Simple promise implementation
/// Does not support the complete Promise spec (for example, there is no recovery mechanism, no chaining, then cannot change values, ...)
internal class LightPromise<T> {
    typealias ThenBlock = (T) -> Void
    typealias CatchBlock = (Error?) -> Void
    
    enum Status<S> {
        case pending
        case resolved(value: S)
        case rejected(error: Error?)
    }
    
    private var status: Status<T> = Status.pending
    private var executor: LightPromiseExecutor = LightPromiseExecutor.synchronous
    
    /// Queue used to enqueue the state mutation changes, making them thread-safe
    /// Mark this as user initiated as state changes needs to happen fast
    private var stateMutatingQueue: DispatchQueue = DispatchQueue(label: "com.batch.flutter.LightPromise", qos: .userInitiated)
    
    private var thenBlocks = [ThenBlock]()
    private var catchBlocks = [CatchBlock]()
    
    init(_ promiseWorkBlock: @escaping (_ resolve: @escaping (T) -> Void,
                                        _ reject: @escaping (Error?) -> Void) -> Void) {
        stateMutatingQueue.setSpecific(key: promiseStateMutatingQueueKey, value: ())
        promiseWorkBlock(self._resolve(_:), self._reject(_:))
    }

    //MARK: Public API
    
    static func resolved<P>(_ value: P) -> LightPromise<P> {
        return LightPromise<P> { resolve, _ in
            resolve(value)
        }
    }
    
    static func rejected<R>(_ error: Error?) -> LightPromise<R> {
        return LightPromise<R> { _, reject in
            reject(error)
        }
    }
    
    func continueOn(_ newExecutor: LightPromiseExecutor) -> Self {
        usingState {
            self.executor = newExecutor
        }
        return self
    }
    
    @discardableResult
    func then(_ block: @escaping (T) -> Void) -> Self {
        usingState {
            switch self.status {
                case .pending:
                    self.thenBlocks.append(block)
                    break
                case .resolved(value: let resolvedValue):
                    self.executor.execute {
                        block(resolvedValue)
                    }
                    break
                case .rejected(error: _):
                    // Do nothing
                    break
            }
        }
        return self
    }
    
    @discardableResult
    func `catch`(_ block: @escaping (Error?) -> Void) -> Self {
        usingState {
            switch self.status {
                case .pending:
                    self.catchBlocks.append(block)
                    break
                case .resolved(value: _):
                    // Do nothing
                    break
                case .rejected(error: let error):
                    // Do nothing
                    self.executor.execute {
                        block(error)
                    }
                    break
            }
        }
        return self
    }
    
    //MARK: Private functions
    
    private func _resolve(_ value: T) {
        usingState {
            // == can't be used on enums with associated values
            switch self.status {
                case .pending:
                    break
                default:
                    return
            }
            
            self.status = Status.resolved(value: value)
            
            let executor = self.executor
            let pendingThenBlocks = self.thenBlocks
            self.thenBlocks.removeAll()
            for pendingBlock in pendingThenBlocks {
                executor.execute {
                    pendingBlock(value)
                }
            }
        }
    }
    
    private func _reject(_ error: Error?) {
        usingState {
            // == can't be used on enums with associated values
            switch self.status {
                case .pending:
                    break
                default:
                    return
            }
            
            self.status = Status.rejected(error: error)
            
            let executor = self.executor
            let pendingCatchBlocks = self.catchBlocks
            self.catchBlocks.removeAll()
            for pendingBlock in pendingCatchBlocks {
                executor.execute {
                    pendingBlock(error)
                }
            }
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

/// Executor used to schedule promise callbacks
///  - Synchronous will run the executor on the current thread without using Dispatch's async
///  - AsyncMain is the UI thread
///  - Other values are mapped to their Dispatch QoS counterpart
enum LightPromiseExecutor {
    case synchronous
    case asyncMain
    case asyncUserInteractive
    case asyncUserInitiated
    case asyncDefault
    case asyncUtility
    case asyncBackground
    
    /// The dispatch queue associated to this executor
    var dispatchQueue: DispatchQueue? {
        switch self {
            case .synchronous:
                return nil
            case .asyncMain:
                return DispatchQueue.main
            case .asyncUserInteractive:
                return DispatchQueue.global(qos: .userInteractive)
            case .asyncUserInitiated:
                return DispatchQueue.global(qos: .userInitiated)
            case .asyncDefault:
                return DispatchQueue.global(qos: .default)
            case .asyncUtility:
                return DispatchQueue.global(qos: .utility)
            case .asyncBackground:
                return DispatchQueue.global(qos: .background)
        }
    }
    
    
    /// Execute a block, handing off to a dispatch queue is requested
    func execute(_ block: @escaping () -> Void) {
        if let targetQueue = self.dispatchQueue {
            targetQueue.async(execute: block)
        } else {
            // Synchronous
            block()
        }
    }
}
