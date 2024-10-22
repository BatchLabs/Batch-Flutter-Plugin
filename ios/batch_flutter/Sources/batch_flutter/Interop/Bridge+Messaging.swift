import Foundation
import Batch

// Bridge Messaging methods
extension Bridge {
    func showPendingMessage() {
        DispatchQueue.main.async {
            BatchMessaging.showPendingMessage()
        }
    }
    
    func setDoNotDisturbEnabled(parameters: BridgeParameters) throws {
        guard let enabled = parameters["enabled"] as? Bool else {
            throw BridgeError.makeBadArgumentError(argumentName: "enabled")
        }
        
        BatchMessaging.doNotDisturb = enabled
    }
}
