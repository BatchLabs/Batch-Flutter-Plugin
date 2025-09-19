import Foundation
import Batch
import Flutter

struct Bridge {
    private let inboxBridge = InboxBridge()
    
    // Bool is a temporary return value
    func call(rawAction: String, parameters: BridgeParameters) -> LightPromise {
        guard let action = Action.init(rawValue: rawAction) else {
            BatchFlutterLogger.logDebug(module: "Bridge", message: "Invalid action name \(rawAction)")
            return LightPromise.rejected(BridgeInternalError.notImplemented)
        }
        
        return doAction(action, parameters: parameters)
    }
    
    func doAction(_ action: Action, parameters: BridgeParameters) -> LightPromise {
        do {
            switch action {
                case .optIn:
                    return optIn()
                case .optOut:
                    return optOut()
                case .optOutAndWipeData:
                    return optOutAndWipeData()
                case .isOptedOut:
					return .resolved(.number(BatchSDK.isOptedOut as NSNumber))
                case .setAutomaticDataCollection:
                    try setAutomaticDataCollection(parameters: parameters)
                    return .emptySuccess
                case .push_iOSRefreshToken:
                    BatchPush.refreshToken()
                    return .emptySuccess
                case .push_RequestPermission:
                    BatchPush.requestNotificationAuthorization()
                    return .emptySuccess
                case .push_iOSRequestProvisionalPermission:
                    BatchPush.requestProvisionalNotificationAuthorization()
                    return .emptySuccess
                case .push_dismissNotifications:
                    BatchPush.dismissNotifications()
                    return .emptySuccess
                case .push_clearBadge:
                    BatchPush.clearBadge()
                    return .emptySuccess
                case .push_iOSSetShowForegroundNotifications:
                    try setShowForegroundNotifications(parameters: parameters)
                    return .emptySuccess
                case .push_getLastKnownPushToken:
					return .resolved(.string(BatchPush.lastKnownPushToken as String?))
                case .push_setShowNotifications:
                    return .emptySuccess
                case .push_shouldShowNotifications:
					return .emptySuccess
                case .user_getInstallationID:
                    return getInstallationID()
                case .user_getIdentifier:
					return .resolved(.string(BatchUser.identifier()))
                case .user_getLanguage:
                    return .resolved(.string(BatchUser.language()))
                case .user_getRegion:
					return .resolved(.string(BatchUser.region()))
                case .user_fetchAttributes:
                    return userDataFetchAttributes()
                case .user_fetchTags:
                    return userDataFetchTags()
                case .user_clearInstallationData:
                    BatchUser.clearInstallationData()
                    return .emptySuccess
                case .profile_identify:
                    try identify(parameters: parameters)
                    return .emptySuccess
                case .profile_edit:
                    try editProfileAttributes(parameters: parameters)
                    return .emptySuccess
                case .profile_trackEvent:
                     return trackEvent(parameters)
                case .profile_trackLocation:
                    try trackLocation(parameters)
                    return .emptySuccess
                case .messaging_showPendingMessage:
                    showPendingMessage()
                    return .emptySuccess
                case .messaging_setDoNotDisturbEnabled:
                    try setDoNotDisturbEnabled(parameters: parameters)
                    return .emptySuccess
                case .debug_showDebugView:
                    showDebugView()
                    return .emptySuccess
                case .inbox_releaseFetcher,
                     .inbox_createInstallationFetcher,
                     .inbox_createUserFetcher,
                     .inbox_fetchNextPage,
                     .inbox_fetchNewNotifications,
                     .inbox_getFetchedNotifications,
                     .inbox_markAsRead,
                     .inbox_markAllAsRead,
                     .inbox_markAsDeleted,
                     .inbox_displayLandingMessage:
					return try inboxBridge.doAction(action, parameters: parameters)
				case .echo:
					return .resolved(.string(parameters["value"] as? String))
                //default:
                //    return LightPromise<AnyObject?>.rejected(BridgeInternalError.notImplemented)
            }
        } catch {
            return .rejected(error)
        }
    }
    
    private func getInstallationID() -> LightPromise {
        var installID = BatchUser.installationID
        // To maintain consistency with Android, an empty installation ID will be nilled.
        // It's a native SDK weirdness that might someday change
        if installID?.count == 0 {
            installID = nil
        }
		return .resolved(.string(installID))
    }

    private func setShowForegroundNotifications(parameters: BridgeParameters) throws {
        guard let enabled = parameters["enabled"] as? Bool else {
            throw BridgeError.makeBadArgumentError(argumentName: "enabled")
        }
        
        BatchUNUserNotificationCenterDelegate.sharedInstance.showForegroundNotifications = enabled
    }
    
    private func setAutomaticDataCollection(parameters: BridgeParameters) throws {
        guard let serializedConfig = parameters["dataCollectionConfig"] as? [String: AnyObject] else {
            throw BridgeError.makeBadArgumentError(argumentName: "dataCollectionConfig")
        }
        BatchSDK.updateAutomaticDataCollection { editor in
            if let deviceModelEnabled = serializedConfig["deviceModel"] as? NSNumber {
                editor.setDeviceModelEnabled(deviceModelEnabled.boolValue)
            }
            if let geoIPEnabled = serializedConfig["geoIP"] as? NSNumber {
                editor.setGeoIPEnabled(geoIPEnabled.boolValue)
            }
        }
    }
}
