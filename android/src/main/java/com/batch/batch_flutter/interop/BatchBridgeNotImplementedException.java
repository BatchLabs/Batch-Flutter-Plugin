package com.batch.batch_flutter.interop;

public class BatchBridgeNotImplementedException extends Exception {
    public BatchBridgeNotImplementedException(String method) {
        super("Bridge method '" + method + "' is not implemented");
    }
}
