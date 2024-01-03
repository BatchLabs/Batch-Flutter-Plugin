package com.batch.batch_flutter_example;

import android.content.Intent;

import androidx.annotation.NonNull;

import com.batch.android.Batch;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onStart() {
        super.onStart();
    }

    @Override
    protected void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        Batch.onNewIntent(this, intent);
    }
}
