/// Internal bridge erorrs, which may not be surfaced to the flutter plugin in detail
enum BridgeInternalError: Error {
    case notImplemented
}

/// Describes a bridge error that will be surfaced to the flutter plugin
struct BridgeError: Error {
    enum ErrorCode: String {
        case unknownBridgeError
        case internalBridgeError
        case badArgumentType
        case missingSetup
    }
    
    let code: ErrorCode
    let description: String
    let details: [String: AnyObject]?
    
    /// Helper for badBridgeArgumentType as it is a common error
    static func makeBadArgumentError(argumentName: String) -> BridgeError {
        return BridgeError(code: ErrorCode.badArgumentType, description: "Required parameter '\(argumentName)' missing or of wrong type", details: nil)
    }
}
