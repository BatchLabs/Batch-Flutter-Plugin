import Foundation
import Batch

// Bridge Debug methods
extension Bridge {
    func showDebugView() {
		Task { @MainActor in
			if let debugVC = BatchSDK.makeDebugViewController(),
			   let rootViewController = WindowHelper.topViewController {
				rootViewController.present(debugVC, animated: true, completion: nil)
			} else {
				BatchFlutterLogger.logPublic(module: "Core", message: "Could not display debug view")
			}
		}
    }
}
