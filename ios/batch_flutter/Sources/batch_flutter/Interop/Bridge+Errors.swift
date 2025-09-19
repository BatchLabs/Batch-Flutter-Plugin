/// Internal bridge erorrs, which may not be surfaced to the flutter plugin in detail
enum BridgeInternalError: Error, Sendable {
    case notImplemented
}

/// Describes a bridge error that will be surfaced to the flutter plugin
struct BridgeError: Error, Sendable {
    enum ErrorCode: String {
        case unknownBridgeError
        case internalBridgeError
        case internalSDKError
        case badArgumentType
        case missingSetup
        case inboxError
    }
    
    let code: ErrorCode
    let description: String
	nonisolated(unsafe) let details: [String: AnyObject]?
    
    /// Helper for badBridgeArgumentType as it is a common error
    static func makeBadArgumentError(argumentName: String) -> BridgeError {
        return BridgeError(code: ErrorCode.badArgumentType, description: "Required parameter '\(argumentName)' missing or of wrong type", details: nil)
    }
}
