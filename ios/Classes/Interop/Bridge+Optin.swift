import Foundation
import Batch
import Flutter

extension Bridge {
    func optIn() {
        Batch.optIn()
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
