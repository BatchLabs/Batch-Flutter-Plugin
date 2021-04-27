enum Action: String {
    case optIn = "optIn"
    case optOut = "optOut"
    case optOutAndWipeData = "optOutAndWipeData"
    
    case push_getLastKnownPushToken = "push.getLastKnownPushToken"
    case push_iOSRequestPermission = "push.iOS.requestPermission"
    case push_iOSRequestProvisionalPermission = "push.iOS.requestProvisionalPermission"
    case push_iOSRefreshToken = "push.iOS.refreshToken"
    case push_clearBadge = "push.clearBadge"
    case push_dismissNotifications = "push.dismissNotifications"
    case push_iOSSetShowForegroundNotifications = "push.setIOSShowForegroundNotifications"
    
    case user_getIdentifier = "user.getIdentifier"
    case user_getLanguage = "user.getLanguage"
    case user_getRegion = "user.getRegion"
    case user_getInstallationID = "user.getInstallationID"
    
    case debug_showDebugView = "debug.showDebugView"
    
    case echo = "echo"
}
