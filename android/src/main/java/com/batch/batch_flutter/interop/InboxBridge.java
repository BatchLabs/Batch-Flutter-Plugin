package com.batch.batch_flutter.interop;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import com.batch.android.Batch;
import com.batch.android.BatchInboxFetcher;
import com.batch.android.BatchInboxNotificationContent;
import com.batch.batch_flutter.BatchFlutterLogger;
import com.batch.batch_flutter.Promise;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import static com.batch.batch_flutter.interop.BatchBridgeUtils.getOptionalTypedParameter;
import static com.batch.batch_flutter.interop.BatchBridgeUtils.getTypedParameter;

/**
 * The InboxBridge's job is to retain {@link com.batch.android.BatchInboxFetcher} instances
 * based on an ID, so that the bridged plugin can access retained instances of the fetcher to use.
 * It will also handle calls and dispatch them to the appropriate fetcher, handling all inbox
 * related calls.
 *
 * This can lead to memory leaks if the memory isn't freed, as this object will retain instances
 * indefinitely. Make sure to expose a method on the plugin side to tell this class to release a
 * fetcher.
 */
class InboxBridge {
    Map<String, BatchInboxFetcher> fetchers = new ConcurrentHashMap<>();

    @NonNull
    Promise<Object> doAction(@NonNull Action action, @NonNull Map<String, Object> parameters, @NonNull Activity activity) throws BatchBridgeException, BatchBridgeNotImplementedException {
        switch (action) {
            case INBOX_CREATE_INSTALLATION_FETCHER:
                return Promise.resolved(createInstallationFetcher(activity, parameters));
            case INBOX_CREATE_USER_FETCHER:
                return Promise.resolved(createUserFetcher(activity, parameters));
            case INBOX_RELEASE_FETCHER:
                releaseFetcher(parameters);
                return Promise.resolved(null);
            case INBOX_FETCH_NEW_NOTIFICATIONS:
                return fetchNewNotifications(parameters);
            case INBOX_FETCH_NEXT_PAGE:
                return fetchNextPage(parameters);
            case INBOX_GET_FETCHED_NOTIFICATIONS:
                return getFetchedNotifications(parameters);
            case INBOX_MARK_AS_READ:
                return markAsRead(parameters);
            case INBOX_MARK_ALL_AS_READ:
                return markAllAsRead(parameters);
            case INBOX_MARK_AS_DELETED:
                return markAsDeleted(parameters);
            case INBOX_DISPLAY_LANDING:
                return displayLandingMessage(activity, parameters);
            default:
                throw new BatchBridgeNotImplementedException(action.toString());
        }
    }

    @NonNull
    private String createInstallationFetcher(@NonNull Context context, @NonNull Map<String, Object> parameters) {
        String id = makeFetcherID();
        BatchInboxFetcher fetcher = Batch.Inbox.getFetcher(context.getApplicationContext());
        configureSharedFetcherParameters(fetcher, parameters);
        fetchers.put(id, fetcher);
        return id;
    }

    @NonNull
    private String createUserFetcher(@NonNull Context context, @NonNull Map<String, Object> parameters) throws BatchBridgeException {
        String id = makeFetcherID();
        String user = getTypedParameter(parameters, "user", String.class);
        String authKey = getTypedParameter(parameters, "authKey", String.class);
        BatchInboxFetcher fetcher = Batch.Inbox.getFetcher(context.getApplicationContext(), user, authKey);
        configureSharedFetcherParameters(fetcher, parameters);
        fetchers.put(id, fetcher);
        return id;
    }

    private void configureSharedFetcherParameters(@NonNull BatchInboxFetcher fetcher, @NonNull Map<String, Object> parameters) {
        Number maxPageSize = getOptionalTypedParameter(parameters, "maxPageSize", Number.class, null);
        Number limit = getOptionalTypedParameter(parameters, "limit", Number.class, null);

        if (maxPageSize != null) {
            int maxPageSizeInt = maxPageSize.intValue();
            if (maxPageSizeInt > 0) {
                fetcher.setMaxPageSize(maxPageSizeInt);
            }
        }

        if (limit != null) {
            int limitInt = limit.intValue();
            if (limitInt > 0) {
                fetcher.setFetchLimit(limitInt);
            }
        }
    }

    private void releaseFetcher(@NonNull Map<String, Object> parameters) throws BatchBridgeException {
        fetchers.remove(getTypedParameter(parameters, "fetcherID", String.class));
    }

    @NonNull
    private String makeFetcherID() {
        return UUID.randomUUID().toString();
    }

    @NonNull
    private BatchInboxFetcher getFetcherInstance(@NonNull Map<String, Object> parameters) throws BatchBridgeException {
        BatchInboxFetcher fetcher = fetchers.get(getTypedParameter(parameters, "fetcherID", String.class));

        if (fetcher == null) {
            throw new BatchBridgeException(BatchBridgePublicErrorCode.INBOX_MISSING_NATIVE_FETCHER,
                    "The native inbox fetcher backing this object could not be found." +
                            "Did you call 'dispose()' on this BatchInboxFetcher and attempted to use it afterwards?",
                    null);
        }

        return fetcher;
    }

    private Promise<Object> fetchNewNotifications(@NonNull Map<String, Object> parameters) throws BatchBridgeException {
        final BatchInboxFetcher fetcher = getFetcherInstance(parameters);

        return new Promise<>(promise -> fetcher.fetchNewNotifications(new BatchInboxFetcher.OnNewNotificationsFetchedListener() {
            @Override
            public void onFetchSuccess(@NonNull List<BatchInboxNotificationContent> list, boolean foundNewNotifications, boolean endReached) {
                Map<String, Object> response = new HashMap<>();
                response.put("foundNew", foundNewNotifications);
                response.put("endReached", endReached);
                response.put("notifications", serializeNotificationsForBridge(list));
                promise.resolve(response);
            }

            @Override
            public void onFetchFailure(@NonNull String s) {
                promise.reject(new BatchBridgeException(BatchBridgePublicErrorCode.INTERNAL_SDK_ERROR,
                        "Inbox fetchNewNotifications failed with error: " + s));
            }
        }));
    }

    private Promise<Object> fetchNextPage(@NonNull Map<String, Object> parameters) throws BatchBridgeException {
        final BatchInboxFetcher fetcher = getFetcherInstance(parameters);

        return new Promise<>(promise -> fetcher.fetchNextPage(new BatchInboxFetcher.OnNextPageFetchedListener() {
            @Override
            public void onFetchSuccess(@NonNull List<BatchInboxNotificationContent> list, boolean endReached) {
                Map<String, Object> response = new HashMap<>();
                response.put("endReached", endReached);
                response.put("notifications", serializeNotificationsForBridge(list));
                promise.resolve(response);
            }

            @Override
            public void onFetchFailure(@NonNull String s) {
                promise.reject(new BatchBridgeException(BatchBridgePublicErrorCode.INTERNAL_SDK_ERROR,
                        "Inbox fetchNextPage failed with error: " + s));
            }
        }));
    }

    private Promise<Object> markAsRead(@NonNull Map<String, Object> parameters) throws BatchBridgeException {
        final BatchInboxFetcher fetcher = getFetcherInstance(parameters);

        final String notificationID = getTypedParameter(parameters, "notifID", String.class);

        return new Promise<>(promise -> {
            List<BatchInboxNotificationContent> nativeNotifications = fetcher.getFetchedNotifications();
            BatchInboxNotificationContent notificationToMark = null;
            for (BatchInboxNotificationContent nativeNotification : nativeNotifications) {
                if (nativeNotification.getNotificationIdentifier().equals(notificationID)) {
                    notificationToMark = nativeNotification;
                    break;
                }
            }

            if (notificationToMark != null) {
                fetcher.markAsRead(notificationToMark);
            } else {
                BatchFlutterLogger.e("Could not mark notification as read: No matching native notification. This can happen if you kept a Dart instance of a notification but are trying to use it with another fetcher, or if the fetcher has been reset inbetween.");
            }

            promise.resolve(null);
        });
    }

    private Promise<Object> markAllAsRead(@NonNull Map<String, Object> parameters) throws BatchBridgeException {
        final BatchInboxFetcher fetcher = getFetcherInstance(parameters);

        fetcher.markAllAsRead();

        return Promise.resolved(null);
    }

    private Promise<Object> markAsDeleted(@NonNull Map<String, Object> parameters) throws BatchBridgeException {
        final BatchInboxFetcher fetcher = getFetcherInstance(parameters);

        final String notificationID = getTypedParameter(parameters, "notifID", String.class);

        return new Promise<>(promise -> {
            List<BatchInboxNotificationContent> nativeNotifications = fetcher.getFetchedNotifications();
            BatchInboxNotificationContent notificationToMark = null;
            for (BatchInboxNotificationContent nativeNotification : nativeNotifications) {
                if (nativeNotification.getNotificationIdentifier().equals(notificationID)) {
                    notificationToMark = nativeNotification;
                    break;
                }
            }

            if (notificationToMark != null) {
                fetcher.markAsDeleted(notificationToMark);
            } else {
                BatchFlutterLogger.e("Could not mark notification as deleted: No matching native notification. This can happen if you kept a Dart instance of a notification but are trying to use it with another fetcher, or if the fetcher has been reset inbetween.");
            }

            promise.resolve(null);
        });
    }
    private Promise<Object> displayLandingMessage(@NonNull Context context, @NonNull Map<String, Object> parameters) throws BatchBridgeException {
        final BatchInboxFetcher fetcher = getFetcherInstance(parameters);

        final String notificationID = getTypedParameter(parameters, "notifID", String.class);

        return new Promise<>(promise -> {
            List<BatchInboxNotificationContent> nativeNotifications = fetcher.getFetchedNotifications();
            BatchInboxNotificationContent notificationToDisplay = null;
            for (BatchInboxNotificationContent nativeNotification : nativeNotifications) {
                if (nativeNotification.getNotificationIdentifier().equals(notificationID)) {
                    notificationToDisplay = nativeNotification;
                    break;
                }
            }

            if (notificationToDisplay != null) {
                notificationToDisplay.displayLandingMessage(context);
            } else {
                BatchFlutterLogger.e("Could not display the landing message: No matching native notification. This can happen if you kept a Dart instance of a notification but are trying to use it with another fetcher, or if the fetcher has been reset inbetween.");
            }
            promise.resolve(null);
        });
    }

    private Promise<Object> getFetchedNotifications(@NonNull Map<String, Object> parameters) throws BatchBridgeException {
        final BatchInboxFetcher fetcher = getFetcherInstance(parameters);

        Map<String, Object> response = new HashMap<>();
        response.put("notifications", serializeNotificationsForBridge(fetcher.getFetchedNotifications()));
        return Promise.resolved(response);
    }

    @NonNull
    private List<Map<String, Object>> serializeNotificationsForBridge(@NonNull List<BatchInboxNotificationContent> nativeNotifications) {
        List<Map<String, Object>> serializedNotifications = new ArrayList<>(nativeNotifications.size());

        for (BatchInboxNotificationContent nativeNotification : nativeNotifications) {
            //TODO: implement support for silent notifications
            if (nativeNotification.isSilent()) {
                continue;
            }
            Map<String, Object> serializedNotification = new HashMap<>();
            serializedNotification.put("id", nativeNotification.getNotificationIdentifier());

            serializedNotification.put("body", nativeNotification.getBody());
            final String title = nativeNotification.getTitle();
            if (title != null) {
                serializedNotification.put("title", title);
            }

            serializedNotification.put("isUnread", nativeNotification.isUnread());
            serializedNotification.put("date", nativeNotification.getDate().getTime());
            int source = 0; // UNKNOWN
            switch (nativeNotification.getSource()) {
                case CAMPAIGN:
                    source = 1;
                    break;
                case TRANSACTIONAL:
                    source = 2;
                    break;
                case TRIGGER:
                    source = 3;
                    break;
            }
            serializedNotification.put("source", source);
            serializedNotification.put("payload", nativeNotification.getRawPayload());
            serializedNotification.put("hasLandingMessage", nativeNotification.hasLandingMessage());
            serializedNotifications.add(serializedNotification);
        }

        return serializedNotifications;
    }
}
