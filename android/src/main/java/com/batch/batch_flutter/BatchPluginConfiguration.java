package com.batch.batch_flutter;

import android.content.Context;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.batch.android.Config;

/**
 * Manages Batch configuration for the flutter plugin.
 * Configuration will be read from the manifest, but can be overridden at app launch.
 */
public class BatchPluginConfiguration {

    private static final String APIKEY_MANIFEST_KEY = "com.batch.flutter.apikey";
    private static final String GAID_MANIFEST_KEY = "com.batch.flutter.use_gaid";
    private static final String ADVANCED_INFO_MANIFEST_KEY = "com.batch.flutter.use_advanced_device_information";
    private static final String INITIAL_DND_STATE_MANIFEST_KEY = "com.batch.flutter.do_not_disturb_initial_state";

    private boolean didReadManifest = false;

    @Nullable
    private String apiKey;

    private boolean canUseAdvertisingID = true;

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
        canUseAdvertisingID = manifestReader.readBoolean(GAID_MANIFEST_KEY, true);
        canUseAdvancedDeviceInformation = manifestReader.readBoolean(ADVANCED_INFO_MANIFEST_KEY, true);
        canUseAdvancedDeviceInformation = manifestReader.readBoolean(INITIAL_DND_STATE_MANIFEST_KEY, false);
    }

    boolean hasAPIKey() {
        return !TextUtils.isEmpty(apiKey);
    }

    @Nullable
    Config makeBatchConfig() {
        if (!hasAPIKey()) {
            return null;
        }
        Config batchConfig = new Config(apiKey);
        batchConfig.setCanUseAdvancedDeviceInformation(canUseAdvancedDeviceInformation);
        batchConfig.setCanUseAdvertisingID(canUseAdvertisingID);
        return batchConfig;
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

    public boolean canUseAdvertisingID() {
        return canUseAdvertisingID;
    }

    public BatchPluginConfiguration setCanUseAdvertisingID(boolean canUseAdvertisingID) {
        this.canUseAdvertisingID = canUseAdvertisingID;
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
