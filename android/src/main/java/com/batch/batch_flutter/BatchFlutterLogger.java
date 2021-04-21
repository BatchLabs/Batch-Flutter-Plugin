package com.batch.batch_flutter;

import android.util.Log;

import androidx.annotation.NonNull;

/**
 * Internal SDK class for logging Plugin related messages
 */
public class BatchFlutterLogger {

    static boolean enableDebugLogs = true;

    private static final String TAG = "BatchFlutter";

    public static void d(@NonNull String message) {
        if (!enableDebugLogs) {
            return;
        }
        Log.d(TAG, message);
    }

    public static void d(@NonNull String message, @NonNull Throwable t) {
        if (!enableDebugLogs) {
            return;
        }
        Log.d(TAG, message, t);
    }

    public static void i(@NonNull String message) {
        Log.v(TAG, message);
    }

    public static void e(@NonNull String message) {
        Log.e(TAG, message);
    }

    public static void e(@NonNull String message, @NonNull Throwable t) {
        Log.e(TAG, message, t);
    }
}
