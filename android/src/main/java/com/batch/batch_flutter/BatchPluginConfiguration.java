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
    private static final String PROFILE_CUSTOM_ID_MIGRATION_ENABLED_MANIFEST_KEY = "com.batch.flutter.profile_custom_id_migration_enabled";
    private static final String PROFILE_CUSTOM_DATA_MIGRATION_ENABLED_MANIFEST_KEY = "com.batch.flutter.profile_custom_data_migration_enabled";
    private static final String INITIAL_DND_STATE_MANIFEST_KEY = "com.batch.flutter.do_not_disturb_initial_state";

    private boolean didReadManifest = false;

    @Nullable
    private String apiKey;
    private boolean initialDoNotDisturbState = false;
    private boolean profileCustomIdMigrationEnabled = true;
    private boolean profileCustomDataMigrationEnabled = true;

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
        initialDoNotDisturbState = manifestReader.readBoolean(INITIAL_DND_STATE_MANIFEST_KEY, false);
        profileCustomIdMigrationEnabled =  manifestReader.readBoolean(PROFILE_CUSTOM_ID_MIGRATION_ENABLED_MANIFEST_KEY, true);
        profileCustomDataMigrationEnabled =  manifestReader.readBoolean(PROFILE_CUSTOM_DATA_MIGRATION_ENABLED_MANIFEST_KEY, true);
    }
    //region Public API

    /**
     * Get the API key.
     *
     * @return The API key.
     */
    @Nullable
    public String getApiKey() {
        return apiKey;
    }

    /**
     * Set the API key.
     *
     * @param apiKey The API key.
     * @return This BatchPluginConfiguration instance for method chaining.
     */
    public BatchPluginConfiguration setAPIKey(@Nullable String apiKey) {
        this.apiKey = apiKey;
        return this;
    }

    /**
     * Get the initial do not disturb state.
     *
     * @return The initial do not disturb state.
     */
    public boolean getInitialDoNotDisturbState() {
        return initialDoNotDisturbState;
    }

    /**
     * Set the initial do not disturb state.
     *
     * @param initialDoNotDisturbState The initial do not disturb state.
     * @return This BatchPluginConfiguration instance for method chaining.
     */
    public BatchPluginConfiguration setInitialDoNotDisturbState(boolean initialDoNotDisturbState) {
        this.initialDoNotDisturbState = initialDoNotDisturbState;
        return this;
    }

    /**
     * Whether custom id migration is enabled or not.
     */
    public boolean isProfileCustomIdMigrationEnabled() {
        return profileCustomIdMigrationEnabled;
    }

    /**
     * Whether Batch should automatically identify logged-in user when running the SDK for the first time.
     * <p>
     * This mean user with a custom_user_id will be automatically attached a to a Profile and could be targeted within a Project scope.
     * @param profileCustomIdMigrationEnabled whether custom id migration is enabled or not.
     * @return This BatchPluginConfiguration instance for method chaining.
     */
    public BatchPluginConfiguration setProfileCustomIdMigrationEnabled(boolean profileCustomIdMigrationEnabled) {
        this.profileCustomIdMigrationEnabled = profileCustomIdMigrationEnabled;
        return this;
    }

    /**
     * Whether custom data migration is enabled or not.
     */
    public boolean isProfileCustomDataMigrationEnabled() {
        return profileCustomDataMigrationEnabled;
    }

    /**
     *  Set whether Batch should automatically attach current installation's data (language/region/customDataAttributes...)
     *  to the User's Profile when running the SDK for the first time.
     *
     * @param profileCustomDataMigrationEnabled whether custom data migration is enabled or not.
     * @return This BatchPluginConfiguration instance for method chaining.
     */
    public BatchPluginConfiguration setProfileCustomDataMigrationEnabled(boolean profileCustomDataMigrationEnabled) {
        this.profileCustomDataMigrationEnabled = profileCustomDataMigrationEnabled;
        return this;
    }
    //endregion
}
