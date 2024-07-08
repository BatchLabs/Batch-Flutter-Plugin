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
import org.robolectric.Robolectric;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.android.controller.ActivityController;
import org.robolectric.annotation.LooperMode;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Map;

import static android.os.Looper.getMainLooper;
import static org.robolectric.Shadows.shadowOf;

import io.flutter.plugin.common.MethodCall;

@RunWith(RobolectricTestRunner.class)
public class BatchFlutterPluginTest {

    @Test
    public void testSetupErrors() {
        try (ActivityController<TestActivity> controller = Robolectric.buildActivity(TestActivity.class)) {
            controller.setup();

            TestActivity activity = controller.get();
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
        }
    }

    @Test
    public void testBridgeErrors() {
        try (ActivityController<TestActivity> controller = Robolectric.buildActivity(TestActivity.class)) {
            controller.setup();

            TestActivity activity = controller.get();
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
        }
    }

    @Test
    public void testBridgeSuccess() {
        try (ActivityController<TestActivity> controller = Robolectric.buildActivity(TestActivity.class)) {
            controller.setup();

            TestActivity activity = controller.get();
            Assert.assertNotNull(activity);

            ControllableBatchFlutterPlugin plugin = new ControllableBatchFlutterPlugin();
            plugin.didCallSetupOverride = true;
            plugin.currentActivity = new WeakReference<>(activity);

            final String helloWorld = "Hello, world!";
            final Map<String, Object> echoArguments = new HashMap<>();
            echoArguments.put("value", helloWorld);

            ObservableFlutterResult echoResult = new ObservableFlutterResult();
            plugin.onMethodCall(new MethodCall("echo", echoArguments), echoResult);

            shadowOf(getMainLooper()).idle();

            Assert.assertFalse(echoResult.didCallNotImplemented);
            Assert.assertFalse(echoResult.didCallError);
            Assert.assertTrue(echoResult.didCallSuccess);
            Assert.assertEquals(helloWorld, echoResult.lastSuccessArgument);

            echoResult.didCallSuccess = false;
            plugin.onMethodCall(new MethodCall("echo", null), echoResult);

            shadowOf(getMainLooper()).idle();

            Assert.assertFalse(echoResult.didCallNotImplemented);
            Assert.assertFalse(echoResult.didCallError);
            Assert.assertTrue(echoResult.didCallSuccess);
            Assert.assertNull(echoResult.lastSuccessArgument);
        }
    }
}
