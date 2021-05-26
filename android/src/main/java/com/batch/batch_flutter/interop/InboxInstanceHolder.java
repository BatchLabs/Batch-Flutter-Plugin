package com.batch.batch_flutter.interop;

import android.app.Activity;

import androidx.annotation.NonNull;

import com.batch.android.BatchInboxFetcher;
import com.batch.batch_flutter.Promise;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

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
    Promise<Object> doAction(String actionName, Map<String, Object> parameters, Activity activity) throws BatchBridgeException, BatchBridgeNotImplementedException {
    }

    private createInstallationFetcher() {
        UUID uuid = nwe U
    }
}
