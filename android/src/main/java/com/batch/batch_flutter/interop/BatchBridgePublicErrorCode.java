package com.batch.batch_flutter.interop;

/**
 * Describes flutter error codes.
 * All Android specific error codes start with "android_".
 */
public enum BatchBridgePublicErrorCode {

    UNKNOWN_BRIDGE_ERROR("unknownBridgeError"),
    INTERNAL_BRIDGE_ERROR("internalBridgeError"),
    INTERNAL_SDK_ERROR("internalSDKError"),
    BAD_BRIDGE_ARGUMENT_TYPE("badBridgeArgumentType"),
    MISSING_SETUP("missingSetup"),
    NOT_ATTACHED_TO_ACTIVITY("android_notAttachedToActivity"),
    INBOX_MISSING_NATIVE_FETCHER("inboxNoNativeFetcher");

    public final String code;

    /**
     * Init an action with its string representation
     */
    BatchBridgePublicErrorCode(String code) {
        this.code = code;
    }
}
