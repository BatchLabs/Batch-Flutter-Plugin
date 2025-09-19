import Foundation
import Batch
import Flutter

extension Bridge {
    func optIn() -> LightPromise {
		return LightPromise { resolve, reject in
			let callbacks = LightPromise.Callbacks(resolve: resolve, reject: reject)
			BatchSDK.optIn()

			Task { @MainActor in
				BatchFlutterPlugin.startManagedNativeSDK()
				callbacks.resolve(.null)
			}
		}
    }

    func optOut() -> LightPromise {
        return LightPromise { resolve, _ in
            BatchSDK.optOut { _ in
				resolve(.null)
                return BatchOptOutNetworkErrorPolicy.ignore
            }
        }
    }
    
    func optOutAndWipeData() -> LightPromise {
        return LightPromise { resolve, _ in
            BatchSDK.optOutAndWipeData { _ in
				resolve(.null)
                return BatchOptOutNetworkErrorPolicy.ignore
            }
        }
    }
}
