import Foundation

public struct BatchFlutterLogger {
    public static var enableDebugLogs = false
    
    internal static func logDebug(module: String, message: String) {
        if enableDebugLogs {
            print("BatchFlutter (debug) - [\(module)] \(message)")
        }
    }
    
    internal static func logPublic(module: String, message: String) {
        print("BatchFlutter - [\(module)] \(message)")
    }
}
