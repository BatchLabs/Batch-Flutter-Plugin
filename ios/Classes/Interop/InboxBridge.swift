import Foundation
import Batch
import Flutter

/// This class' job is to:
/// - Hold references to bridges by ID and instanciate/release them, so that a bridged object on the plugin side
///    can reference to it.
/// - Implement Inbox bridge methods
class InboxBridge {
    var fetchers: [String: BatchInboxFetcher] = [:]
    
    func doAction(_ action: Action, parameters: BridgeParameters) throws -> LightPromise<AnyObject?> {
        switch (action) {
            case .inbox_createInstallationFetcher:
                return createInstallationFetcher()
            case .inbox_createUserFetcher:
                return try createUserFetcher(parameters: parameters)
            case .inbox_releaseFetcher:
                try releaseFetcher(parameters: parameters)
                return LightPromise<AnyObject?>.resolved(nil)
            case .inbox_fetchNextPage,
                 .inbox_fetchNewNotifications,
                 .inbox_getFetchedNotifications:
                return LightPromise<AnyObject?>.rejected(BridgeInternalError.notImplemented)
            default:
                // We should never end up here, unless the Bridge threw a non inbox method at us
                return LightPromise<AnyObject?>.rejected(BridgeInternalError.notImplemented)
        }
    }
    
    private func createInstallationFetcher() -> LightPromise<AnyObject?> {
        let fetcherID = makeFetcherID()
        
        //TODO: Synchronize
        fetchers[fetcherID] = BatchInbox.fetcher()
        
        return LightPromise<AnyObject?>.resolved(fetcherID as NSString)
    }
    
    private func createUserFetcher(parameters: BridgeParameters) throws -> LightPromise<AnyObject?> {
        let fetcherID = makeFetcherID()
        
        guard let user = parameters["user"] as? String else {
            throw BridgeError.makeBadArgumentError(argumentName: "user")
        }
        
        guard let authKey = parameters["authKey"] as? String else {
            throw BridgeError.makeBadArgumentError(argumentName: "authKey")
        }
        
        //TODO: Synchronize
        fetchers[fetcherID] = BatchInbox.fetcher(forUserIdentifier: user, authenticationKey: authKey)
        
        return LightPromise<AnyObject?>.resolved(fetcherID as NSString)
    }
    
    private func releaseFetcher(parameters: BridgeParameters) throws {
        let fetcherID = try getFetcherID(parameters)
        
        //TODO: Synchronize
        fetchers[fetcherID] = nil
    }
    
    private func makeFetcherID() -> String {
        return UUID().uuidString
    }
    
    private func getFetcherID(_ parameters: BridgeParameters) throws -> String {
        guard let fetcherID = parameters["fetcherID"] as? String else {
            throw BridgeError.makeBadArgumentError(argumentName: "fetcherID")
        }
        return fetcherID
    }
    
    private func getFetcher(_ parameters: BridgeParameters) throws -> BatchInboxFetcher {
        guard let fetcher = try fetchers[getFetcherID(parameters)] else {
            throw BridgeError(code: BridgeError.ErrorCode.internalBridgeError,
                              description: "The native inbox fetcher backing this object could not be found. Did you call dispose() and attempted to use the object afterwards?",
                              details: nil)
        }
        return fetcher
    }
}
