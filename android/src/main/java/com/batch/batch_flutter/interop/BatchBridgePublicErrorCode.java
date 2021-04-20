package com.batch.batch_flutter.interop;

/**
 * Describes flutter error codes.
 * All Android specific error codes start with "android_".
 */
public enum BatchBridgePublicErrorCode {

    UNKNOWN_BRIDGE_ERROR("unknownBridgeError"),
    INTERNAL_BRIDGE_ERROR("internalBridgeError"),
    NOT_ATTACHED_TO_ACTIVITY("android_notAttachedToActivity");

    public final String code;

    /**
     * Init an action with its string representation
     */
    BatchBridgePublicErrorCode(String code) {
        this.code = code;
    }
}
