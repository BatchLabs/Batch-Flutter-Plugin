import Foundation
import Batch
import Flutter

/// This class' job is to:
/// - Hold references to bridges by ID and instanciate/release them, so that a bridged object on the plugin side
///    can reference to it.
/// - Implement Inbox bridge methods
class InboxBridge {
    func doAction(_ action: Action, parameters: BridgeParameters) -> LightPromise<AnyObject?> {
        switch (action) {
            case .inbox_releaseFetcher,
                 .inbox_createInstallationFetcher,
                 .inbox_createUserFetcher,
                 .inbox_fetchNextPage,
                 .inbox_fetchNewNotifications,
                 .inbox_getFetchedNotifications:
                return LightPromise<AnyObject?>.rejected(BridgeInternalError.notImplemented)
            default:
                // We should never end up here, unless the Bridge threw a non inbox method at us
                return LightPromise<AnyObject?>.rejected(BridgeInternalError.notImplemented)
        }
    }
}
