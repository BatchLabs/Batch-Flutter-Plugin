package com.batch.batch_flutter;

import androidx.test.core.app.ActivityScenario;
import androidx.test.ext.junit.rules.ActivityScenarioRule;
import androidx.test.ext.junit.runners.AndroidJUnit4;

import com.batch.batch_flutter.interop.BatchBridgePublicErrorCode;
import com.batch.batch_flutter.testutils.ObservableFlutterResult;

import org.junit.Assert;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.annotation.LooperMode;

import java.lang.ref.WeakReference;

import io.flutter.plugin.common.MethodCall;

import static android.os.Looper.getMainLooper;
import static org.robolectric.Shadows.shadowOf;

@RunWith(AndroidJUnit4.class)
@LooperMode(LooperMode.Mode.PAUSED)
public class BatchFlutterPluginTest {
    @Rule
    public ActivityScenarioRule<TestActivity> rule = new ActivityScenarioRule<>(TestActivity.class);

    @Test
    public void testSetupErrors() {
        ActivityScenario<TestActivity> scenario = rule.getScenario();

        scenario.onActivity((activity) -> {
            Assert.assertNotNull(activity);

            ControllableBatchFlutterPlugin plugin = new ControllableBatchFlutterPlugin();
            plugin.didCallSetupOverride = false;
            plugin.currentActivity = new WeakReference<>(null);

            ObservableFlutterResult didNotSetupResult = new ObservableFlutterResult();
            plugin.onMethodCall(new MethodCall("user.getLanguage", null), didNotSetupResult);

            plugin.didCallSetupOverride = true;

            ObservableFlutterResult noActivityResult = new ObservableFlutterResult();
            plugin.onMethodCall(new MethodCall("user.getLanguage", null), noActivityResult);

            shadowOf(getMainLooper()).idle();

            Assert.assertFalse(didNotSetupResult.didCallNotImplemented);
            Assert.assertTrue(didNotSetupResult.didCallError);
            Assert.assertFalse(didNotSetupResult.didCallSuccess);
            Assert.assertEquals(BatchBridgePublicErrorCode.MISSING_SETUP.code, didNotSetupResult.lastErrorArguments.errorCode);

            Assert.assertFalse(noActivityResult.didCallNotImplemented);
            Assert.assertTrue(noActivityResult.didCallError);
            Assert.assertFalse(noActivityResult.didCallSuccess);
            Assert.assertEquals(BatchBridgePublicErrorCode.NOT_ATTACHED_TO_ACTIVITY.code, noActivityResult.lastErrorArguments.errorCode);
        });
    }

    @Test
    public void testBridgeErrors() {
        ActivityScenario<TestActivity> scenario = rule.getScenario();

        scenario.onActivity((activity) -> {
            Assert.assertNotNull(activity);

            ControllableBatchFlutterPlugin plugin = new ControllableBatchFlutterPlugin();
            plugin.didCallSetupOverride = true;
            plugin.currentActivity = new WeakReference<>(activity);

            ObservableFlutterResult notImplementedResult = new ObservableFlutterResult();
            plugin.onMethodCall(new MethodCall("not_implemented", null), notImplementedResult);

            ObservableFlutterResult internalErrorResult = new ObservableFlutterResult();
            plugin.onMethodCall(new MethodCall("", null), internalErrorResult);

            shadowOf(getMainLooper()).idle();

            Assert.assertTrue(notImplementedResult.didCallNotImplemented);
            Assert.assertFalse(notImplementedResult.didCallError);
            Assert.assertFalse(notImplementedResult.didCallSuccess);

            Assert.assertFalse(internalErrorResult.didCallNotImplemented);
            Assert.assertTrue(internalErrorResult.didCallError);
            Assert.assertFalse(internalErrorResult.didCallSuccess);
            Assert.assertEquals(BatchBridgePublicErrorCode.INTERNAL_BRIDGE_ERROR.code, internalErrorResult.lastErrorArguments.errorCode);
        });


    }
}
