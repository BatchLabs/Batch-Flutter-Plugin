import Foundation
import Batch
import Flutter

typealias BridgeParameters = [String: AnyObject]

struct Bridge {
    // Bool is a temporary return value
    func call(rawAction: String, parameters: BridgeParameters) -> LightPromise<AnyObject?> {
        guard let action = Action.init(rawValue: rawAction) else {
            //TODO: better exception handling
            print("Invalid action name \(rawAction)")
            return LightPromise<AnyObject?>.rejected(BridgeInternalError.notImplemented)
        }
        
        return doAction(action, parameters: parameters)
    }
    
    // Bool is a temporary return value
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
                case .push_iOSRequestPermission:
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
                    //TODO
                    return LightPromise<AnyObject?>.rejected(BridgeInternalError.notImplemented)
                case .push_getLastKnownPushToken:
                    return LightPromise<AnyObject?>.resolved(BatchPush.lastKnownPushToken() as NSString?)
                    
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
                    
                case .user_edit:
                    try userDataEdit(parameters: parameters)
                    return emptySuccessPromise()
                case .user_trackEvent:
                    try trackEvent(parameters)
                    return emptySuccessPromise()
                case .user_trackLocation:
                    try trackLocation(parameters)
                    return emptySuccessPromise()
                case .user_trackTransaction:
                    try trackTransaction(parameters)
                    return emptySuccessPromise()
                case .debug_showDebugView:
                    showDebugView()
                    return emptySuccessPromise()
                case .echo:
                    return LightPromise<NSString?>.resolved(parameters["value"] as? NSString)
                default:
                    return LightPromise<AnyObject?>.rejected(BridgeInternalError.notImplemented)
            }
        } catch {
            return LightPromise<AnyObject?>.rejected(error)
        }
    }
    
    private func getInstallationID() -> LightPromise<AnyObject?> {
        var installID = BatchUser.installationID()
        // To maintain consistency with Android, an empty installation ID will be nilled.
        // It's a native SDK weirdness that might someday change
        if installID?.count == 0 {
            installID = nil
        }
        return LightPromise<AnyObject?>.resolved(installID as NSString?)
    }
    
    /// Convinence method to get a promise resolved with nil
    private func emptySuccessPromise() -> LightPromise<AnyObject?> {
        return LightPromise<AnyObject?>.resolved(nil)
    }
}
