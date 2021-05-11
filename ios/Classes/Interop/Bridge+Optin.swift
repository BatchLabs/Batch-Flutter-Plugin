import Foundation
import Batch
import Flutter

extension Bridge {
    func optIn() {
        Batch.optIn()
        if BatchFlutterPlugin().isSetup {
            BatchFlutterPlugin.startManagedNativeSDK()
        }
    }

    func optOut() {
        Batch.optOut { _ in
            return BatchOptOutNetworkErrorPolicy.ignore
        }
    }
    
    func optOutAndWipeData() {
        Batch.optOutAndWipeData { _ in
            return BatchOptOutNetworkErrorPolicy.ignore
        }
    }
}
