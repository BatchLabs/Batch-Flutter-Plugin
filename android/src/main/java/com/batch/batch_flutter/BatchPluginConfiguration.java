package com.batch.batch_flutter;

import android.content.Context;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;


/**
 * Manages Batch configuration for the flutter plugin.
 * Configuration will be read from the manifest, but can be overridden at app launch.
 */
public class BatchPluginConfiguration {

    private static final String APIKEY_MANIFEST_KEY = "com.batch.flutter.apikey";
    private static final String ADVANCED_INFO_MANIFEST_KEY = "com.batch.flutter.use_advanced_device_information";
    private static final String INITIAL_DND_STATE_MANIFEST_KEY = "com.batch.flutter.do_not_disturb_initial_state";

    private boolean didReadManifest = false;

    @Nullable
    private String apiKey;

    private boolean canUseAdvancedDeviceInformation = true;

    private boolean initialDoNotDisturbState = false;

    synchronized void initFromManifest(@NonNull Context context) {
        //noinspection ConstantConditions
        if (context == null) {
            return;
        }
        if (didReadManifest) {
            return;
        }
        didReadManifest = true;

        final ManifestReader manifestReader = new ManifestReader(context);
        apiKey = manifestReader.readString(APIKEY_MANIFEST_KEY, null);
        canUseAdvancedDeviceInformation = manifestReader.readBoolean(ADVANCED_INFO_MANIFEST_KEY, true);
        initialDoNotDisturbState = manifestReader.readBoolean(INITIAL_DND_STATE_MANIFEST_KEY, false);
    }
    //region Public API

    @Nullable
    public String getApiKey() {
        return apiKey;
    }

    public BatchPluginConfiguration setAPIKey(@Nullable String apiKey) {
        this.apiKey = apiKey;
        return this;
    }

    /**
     * Can Batch use Advertising ID
     * Batch doesn't collects Android Advertising Identifier anymore.
     *
     * @deprecated This method does nothing, please stop using it.
     * @return Always return false.
     */
    @Deprecated
    public boolean canUseAdvertisingID() {
        return false;
    }

    /**
     * Batch doesn't support Android Advertising Identifier anymore.
     *
     * @param canUseAdvertisingID This parameter does nothing.
     * @deprecated This method does nothing, please stop using it.
     */
    @Deprecated
    public BatchPluginConfiguration setCanUseAdvertisingID(boolean canUseAdvertisingID) {
        return this;
    }

    public boolean canUseAdvancedDeviceInformation() {
        return canUseAdvancedDeviceInformation;
    }

    public BatchPluginConfiguration setCanUseAdvancedDeviceInformation(boolean canUseAdvancedDeviceInformation) {
        this.canUseAdvancedDeviceInformation = canUseAdvancedDeviceInformation;
        return this;
    }

    public boolean getInitialDoNotDisturbState() {
        return initialDoNotDisturbState;
    }

    public BatchPluginConfiguration setInitialDoNotDisturbState(boolean initialDoNotDisturbState) {
        this.initialDoNotDisturbState = initialDoNotDisturbState;
        return this;
    }

    //endregion
}
