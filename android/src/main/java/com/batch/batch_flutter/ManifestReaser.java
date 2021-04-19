package com.batch.batch_flutter;

import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * Simple manifest reader
 */
class ManifestReader {
    @NonNull
    private final Context context;

    ManifestReader(@NonNull Context context) {
        this.context = context.getApplicationContext();
    }

    @Nullable
    String readString(@NonNull String key, @Nullable String fallback) {
        final Bundle metadata = readMetadata();
        if (metadata == null) {
            return fallback;
        }
        return metadata.getString(key, fallback);
    }

    boolean readBoolean(@NonNull String key, boolean fallback)
    {
        final Bundle metadata = readMetadata();
        if (metadata == null) {
            return fallback;
        }
        return metadata.getBoolean(key, fallback);
    }

    @Nullable
    private Bundle readMetadata() {
        try {
            return context
                    .getPackageManager()
                    .getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA)
                    .metaData;
        } catch (PackageManager.NameNotFoundException e) {
            return null;
        }
    }
}
