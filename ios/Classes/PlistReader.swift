import Foundation

// Reads values from Info.plist
public struct PlistReader {
    static func readBoolean(key: String, fallbackValue: Bool) -> Bool {
        return Bundle.main.object(forInfoDictionaryKey: key) as? Bool ?? fallbackValue
    }
    
    static func readString(key: String, fallbackValue: String? = nil) -> String? {
        return Bundle.main.object(forInfoDictionaryKey: key) as? String ?? fallbackValue
    }
}
