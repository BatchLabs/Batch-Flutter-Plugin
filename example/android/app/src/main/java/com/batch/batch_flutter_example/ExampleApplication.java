package com.batch.batch_flutter_example;

import android.app.Application;

import com.batch.batch_flutter.BatchFlutterLogger;
import com.batch.batch_flutter.BatchFlutterPlugin;

public class ExampleApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        BatchFlutterLogger.enableDebugLogs = true;
        BatchFlutterPlugin.getConfiguration(this)
                .setAPIKey("60802CE500701B1E2399E1FC31E33E")
                .setCanUseAdvertisingID(true);
        BatchFlutterPlugin.setup(this);
    }
}
