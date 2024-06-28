package com.batch.batch_flutter;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.core.content.ContextCompat;

import com.batch.android.Batch;
import com.batch.batch_flutter.interop.BatchBridge;
import com.batch.batch_flutter.interop.BatchBridgeException;
import com.batch.batch_flutter.interop.BatchBridgeNotImplementedException;
import com.batch.batch_flutter.interop.BatchBridgePublicErrorCode;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/**
 * BatchFlutterPlugin
 */
public class BatchFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.NewIntentListener {

    private static final String PLUGIN_VERSION_SYSTEM_PROPERTY = "batch.plugin.version";

    private static final String PLUGIN_VERSION = "Flutter/1.4.0";

    private final static BatchPluginConfiguration configuration = new BatchPluginConfiguration();

    private static boolean didCallSetup = false;

    private static boolean manageActivityLifecycle = true;

    /// MethodChannels used to communicate with the plugin
    private MethodChannel coreChannel;
    private MethodChannel userChannel;
    private MethodChannel pushChannel;
    private MethodChannel inboxChannel;
    private MethodChannel messagingChannel;

    /// Current Activity
    @VisibleForTesting
    protected WeakReference<Activity> currentActivity = new WeakReference<>(null);

    static {
        System.setProperty(PLUGIN_VERSION_SYSTEM_PROPERTY, PLUGIN_VERSION);
    }

    @VisibleForTesting
    protected boolean isSetup() {
        return didCallSetup;
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        coreChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "batch_flutter");
        coreChannel.setMethodCallHandler(this);
        userChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "batch_flutter.user");
        userChannel.setMethodCallHandler(this);
        pushChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "batch_flutter.push");
        pushChannel.setMethodCallHandler(this);
        inboxChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "batch_flutter.inbox");
        inboxChannel.setMethodCallHandler(this);
        messagingChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "batch_flutter.messaging");
        messagingChannel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        coreChannel.setMethodCallHandler(null);
        userChannel.setMethodCallHandler(null);
        pushChannel.setMethodCallHandler(null);
        inboxChannel.setMethodCallHandler(null);
        messagingChannel.setMethodCallHandler(null);
    }

    //region Method calling

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (!isSetup()) {
            final String message = "batch_flutter's BatchFlutterPlugin.setup() has not been called." +
                    "Please make sure that you followed integration steps, and called this method " +
                    "in your Application subclass' onCreate().\n" +
                    "If you're still encountering an error, check that your application subclass" +
                    "is registered using 'android:name' on <application> in your AndroidManifest.xml.";
            BatchFlutterLogger.e(message);
            result.error(BatchBridgePublicErrorCode.MISSING_SETUP.code,
                    message,
                    null);
            return;
        }

        Activity activity = currentActivity.get();
        if (activity == null) {
            final String message = "batch_flutter isn't attached to an activity.";
            BatchFlutterLogger.e(message);
            result.error(BatchBridgePublicErrorCode.NOT_ATTACHED_TO_ACTIVITY.code,
                    message,
                    null);
            return;
        }

        Map<String, Object> arguments = null;
        if (call.arguments != null) {
            if (isObjectAMapOfStrings(call.arguments)) {
                try {
                    //noinspection unchecked
                    arguments = (Map<String, Object>) call.arguments;
                } catch (ClassCastException ignored) {
                }
            } else {
                final String message = "Bridge message root arguments were not null, but not" +
                        "of Map type. Got: '" + call.arguments.getClass().toString() + "'.";
                BatchFlutterLogger.e(message);
                result.error(BatchBridgePublicErrorCode.BAD_BRIDGE_ARGUMENT_TYPE.code,
                        message,
                        null);
                return;
            }
        }

        if (arguments == null) {
            arguments = new HashMap<>();
        }

        BatchBridge.call(call.method, arguments, activity)
                .setExecutor(ContextCompat.getMainExecutor(activity))
                .then(result::success)
                .catchException(e -> {
                    if (e instanceof BatchBridgeNotImplementedException) {
                        result.notImplemented();
                    } else if (e instanceof BatchBridgeException) {
                        BatchBridgeException bridgeException = (BatchBridgeException) e;
                        result.error(bridgeException.pluginCode.code, bridgeException.description, bridgeException.details);
                    } else {
                        BatchFlutterLogger.e("Unknown bridge error", e);
                        result.error(BatchBridgePublicErrorCode.UNKNOWN_BRIDGE_ERROR.code, "Unknown Batch native bridge error. Please see logcat for more info.", null);
                    }
                });
    }

    //endregion

    //region Activity awareness

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        attachToActivity(binding);
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        attachToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        detachFromActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        detachFromActivity();
    }

    @Override
    public boolean onNewIntent(Intent intent) {
        BatchFlutterLogger.d("Activity: onNewIntent");
        Activity activity = currentActivity.get();
        if (activity != null) {
            Batch.onNewIntent(activity, intent);
        }
        return false;
    }

    private void attachToActivity(@NonNull ActivityPluginBinding binding) {
        BatchFlutterLogger.d("Activity: attached. Should manage lifecycle: " + manageActivityLifecycle);
        if (manageActivityLifecycle) {
            binding.addOnNewIntentListener(this);
            Batch.onStart(binding.getActivity());
        }
        currentActivity = new WeakReference<>(binding.getActivity());
    }

    private void detachFromActivity() {
        BatchFlutterLogger.d("Activity: detached. Should manage lifecycle: " + manageActivityLifecycle);
        if (manageActivityLifecycle) {
            Activity activity = currentActivity.get();
            if (activity != null) {
                Batch.onStop(activity);
                Batch.onDestroy(activity);
            }
        }
    }

    //endregion

    //region Public API

    /**
     * Ready the plugin for use.
     * This MUST be called in an {@link android.app.Application} subclass' {@link Application#onCreate()}.
     * <p>
     * Once setup success fully, the configuration cannot be changed anymore
     * as this calls {@link com.batch.android.Batch#start(String)}
     * <p>
     * Note: If setup has never been called, or if Batch wasn't provided an APIKey in the manifest or
     * using {@link BatchFlutterPlugin#getConfiguration(Context)} and {@link BatchPluginConfiguration#setAPIKey(String)},
     * any method call will throw an exception.
     *
     * @return Whether the plugin was successfully setup. Returns true on any subsequent call if one
     * setup call succeeded.
     */
    public static synchronized boolean setup(@NonNull Context context) {
        if (didCallSetup) {
            BatchFlutterLogger.i("BatchFlutterPlugin.setup() has already been called once. Ignoring.");
            return true;
        }

        BatchPluginConfiguration pluginConfiguration = getConfiguration(context);
        if (pluginConfiguration.getApiKey() != null) {
            Batch.start(pluginConfiguration.getApiKey());
            Batch.Messaging.setDoNotDisturbEnabled(pluginConfiguration.getInitialDoNotDisturbState());
            didCallSetup = true;
            return true;
        } else {
            BatchFlutterLogger.e("Could not setup BatchFlutterPlugin: your configuration is " +
                    "invalid. Did you set a non-null APIKey using getConfiguration() or using manifest meta-data?");
            return false;
        }
    }

    /**
     * Get the plugin configuration object.
     * It will be initialized with the previous values, including what has been read from the manifest.
     * <p>
     * Once {@link BatchFlutterPlugin#setup(Context)} has been called, changing values in the returned
     * object will not have any effect.
     */
    public static BatchPluginConfiguration getConfiguration(@NonNull Context context) {
        //noinspection ConstantConditions
        if (context == null) {
            throw new IllegalArgumentException("Cannot call getConfiguration with a null context");
        }

        if (didCallSetup) {
            BatchFlutterLogger.i("BatchFlutterPlugin.setup() has already been called. Any " +
                    "configuration change won't be applied, as they all must be " +
                    "done before calling this method.");
        }

        // Ensure that we read the default values from the manifest before any custom one is set
        // as this can be called before "onAttachedToEngine"
        configuration.initFromManifest(context);
        return configuration;
    }

    /**
     * Set whether BatchFlutterPlugin should automatically manage Batch's activity lifecycle
     * (as in automatically calling {@link Batch#onStart(Activity)} and so on).
     * <p>
     * If you add batch_flutter in a hybrid application (one that mixes native android activities with
     * flutter ones), you should turn this off and register {@link com.batch.android.BatchActivityLifecycleHelper}
     * in your {@link Application} subclass.
     */
    public static void setManageActivityLifecycle(boolean manageActivityLifecycle) {
        BatchFlutterPlugin.manageActivityLifecycle = manageActivityLifecycle;
    }

    //endregion

    private boolean isObjectAMapOfStrings(Object object) {
        if (!(object instanceof Map<?, ?>)) {
            return false;
        }

        Map<?, ?> map = (Map<?, ?>) object;

        for (Object key : map.keySet()) {
            if (!(key instanceof String)) {
                return false;
            }
        }

        return true;
    }
}
