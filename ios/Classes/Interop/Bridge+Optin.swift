import Foundation
import Batch
import Flutter

extension Bridge {
    func optIn() {
        BatchSDK.optIn()
        BatchFlutterPlugin.startManagedNativeSDK()
    }

    func optOut() -> LightPromise<AnyObject?> {
        return LightPromise<AnyObject?> { resolve, _ in
            BatchSDK.optOut { _ in
                resolve(nil)
                return BatchOptOutNetworkErrorPolicy.ignore
            }
        }
    }
    
    func optOutAndWipeData() -> LightPromise<AnyObject?> {
        return LightPromise<AnyObject?> { resolve, _ in
            BatchSDK.optOutAndWipeData { _ in
                resolve(nil)
                return BatchOptOutNetworkErrorPolicy.ignore
            }
        }
    }
}
