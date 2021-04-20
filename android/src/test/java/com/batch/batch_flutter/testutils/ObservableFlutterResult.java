package com.batch.batch_flutter.testutils;

import androidx.annotation.Nullable;

import io.flutter.plugin.common.MethodChannel;

public class ObservableFlutterResult implements MethodChannel.Result {

    public boolean didCallSuccess = false;
    public boolean didCallError = false;
    public boolean didCallNotImplemented = false;

    public Object lastSuccessArgument = null;
    public ErrorArguments lastErrorArguments = null;

    @Override
    public void success(@Nullable Object result) {
        didCallSuccess = true;
        lastSuccessArgument = result;
    }

    @Override
    public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        didCallError = true;
        lastErrorArguments = new ErrorArguments(errorCode, errorMessage, errorDetails);
    }

    @Override
    public void notImplemented() {
        didCallNotImplemented = true;
    }

    public static class ErrorArguments {
        public final String errorCode;
        public final String errorMessage;
        public final Object errorDetails;

        public ErrorArguments(String errorCode, String errorMessage, Object errorDetails) {
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
            this.errorDetails = errorDetails;
        }
    }
}
