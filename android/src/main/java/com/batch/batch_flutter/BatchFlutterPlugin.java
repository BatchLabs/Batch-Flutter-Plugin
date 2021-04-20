package com.batch.batch_flutter;

import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** BatchFlutterPlugin */
public class BatchFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

  private final static BatchPluginConfiguration configuration = new BatchPluginConfiguration();

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    // Automatically read configuration from manifest
    configuration.initFromManifest(flutterPluginBinding.getApplicationContext());

    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "batch_flutter");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    result.notImplemented();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  //region Activity awareness

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }

  //endregion

  //region Public API
  public static BatchPluginConfiguration getConfiguration(@NonNull Context context) {
    //noinspection ConstantConditions
    if (context == null) {
      throw new IllegalArgumentException("Cannot call getConfiguration with a null context");
    }
    // Ensure that we read the default values from the manifest before any custom one is set
    // as this can be called before "onAttachedToEngine"
    configuration.initFromManifest(context);
    return configuration;
  }
  //endregion
}
