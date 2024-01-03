enum Action: String {
    case optIn = "optIn"
    case optOut = "optOut"
    case optOutAndWipeData = "optOutAndWipeData"
    
    case push_getLastKnownPushToken = "push.getLastKnownPushToken"
    case push_RequestPermission = "push.requestPermission"
    case push_iOSRequestProvisionalPermission = "push.iOS.requestProvisionalPermission"
    case push_iOSRefreshToken = "push.iOS.refreshToken"
    case push_clearBadge = "push.clearBadge"
    case push_dismissNotifications = "push.dismissNotifications"
    case push_iOSSetShowForegroundNotifications = "push.iOS.setShowForegroundNotifications"
    
    case user_getIdentifier = "user.getIdentifier"
    case user_getLanguage = "user.getLanguage"
    case user_getRegion = "user.getRegion"
    case user_getInstallationID = "user.getInstallationID"
    case user_fetchAttributes = "user.fetch.attributes"
    case user_fetchTags = "user.fetch.tags"
    case user_edit = "user.edit"
    case user_trackEvent = "user.track.event"
    case user_trackTransaction = "user.track.transaction"
    case user_trackLocation = "user.track.location"
    
    case inbox_createInstallationFetcher = "inbox.createInstallationFetcher"
    case inbox_createUserFetcher = "inbox.createUserFetcher"
    case inbox_releaseFetcher = "inbox.releaseFetcher"
    case inbox_fetchNewNotifications = "inbox.fetchNewNotifications"
    case inbox_fetchNextPage = "inbox.fetchNextPage"
    case inbox_getFetchedNotifications = "inbox.getFetchedNotifications"
    case inbox_markAsRead = "inbox.markAsRead"
    case inbox_markAllAsRead = "inbox.markAllAsRead"
    case inbox_markAsDeleted = "inbox.markAsDeleted"
    case inbox_displayLandingMessage = "inbox.displayLandingMessage"

    case messaging_setDoNotDisturbEnabled = "messaging.setDoNotDisturbEnabled"
    case messaging_showPendingMessage = "messaging.showPendingMessage"
    
    case debug_showDebugView = "debug.showDebugView"
    
    case echo = "echo"
}
