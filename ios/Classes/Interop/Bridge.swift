import Foundation
import Batch
import Flutter

struct Bridge {
    // Bool is a temporary return value
    func call(rawAction: String, parameters: [String: AnyObject]) -> Any? {
        guard let action = Action.init(rawValue: rawAction) else {
            //TODO: better exception handling
            print("Invalid action name \(rawAction)")
            return FlutterMethodNotImplemented
        }
        
        return doAction(action, parameters: parameters) as AnyObject?
    }
    
    // Bool is a temporary return value
    func doAction(_ action: Action, parameters: [String: AnyObject]) -> Any? {
        switch action {
            case .push_iOSRefreshToken:
                BatchPush.refreshToken()
                return nil
            case .push_iOSRequestPermission:
                BatchPush.requestNotificationAuthorization()
                return nil
            case .push_iOSRequestProvisionalPermission:
                BatchPush.requestProvisionalNotificationAuthorization()
                return nil
            case .push_dismissNotifications:
                BatchPush.dismissNotifications()
                return nil
            case .push_clearBadge:
                BatchPush.clearBadge()
                return nil
            case .push_iOSSetShowForegroundNotifications:
                //TODO
                return nil
            case .push_getLastKnownPushToken:
                return BatchPush.lastKnownPushToken() as NSString?
            case .user_getInstallationID:
                return BatchUser.installationID() as NSString?
            case .echo:
                //TODO: error
                return parameters["value"] as? NSString
            default:
                return FlutterMethodNotImplemented
        }
    }
}
