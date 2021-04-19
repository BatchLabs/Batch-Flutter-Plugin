package com.batch.batch_flutter;

import androidx.annotation.Nullable;

import com.batch.android.Config;

/**
 * Manages static Batch configuration for the flutter plugin.
 * Configuration will be read from the manifest, but can be overridden at app launch.
 */
class PluginConfiguration {

    private static String APIKEY_MANIFEST_KEY = "com.batch.flutter.apikey";
    private static String GAID_MANIFEST_KEY = "com.batch.flutter.use_gaid";
    private static String ADVANCED_INFO_MANIFEST_KEY = "com.batch.flutter.use_advanced_device_information";

    @Nullable
    private String apiKey;

    private boolean canUseAdvertisingID = true;

    private boolean canUseAdvancedDeviceInformation = true;

    private void readFromManifest() {

    }

    Config makeBatchConfig() {
        Config batchConfig = new Config("");
        batchConfig.setCanUseAdvancedDeviceInformation(canUseAdvancedDeviceInformation);
        batchConfig.setCanUseAdvertisingID(canUseAdvertisingID);
        return batchConfig;
    }
}
