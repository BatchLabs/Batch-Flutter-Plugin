import Foundation
import Batch
import Flutter

typealias BridgeParameters = [String: AnyObject]

struct Bridge {
    private let inboxBridge = InboxBridge()
    
    // Bool is a temporary return value
    func call(rawAction: String, parameters: BridgeParameters) -> LightPromise<AnyObject?> {
        guard let action = Action.init(rawValue: rawAction) else {
            BatchFlutterLogger.logDebug(module: "Bridge", message: "Invalid action name \(rawAction)")
            return LightPromise<AnyObject?>.rejected(BridgeInternalError.notImplemented)
        }
        
        return doAction(action, parameters: parameters)
    }
    
    func doAction(_ action: Action, parameters: BridgeParameters) -> LightPromise<AnyObject?> {
        do {
            switch action {
                case .optIn:
                    optIn()
                    return emptySuccessPromise()
                case .optOut:
                    return optOut()
                case .optOutAndWipeData:
                    return optOutAndWipeData()
                
                case .push_iOSRefreshToken:
                    BatchPush.refreshToken()
                    return emptySuccessPromise()
                case .push_RequestPermission:
                    BatchPush.requestNotificationAuthorization()
                    return emptySuccessPromise()
                case .push_iOSRequestProvisionalPermission:
                    BatchPush.requestProvisionalNotificationAuthorization()
                    return emptySuccessPromise()
                case .push_dismissNotifications:
                    BatchPush.dismissNotifications()
                    return emptySuccessPromise()
                case .push_clearBadge:
                    BatchPush.clearBadge()
                    return emptySuccessPromise()
                case .push_iOSSetShowForegroundNotifications:
                    try setShowForegroundNotifications(parameters: parameters)
                    return emptySuccessPromise()
                case .push_getLastKnownPushToken:
                    return LightPromise<AnyObject?>.resolved(BatchPush.lastKnownPushToken as NSString?)
                
                case .user_getInstallationID:
                    return getInstallationID()
                case .user_getIdentifier:
                    return LightPromise<AnyObject?>.resolved(BatchUser.identifier() as NSString?)
                case .user_getLanguage:
                    return LightPromise<AnyObject?>.resolved(BatchUser.language() as NSString?)
                case .user_getRegion:
                    return LightPromise<AnyObject?>.resolved(BatchUser.region() as NSString?)
                case .user_fetchAttributes:
                    return userDataFetchAttributes()
                case .user_fetchTags:
                    return userDataFetchTags()

                case .profile_identify:
                    try identify(parameters: parameters)
                    return emptySuccessPromise()
                case .profile_edit:
                    try editProfileAttributes(parameters: parameters)
                    return emptySuccessPromise()
                case .profile_trackEvent:
                     return trackEvent(parameters)
                case .profile_trackLocation:
                    try trackLocation(parameters)
                    return emptySuccessPromise()
                
                case .messaging_showPendingMessage:
                    showPendingMessage()
                    return emptySuccessPromise()
                case .messaging_setDoNotDisturbEnabled:
                    try setDoNotDisturbEnabled(parameters: parameters)
                    return emptySuccessPromise()
                
                case .debug_showDebugView:
                    showDebugView()
                    return emptySuccessPromise()
                
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
                    return LightPromise<NSString?>.resolved(parameters["value"] as? NSString)
                //default:
                //    return LightPromise<AnyObject?>.rejected(BridgeInternalError.notImplemented)
            }
        } catch {
            return LightPromise<AnyObject?>.rejected(error)
        }
    }
    
    private func getInstallationID() -> LightPromise<AnyObject?> {
        var installID = BatchUser.installationID
        // To maintain consistency with Android, an empty installation ID will be nilled.
        // It's a native SDK weirdness that might someday change
        if installID?.count == 0 {
            installID = nil
        }
        return LightPromise<AnyObject?>.resolved(installID as NSString?)
    }

    private func setShowForegroundNotifications(parameters: BridgeParameters) throws {
        guard let enabled = parameters["enabled"] as? Bool else {
            throw BridgeError.makeBadArgumentError(argumentName: "enabled")
        }
        
        BatchUNUserNotificationCenterDelegate.sharedInstance.showForegroundNotifications = enabled
    }
    
    /// Convinence method to get a promise resolved with nil
    private func emptySuccessPromise() -> LightPromise<AnyObject?> {
        return LightPromise<AnyObject?>.resolved(nil)
    }
}
