import Foundation
import Batch

fileprivate struct PlistKeys {
    static let APIKey = "BatchFlutterAPIKey"
    static let initialDnDState = "BatchFlutterDoNotDisturbInitialState"
    static let profileCustomIdMigrationEnabled = "BatchFlutterProfileCustomIdMigrationEnabled"
    static let profileCustomDataMigrationEnabled = "BatchFlutterProfileCustomDataMigrationEnabled"
}


/**
 Manages Batch's Flutter plugin configuration. Do not instantiate this directly, use BatchFlutterPlugin to get an instance: your changes will otherwise be ignored.
 
 This class' default values are initialized using your Info.plist settings, if any.
 */
@objc
public class BatchPluginConfiguration: NSObject {
    
    /// The Batch API Key
    public var APIKey: String? = nil

    /// The initial do not disturb state.
    public var initialDoNotDisturbState: Bool = false
    
    /// Whether Batch should automatically identify logged-in user when running the SDK for the first time.
    public var profileCustomIdMigrationEnabled: Bool = true
    
    /// Whether Batch should automatically attach current installation's data (language/region/customDataAttributes...) to the User's Profile when running the SDK for the first time.
    public var profileCustomDataMigrationEnabled: Bool = true
    
    /// Store the API Key in a different variable, so that editing "APIKey" has no effect until "apply" is called
    internal var actualAPIKey: String? = nil
    
    /// Flag indicating if this configuration has already been setup from the info.plist file
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
        initialDoNotDisturbState = PlistReader.readBoolean(key: PlistKeys.initialDnDState, fallbackValue: initialDoNotDisturbState)
        profileCustomIdMigrationEnabled = PlistReader.readBoolean(key: PlistKeys.profileCustomIdMigrationEnabled, fallbackValue: true)
        profileCustomDataMigrationEnabled = PlistReader.readBoolean(key: PlistKeys.profileCustomDataMigrationEnabled, fallbackValue: true)
    }
    
    /// Apply configuration. Returns true on success.
    internal func apply() -> Bool {
        if let APIKey = APIKey, APIKey.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
            actualAPIKey = APIKey
            BatchMessaging.doNotDisturb = initialDoNotDisturbState
            var migrations : BatchMigration = []
            if (!profileCustomIdMigrationEnabled) {
                BatchFlutterLogger.logDebug(module: "Plugin", message: "Disabling profile custom id migration.")
                migrations.insert(.customID)
            }
            if (!profileCustomDataMigrationEnabled) {
                BatchFlutterLogger.logDebug(module: "Plugin", message: "Disabling profile custom data migration.")
                migrations.insert(.customData)
            }
            BatchSDK.setDisabledMigrations(migrations)
            return true
        } else {
            // No API key
            return false
        }
    }
}
