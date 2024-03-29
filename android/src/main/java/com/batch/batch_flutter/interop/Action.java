package com.batch.batch_flutter.interop;

/**
 * Enum that wraps the supported action names.
 */
enum Action
{
    OPT_IN("optIn"),
    OPT_OUT("optOut"),
    OPT_OUT_AND_WIPE_DATA("optOutAndWipeData"),
    MESSAGING_SET_DO_NOT_DISTURB_ENABLED("messaging.setDoNotDisturbEnabled"),
    MESSAGING_SHOW_PENDING_MESSAGE("messaging.showPendingMessage"),
    PUSH_GET_LAST_KNOWN_TOKEN("push.getLastKnownPushToken"),
    PUSH_REQUEST_PERMISSION("push.requestPermission"),
    PUSH_IOS_REQUEST_PROVISIONAL_PERMISSION("push.iOS.requestProvisionalPermission"),
    PUSH_IOS_REFRESH_TOKEN("push.iOS.refreshToken"),
    PUSH_IOS_SET_SHOW_FOREGROUND("push.iOS.setShowForegroundNotifications"),
    PUSH_CLEAR_BADGE("push.clearBadge"),
    PUSH_DISMISS_NOTIFICATIONS("push.dismissNotifications"),
	USER_EDIT("user.edit"),
	USER_TRACK_EVENT("user.track.event"),
	USER_TRACK_TRANSACTION("user.track.transaction"),
    USER_TRACK_LOCATION("user.track.location"),
    USER_GET_IDENTIFIER("user.getIdentifier"),
    USER_GET_LANGUAGE("user.getLanguage"),
    USER_GET_REGION("user.getRegion"),
	USER_GET_INSTALLATION_ID("user.getInstallationID"),
    USER_FETCH_ATTRIBUTES("user.fetch.attributes"),
    USER_FETCH_TAGS("user.fetch.tags"),
    DEBUG_SHOW_DEBUG_VIEW("debug.showDebugView"),

    INBOX_CREATE_INSTALLATION_FETCHER("inbox.createInstallationFetcher"),
    INBOX_CREATE_USER_FETCHER("inbox.createUserFetcher"),
    INBOX_RELEASE_FETCHER("inbox.releaseFetcher"),
    INBOX_FETCH_NEW_NOTIFICATIONS("inbox.fetchNewNotifications"),
    INBOX_FETCH_NEXT_PAGE("inbox.fetchNextPage"),
    INBOX_GET_FETCHED_NOTIFICATIONS("inbox.getFetchedNotifications"),
    INBOX_MARK_AS_READ("inbox.markAsRead"),
    INBOX_MARK_ALL_AS_READ("inbox.markAllAsRead"),
    INBOX_MARK_AS_DELETED("inbox.markAsDeleted"),
    INBOX_DISPLAY_LANDING("inbox.displayLandingMessage"),

    /// For testing
    ECHO("echo");

    /**
     * Action name, the one passed as a paremeter in {@link com.batch.batch_flutter.interop.BatchBridge}
     */
    private String name;

    /**
     * Init an action with its string representation
     */
    private Action(String name)
    {
        this.name = name;
    }

    /**
     * Get the name associated with this action
     */
    public String getName()
    {
        return name;
    }

    /**
     * Create an Action from its string name.
     *
     * @throws IllegalArgumentException Thrown when the supplied name doesn't match any known action
     * @param actionName Action name
     * @return Action
     */
    public static Action fromName(String actionName) throws IllegalArgumentException
    {
        for (Action parameterValue : values())
        {
            if (parameterValue.getName().equalsIgnoreCase(actionName))
            {
                return parameterValue;
            }
        }

        throw new IllegalArgumentException("Unknown action.");
    }
}
