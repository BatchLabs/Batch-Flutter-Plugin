package com.batch.batch_flutter.interop;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

/**
 * Exception representing internal bridge errors
 */
public class BatchBridgeException extends Exception {
    @NonNull
    public final BatchBridgePublicErrorCode pluginCode;

    @NonNull
    public final String description;

    /**
     * Error details.
     * Must be serializable by {@link io.flutter.plugin.common.StandardMessageCodec}.
     */
    @Nullable
    public final Map<String, Object> details;

    /**
     * Create a Batch Bridge Exception
     * @param pluginCode batch_flutter error code
     * @param description Human readable error description
     */
    BatchBridgeException(@NonNull BatchBridgePublicErrorCode pluginCode, @NonNull String description) {
        super(pluginCode.code + ": " + description);
        this.pluginCode = pluginCode;
        this.description = description;
        this.details = null;
    }

    /**
     * Create a Batch Bridge Exception
     * @param pluginCode batch_flutter error code
     * @param description Human readable error description
     * @param details Optional error details. Must be serializable by {@link io.flutter.plugin.common.StandardMessageCodec}
     */
    BatchBridgeException(@NonNull BatchBridgePublicErrorCode pluginCode, @NonNull String description, @Nullable Map<String, Object> details) {
        super(pluginCode.code + ": " + description);
        this.pluginCode = pluginCode;
        this.description = description;
        this.details = details;
    }

    /**
     * Create a Batch Bridge Exception
     * @param pluginCode batch_flutter error code
     * @param description Human readable error description
     * @param details Optional error details. Must be serializable by {@link io.flutter.plugin.common.StandardMessageCodec}
     * @param source Source exception
     */
    BatchBridgeException(@NonNull BatchBridgePublicErrorCode pluginCode, @NonNull String description, @Nullable Map<String, Object> details, @Nullable Throwable source) {
        super(pluginCode.code + ": " + description, source);
        this.pluginCode = pluginCode;
        this.description = description;
        this.details = details;
    }
}
