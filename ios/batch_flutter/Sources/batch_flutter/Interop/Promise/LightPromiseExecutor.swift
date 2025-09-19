import Foundation

/// Executor used to schedule promise callbacks
///  - Synchronous will run the executor on the current thread without using Dispatch's async
///  - AsyncMain is the UI thread
///  - Other values are mapped to their Dispatch QoS counterpart
enum LightPromiseExecutor: Sendable {
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
	func execute(_ block: @Sendable @escaping () -> Void) {
        if let targetQueue = self.dispatchQueue {
            targetQueue.async(execute: block)
        } else {
            // Synchronous
            block()
        }
    }
}
