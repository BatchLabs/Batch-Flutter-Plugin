package com.batch.batch_flutter.interop;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import com.batch.android.Batch;
import com.batch.android.BatchInboxFetcher;
import com.batch.android.BatchInboxNotificationContent;
import com.batch.batch_flutter.Promise;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import static com.batch.batch_flutter.interop.BatchBridge.getTypedParameter;

/**
 * The InboxInstanceHolder's job is to retain {@link com.batch.android.BatchInboxFetcher} instances
 * based on an ID, so that the bridged plugin can access retained instances of the fetcher to use
 *
 * This can lead to memory leaks if the memory isn't freed, as this object will retain instances
 * indefinitely. Make sure to expose a method on the plugin side to tell this class to release a
 * fetcher.
 */
class InboxInstanceHolder {
    Map<String, BatchInboxFetcher> fetchers = new ConcurrentHashMap<>();

    @NonNull
    Promise<Object> doAction(@NonNull Action action, @NonNull Map<String, Object> parameters, @NonNull Activity activity) throws BatchBridgeException, BatchBridgeNotImplementedException {
        switch (action) {
            case INBOX_CREATE_INSTALLATION_FETCHER:
                return Promise.resolved(createInstallationFetcher(activity));
            case INBOX_CREATE_USER_FETCHER:
                return Promise.resolved(createUserFetcher(activity, parameters));
            case INBOX_RELEASE_FETCHER:
                releaseFetcher(parameters);
                return Promise.resolved(null);
            default:
                throw new BatchBridgeNotImplementedException(action.toString());
        }
    }

    @NonNull
    private String createInstallationFetcher(@NonNull Context context) {
        String id = makeFetcherID();
        BatchInboxFetcher fetcher = Batch.Inbox.getFetcher(context.getApplicationContext());
        fetchers.put(id, fetcher);
        return id;
    }

    @NonNull
    private String createUserFetcher(@NonNull Context context, @NonNull Map<String, Object> parameters) throws BatchBridgeException {
        String id = makeFetcherID();
        String user = getTypedParameter(parameters, "user", String.class);
        String authKey = getTypedParameter(parameters, "authKey", String.class);
        BatchInboxFetcher fetcher = Batch.Inbox.getFetcher(context.getApplicationContext(), user, authKey);
        fetchers.put(id, fetcher);
        return id;
    }

    private void releaseFetcher(@NonNull Map<String, Object> parameters) throws BatchBridgeException {
        fetchers.remove(getTypedParameter(parameters, "id", String.class));
    }

    @NonNull
    private String makeFetcherID() {
        return UUID.randomUUID().toString();
    }

    @NonNull
    private BatchInboxFetcher getFetcherInstance(@NonNull Map<String, Object> parameters) throws BatchBridgeException {
        BatchInboxFetcher fetcher = fetchers.get(getTypedParameter(parameters, "id", String.class));

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
            public void onFetchSuccess(@NonNull List<BatchInboxNotificationContent> list, boolean b, boolean b1) {
                promise.resolve();
            }

            @Override
            public void onFetchFailure(@NonNull String s) {
                promise.reject(new BatchBridgeException(BatchBridgePublicErrorCode.INTERNAL_SDK_ERROR,
                        "Inbox fetch failed with error: " + s));
            }
        }));
    }
}
