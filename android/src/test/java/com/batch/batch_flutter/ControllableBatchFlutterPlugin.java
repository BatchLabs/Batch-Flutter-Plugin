package com.batch.batch_flutter;

public class ControllableBatchFlutterPlugin extends BatchFlutterPlugin {
    public boolean didCallSetupOverride = false;

    @Override
    protected boolean isSetup() {
        return didCallSetupOverride;
    }
}
