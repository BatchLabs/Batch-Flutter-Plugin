package com.batch.batch_flutter;

import android.util.Log;

import androidx.annotation.NonNull;

/**
 * Internal SDK class for logging Plugin related messages
 */
public class BatchFlutterLogger {

    static boolean enableDebugLogs = true;

    private static final String TAG = "BatchFlutter";

    static void d(@NonNull String message) {
        if (!enableDebugLogs) {
            return;
        }
        Log.d(TAG, message);
    }

    static void d(@NonNull String message, @NonNull Throwable t) {
        if (!enableDebugLogs) {
            return;
        }
        Log.d(TAG, message, t);
    }

    static void i(@NonNull String message) {
        Log.v(TAG, message);
    }

    static void e(@NonNull String message) {
        Log.e(TAG, message);
    }

    static void e(@NonNull String message, @NonNull Throwable t) {
        Log.e(TAG, message, t);
    }
}
