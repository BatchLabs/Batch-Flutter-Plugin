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
        
        return doAction(action, parameters: parameters)
    }
    
    // Bool is a temporary return value
func doAction(_ action: Action, parameters: [String: AnyObject]) -> Any? {
        switch action {
            case .push_iOSRefreshToken:
                BatchPush.refreshToken()
                return nil
            case .push_iOSRequestPermission:
                //TODO add provisional notif (and on android too)
                BatchPush.requestNotificationAuthorization()
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
                return BatchPush.lastKnownPushToken
            case .user_getInstallationID:
                return BatchUser.installationID
            case .echo:
                //TODO: error
                return parameters["value"] as? String
            default:
                return FlutterMethodNotImplemented
        }
    }
}
