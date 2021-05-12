import Foundation
import Batch
import Flutter

extension Bridge {
    func optIn() {
        Batch.optIn()
        BatchFlutterPlugin.startManagedNativeSDK()
    }

    func optOut() -> LightPromise<AnyObject?> {
        return LightPromise<AnyObject?> { resolve, _ in
            Batch.optOut { _ in
                resolve(nil)
                return BatchOptOutNetworkErrorPolicy.ignore
            }
        }
    }
    
    func optOutAndWipeData() -> LightPromise<AnyObject?> {
        return LightPromise<AnyObject?> { resolve, _ in
            Batch.optOutAndWipeData { _ in
                resolve(nil)
                return BatchOptOutNetworkErrorPolicy.ignore
            }
        }
    }
}
