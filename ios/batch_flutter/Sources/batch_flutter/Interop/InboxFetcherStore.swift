import Foundation
import Batch
import Flutter

/// This class' job is to:
/// - Hold references to bridges by ID and instanciate/release them, so that a bridged object on the plugin side
///    can reference to it.
/// - Implement Inbox bridge methods
/// Actor to manage inbox fetchers safely
actor InboxFetcherStore {
    private var fetchers: [String: BatchInboxFetcher] = [:]

    func setFetcher(_ id: String, _ fetcher: BatchInboxFetcher) {
        fetchers[id] = fetcher
    }

    func removeFetcher(_ id: String) {
        fetchers[id] = nil
    }

    func getFetcher(_ id: String) -> BatchInboxFetcher? {
        return fetchers[id]
    }
}
