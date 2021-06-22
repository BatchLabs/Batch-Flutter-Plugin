import Foundation

public struct BatchFlutterLogger {
    public static var enableDebugLogs = false
    
    internal static func logDebug(message: String) {
        if enableDebugLogs {
            print("BatchFlutter (debug) - \(message)")
        }
    }
    
    internal static func logPublic(message: String) {
        print("BatchFlutter - \(message)")
    }
}
