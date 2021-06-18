import Foundation
import Batch
import Flutter

/// This class' job is to:
/// - Hold references to bridges by ID and instanciate/release them, so that a bridged object on the plugin side
///    can reference to it.
/// - Implement Inbox bridge methods
class InboxBridge {
    let fetchersSyncQueue = DispatchQueue(label: "com.batch.interop.inbox", attributes: [.concurrent])
    
    var fetchers: [String: BatchInboxFetcher] = [:]
    
    func doAction(_ action: Action, parameters: BridgeParameters) throws -> LightPromise<AnyObject?> {
        switch (action) {
            case .inbox_createInstallationFetcher:
                return createInstallationFetcher(parameters: parameters)
            case .inbox_createUserFetcher:
                return try createUserFetcher(parameters: parameters)
            case .inbox_releaseFetcher:
                try releaseFetcher(parameters: parameters)
                return LightPromise<AnyObject?>.resolved(nil)
            case .inbox_fetchNewNotifications:
                return try fetchNewNotifications(parameters: parameters)
            case .inbox_fetchNextPage:
                return try fetchNextPage(parameters: parameters)
            case .inbox_getFetchedNotifications:
                return try getAllFetchedNotifications(parameters: parameters)
            case .inbox_markAsRead:
                return try markAsRead(parameters: parameters)
            case .inbox_markAllAsRead:
                try markAllAsRead(parameters: parameters)
                return LightPromise<AnyObject?>.resolved(nil)
            case .inbox_markAsDeleted:
                return try markAsDeleted(parameters: parameters)
            default:
                // We should never end up here, unless the Bridge threw a non inbox method at us
                return LightPromise<AnyObject?>.rejected(BridgeInternalError.notImplemented)
        }
    }
    
    private func createInstallationFetcher(parameters: BridgeParameters) -> LightPromise<AnyObject?> {
        let fetcherID = makeFetcherID()
        
        return LightPromise<AnyObject?> { [self] resolve, reject in
            fetchersSyncQueue.async(flags: .barrier) {
                let fetcher = BatchInbox.fetcher()
                setupCommonFetcherParameters(fetcher: fetcher, parameters: parameters)
                fetchers[fetcherID] = fetcher
                resolve(fetcherID as NSString)
            }
        }
    }
    
    private func createUserFetcher(parameters: BridgeParameters) throws -> LightPromise<AnyObject?> {
        let fetcherID = makeFetcherID()
        
        
        guard let user = parameters["user"] as? String else {
            throw BridgeError.makeBadArgumentError(argumentName: "user")
        }
        
        guard let authKey = parameters["authKey"] as? String else {
            throw BridgeError.makeBadArgumentError(argumentName: "authKey")
        }
        
        return LightPromise<AnyObject?> { [self] resolve, reject in
            fetchersSyncQueue.async(flags: .barrier) {
                do {
                    guard let fetcher = BatchInbox.fetcher(forUserIdentifier: user, authenticationKey: authKey) else {
                        throw BridgeError(code: BridgeError.ErrorCode.internalSDKError,
                                          description: "Internal SDK error: Failed to initialize the fetcher. Make sure your user identifier and authentication key are valid and not empty.",
                                          details: nil)
                    }
                    
                    setupCommonFetcherParameters(fetcher: fetcher, parameters: parameters)
                    fetchers[fetcherID] = fetcher
                    resolve(fetcherID as NSString)
                } catch {
                    reject(error)
                }
            }
        }
    }
    
    private func setupCommonFetcherParameters(fetcher: BatchInboxFetcher, parameters: BridgeParameters) {
        if let maxPageSize = parameters["maxPageSize"] as? Int, maxPageSize > 0 {
            fetcher.maxPageSize = UInt(maxPageSize)
        }
        
        if let limit = parameters["limit"] as? Int, limit > 0 {
            fetcher.limit = UInt(limit)
        }
    }
    
    private func releaseFetcher(parameters: BridgeParameters) throws {
        let fetcherID = try getFetcherID(parameters)
        
        fetchersSyncQueue.async(flags: .barrier) {
            self.fetchers[fetcherID] = nil
        }
    }
    
    private func getAllFetchedNotifications(parameters: BridgeParameters) throws -> LightPromise<AnyObject?> {
        let fetcher = try getFetcher(parameters)
        let bridgeNotifs = InboxBridge.serializeNotifications(fetcher.allFetchedNotifications) as NSArray
        return LightPromise<AnyObject?>.resolved(["notifications": bridgeNotifs] as NSDictionary)
    }
    
    private func fetchNewNotifications(parameters: BridgeParameters) throws -> LightPromise<AnyObject?> {
        let fetcher = try getFetcher(parameters)
        
        return LightPromise<AnyObject?> { resolve, reject in
            fetcher.fetchNewNotifications { error, notifications, foundNewNotifications, endReached in
                if let error = error {
                    reject(BridgeError(code: BridgeError.ErrorCode.inboxError,
                                       description: "Inbox fetchNewNotifications with error: \(error)",
                                       details: nil))
                    return
                }
                guard let notifications = notifications else {
                    reject(BridgeError(code: BridgeError.ErrorCode.internalSDKError,
                                       description: "Internal SDK error: no error was returned, but no inbox notifications were returned",
                                       details: nil))
                    return
                }
                
                resolve([
                    "notifications": InboxBridge.serializeNotifications(notifications) as NSArray,
                    "endReached": NSNumber(value: endReached)
                ] as NSDictionary)
            }
        }
    }

    private func fetchNextPage(parameters: BridgeParameters) throws -> LightPromise<AnyObject?> {
        let fetcher = try getFetcher(parameters)
        
        return LightPromise<AnyObject?> { resolve, reject in
            fetcher.fetchNextPage { error, notifications, endReached in
                if let error = error {
                    reject(BridgeError(code: BridgeError.ErrorCode.inboxError,
                                       description: "Inbox fetchNextPage with error: \(error)",
                                       details: nil))
                    return
                }
                guard let notifications = notifications else {
                    reject(BridgeError(code: BridgeError.ErrorCode.internalSDKError,
                                       description: "Internal SDK error: no error was returned, but no inbox notifications were returned",
                                       details: nil))
                    return
                }
                
                resolve([
                    "notifications": InboxBridge.serializeNotifications(notifications) as NSArray,
                    "endReached": NSNumber(value: endReached)
                ] as NSDictionary)
            }
        }
    }
    
    private func markAsRead(parameters: BridgeParameters) throws -> LightPromise<AnyObject?> {
        let fetcher = try getFetcher(parameters)
        guard let notifID = parameters["notifID"] as? String else {
            throw BridgeError.makeBadArgumentError(argumentName: "notifID")
        }
        
        return LightPromise<AnyObject?> { resolve, reject in
            DispatchQueue.global(qos: .userInitiated).async {
                let nativeNotification = fetcher.allFetchedNotifications.first { $0.identifier == notifID }
                
                if let nativeNotification = nativeNotification {
                    fetcher.markNotification(asRead: nativeNotification)
                } else {
                    // TODO: Log but don't reject
                }
                
                resolve(nil);
            }
        }
    }
    
    private func markAllAsRead(parameters: BridgeParameters) throws {
        let fetcher = try getFetcher(parameters)
        
        fetcher.markAllNotificationsAsRead()
    }
    
    private func markAsDeleted(parameters: BridgeParameters) throws -> LightPromise<AnyObject?> {
        let fetcher = try getFetcher(parameters)
        guard let notifID = parameters["notifID"] as? String else {
            throw BridgeError.makeBadArgumentError(argumentName: "notifID")
        }
        
        return LightPromise<AnyObject?> { resolve, reject in
            DispatchQueue.global(qos: .userInitiated).async {
                let nativeNotification = fetcher.allFetchedNotifications.first { $0.identifier == notifID }
                
                if let nativeNotification = nativeNotification {
                    fetcher.markNotification(asDeleted: nativeNotification)
                } else {
                    // TODO: Log but don't reject
                }
                
                resolve(nil);
            }
        }
    }
    
    private static func serializeNotifications(_ notifications: [BatchInboxNotificationContent]) -> [NSDictionary] {
        
        return notifications.map { notification in
            var serializedNotification = [String: AnyObject]()
            
            serializedNotification["id"] = notification.identifier as NSString
            serializedNotification["body"] = notification.body as NSString
            if let title = notification.title {
                serializedNotification["title"] = title as NSString
            }
            
            serializedNotification["isUnread"] = NSNumber(value: notification.isUnread)
            serializedNotification["isDeleted"] = NSNumber(value: notification.isDeleted)
            serializedNotification["date"] = NSNumber(value: Int64(floor(notification.date.timeIntervalSince1970 * 1000)))
            
            if let payload = try? serializePayload(notification.payload) {
                serializedNotification["payload"] = payload
            } else {
                serializedNotification["payload"] = "{'error':'Internal native error (-100)'}" as NSString
            }
            
            let source: Int // UNKNOWN
            switch notification.source {
                case .campaign:
                    source = 1
                    break
                case .transactional:
                    source = 2
                    break
                case .trigger:
                    source = 3
                    break
                default:
                    source = 0 // UNKNOWN
                    break
            }
            serializedNotification["source"] = NSNumber(value: source)
            
            return serializedNotification as NSDictionary
        }
    }
    
    private static func serializePayload(_ payload: [AnyHashable: Any]) throws -> NSDictionary {
        var serializedPayload = [AnyHashable: NSString]()
        
        serializedPayload = try payload.mapValues { value in
            guard let data = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
                throw InboxBridgeError.payloadSerializationError
            }
            guard let jsonString = String(data: data, encoding: .utf8) as NSString? else {
                throw InboxBridgeError.payloadSerializationError
            }
            return jsonString
        }
        
        return serializedPayload as NSDictionary
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
        return try fetchersSyncQueue.sync {
            guard let fetcher = try fetchers[getFetcherID(parameters)] else {
                throw BridgeError(code: BridgeError.ErrorCode.internalBridgeError,
                                  description: "The native inbox fetcher backing this object could not be found. Did you call dispose() and attempted to use the object afterwards?",
                                  details: nil)
            }
            return fetcher
        }
    }
    
    enum InboxBridgeError: Error {
        case payloadSerializationError
    }
}
