import Foundation
import Batch
import Flutter

struct Bridge {
    // Bool is a temporary return value
    func call(rawAction: String, parameters: [String: AnyObject]) -> LightPromise<AnyObject?> {
        guard let action = Action.init(rawValue: rawAction) else {
            //TODO: better exception handling
            print("Invalid action name \(rawAction)")
            return LightPromise<AnyObject?>.rejected(BridgeInternalError.notImplemented)
        }
        
        return doAction(action, parameters: parameters)
    }
    
    // Bool is a temporary return value
    func doAction(_ action: Action, parameters: [String: AnyObject]) -> LightPromise<AnyObject?> {
        switch action {
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
                return LightPromise<AnyObject?>.resolved(BatchUser.installationID() as NSString?)
            case .debug_showDebugView:
                showDebugView()
                return emptySuccessPromise()
            case .echo:
                //TODO: error
                return LightPromise<NSString?>.resolved(parameters["value"] as? NSString)
            default:
                return LightPromise<AnyObject?>.rejected(BridgeInternalError.notImplemented)
        }
    }
    
    /// Convinence method to get a promise resolved with nil
    private func emptySuccessPromise() -> LightPromise<AnyObject?> {
        return LightPromise<AnyObject?>.resolved(nil)
    }
}
