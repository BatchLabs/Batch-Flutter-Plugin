import Foundation
import Batch

fileprivate struct PlistKeys {
    static let APIKey = "BatchFlutterAPIKey"
    static let canUseAdvancedDeviceInformation = "BatchFlutterCanUseAdvancedDeviceInformation"
    static let initialDnDState = "BatchFlutterDoNotDisturbInitialState"
}

/**
 Manages Batch's Flutter plugin configuration. Do not instantiate this directly, use BatchFlutterPlugin to get an instance: your changes will otherwise be ignored.
 
 This class' default values are initialized using your Info.plist settings, if any.
 */
@objc
public class BatchPluginConfiguration: NSObject {
    
    public var APIKey: String? = nil

    @available(*, deprecated, message: "As Batch has removed support for automatic IDFA collection, this property does nothing.")
    public var canUseIDFA: Bool = false

    public var canUseAdvancedDeviceInformation: Bool = true
    public var initialDoNotDisturbState: Bool = false
    
    /// Store the API Key in a different variable, so that editing "APIKey" has no effect until "apply" is called
    internal var actualAPIKey: String? = nil
    
    private var didReadInfoPlist = false
    
    override init() {
        super.init()
        readFromPlist()
    }
    
    internal func readFromPlist() {
        if (didReadInfoPlist) {
            return
        }
        didReadInfoPlist = true
        
        APIKey = PlistReader.readString(key: PlistKeys.APIKey)
        canUseAdvancedDeviceInformation = PlistReader.readBoolean(key: PlistKeys.canUseAdvancedDeviceInformation, fallbackValue: canUseAdvancedDeviceInformation)
        initialDoNotDisturbState = PlistReader.readBoolean(key: PlistKeys.initialDnDState, fallbackValue: initialDoNotDisturbState)
    }
    
    /// Apply configuration. Returns true on success.
    internal func apply() -> Bool {
        if let APIKey = APIKey, APIKey.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
            actualAPIKey = APIKey
            BatchMessaging.doNotDisturb = initialDoNotDisturbState
            return true
        } else {
            // No API key
            return false
        }
    }
}
