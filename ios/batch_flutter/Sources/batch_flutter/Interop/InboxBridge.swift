import Foundation
import Batch
import Flutter

extension BatchInboxFetcher: @unchecked @retroactive Sendable { }

final class InboxBridge: Sendable {
    private let fetcherStore = InboxFetcherStore()
    
    func doAction(_ action: Action, parameters: BridgeParameters) throws -> LightPromise {
        switch (action) {
            case .inbox_createInstallationFetcher:
                return createInstallationFetcher(parameters: parameters)
            case .inbox_createUserFetcher:
                return try createUserFetcher(parameters: parameters)
            case .inbox_releaseFetcher:
                try releaseFetcher(parameters: parameters)
				return .emptySuccess
            case .inbox_fetchNewNotifications:
                return try fetchNewNotifications(parameters: parameters)
            case .inbox_fetchNextPage:
                return try fetchNextPage(parameters: parameters)
            case .inbox_getFetchedNotifications:
                return try getAllFetchedNotifications(parameters: parameters)
            case .inbox_markAsRead:
                return try markAsRead(parameters: parameters)
            case .inbox_markAllAsRead:
                return markAllAsRead(parameters: parameters)
            case .inbox_markAsDeleted:
                return try markAsDeleted(parameters: parameters)
            case .inbox_displayLandingMessage:
                return try displayLandingMessage(parameters: parameters)
            default:
                // We should never end up here, unless the Bridge threw a non inbox method at us
                return .rejected(BridgeInternalError.notImplemented)
        }
    }
    
    private func createInstallationFetcher(parameters: BridgeParameters) -> LightPromise {
        let fetcherID = makeFetcherID()
        
        let maxPageSizeValue: UInt? = {
			if let maxPageSize = parameters["maxPageSize"] as? Int, maxPageSize > 0 { return UInt(maxPageSize) }
            return nil
        }()
        
        let limitValue: UInt? = {
			if let limit = parameters["limit"] as? Int, limit > 0 { return UInt(limit) }
            return nil
        }()
        
        return LightPromise { [self] resolve, reject in
			let callbacks = LightPromise.Callbacks(resolve: resolve, reject: reject)
            Task {
                let fetcher = BatchInbox.fetcher()
                setupCommonFetcherParameters(fetcher: fetcher, maxPageSize: maxPageSizeValue, limit: limitValue)
                await fetcherStore.setFetcher(fetcherID, fetcher)
				callbacks.resolve(.string(fetcherID))
            }
        }
    }
    
    private func createUserFetcher(parameters: BridgeParameters) throws -> LightPromise {
        let fetcherID = makeFetcherID()
        
        
		guard let user = parameters["user"] as? String else {
            throw BridgeError.makeBadArgumentError(argumentName: "user")
        }
        
        guard let authKey = parameters["authKey"] as? String else {
            throw BridgeError.makeBadArgumentError(argumentName: "authKey")
        }
        
        let maxPageSizeValue: UInt? = {
            if let maxPageSize = parameters["maxPageSize"] as? Int, maxPageSize > 0 { return UInt(maxPageSize) }
            return nil
        }()
        
        let limitValue: UInt? = {
            if let limit = parameters["limit"] as? Int, limit > 0 { return UInt(limit) }
            return nil
        }()
        
        return LightPromise { [self] resolve, reject in
			let callbacks = LightPromise.Callbacks(resolve: resolve, reject: reject)
            Task {
                do {
                    guard let fetcher = BatchInbox.fetcher(forUserIdentifier: user, authenticationKey: authKey) else {
                        throw BridgeError(code: BridgeError.ErrorCode.internalSDKError,
                                          description: "Internal SDK error: Failed to initialize the fetcher. Make sure your user identifier and authentication key are valid and not empty.",
                                          details: nil)
                    }

                    setupCommonFetcherParameters(fetcher: fetcher, maxPageSize: maxPageSizeValue, limit: limitValue)
                    await fetcherStore.setFetcher(fetcherID, fetcher)
					callbacks.resolve(.string(fetcherID))
                } catch {
                    callbacks.reject(error)
                }
            }
        }
    }
    
    private func setupCommonFetcherParameters(fetcher: BatchInboxFetcher, maxPageSize: UInt?, limit: UInt?) {
        if let maxPageSize = maxPageSize, maxPageSize > 0 {
            fetcher.maxPageSize = maxPageSize
        }

        if let limit = limit, limit > 0 {
            fetcher.limit = limit
        }
    }
    
    private func releaseFetcher(parameters: BridgeParameters) throws {
        let fetcherID = try getFetcherID(parameters)

        Task {
            await fetcherStore.removeFetcher(fetcherID)
        }
    }
    
    private func getAllFetchedNotifications(parameters: BridgeParameters) throws -> LightPromise {
        return LightPromise { resolve, reject in
            Task {
                do {
                    let fetcher = try await self.getFetcher(parameters)
                    let bridgeNotifs = InboxBridge.serializeNotifications(fetcher.allFetchedNotifications) as NSArray
                    resolve(.dictionary(["notifications": bridgeNotifs] as NSDictionary))
                } catch {
                    reject(error)
                }
            }
        }
    }
    
    private func fetchNewNotifications(parameters: BridgeParameters) throws -> LightPromise {
        return LightPromise { resolve, reject in
            Task {
                do {
                    let fetcher = try await self.getFetcher(parameters)
                    let callbacks = LightPromise.Callbacks(resolve: resolve, reject: reject)

                    fetcher.fetchNewNotifications { error, notifications, foundNewNotifications, endReached in
                        if let error = error {
                            callbacks.reject(BridgeError(code: BridgeError.ErrorCode.inboxError,
                                                        description: "Inbox fetchNewNotifications with error: \(error)",
                                                        details: nil))
                            return
                        }
                        guard let notifications = notifications else {
                            callbacks.reject(BridgeError(code: BridgeError.ErrorCode.internalSDKError,
                                                        description: "Internal SDK error: no error was returned, but no inbox notifications were returned",
                                                        details: nil))
                            return
                        }

                        callbacks.resolve(.dictionary([
                            "notifications": InboxBridge.serializeNotifications(notifications) as NSArray,
                            "endReached": NSNumber(value: endReached)
                        ] as NSDictionary))
                    }
                } catch {
                    reject(error)
                }
            }
        }
    }

    private func fetchNextPage(parameters: BridgeParameters) throws -> LightPromise {
        return LightPromise { resolve, reject in
            Task {
                do {
                    let fetcher = try await self.getFetcher(parameters)
                    let callbacks = LightPromise.Callbacks(resolve: resolve, reject: reject)

                    fetcher.fetchNextPage { error, notifications, endReached in
                        if let error = error {
                            callbacks.reject(BridgeError(code: BridgeError.ErrorCode.inboxError,
                                                        description: "Inbox fetchNextPage with error: \(error)",
                                                        details: nil))
                            return
                        }
                        guard let notifications = notifications else {
                            callbacks.reject(BridgeError(code: BridgeError.ErrorCode.internalSDKError,
                                                        description: "Internal SDK error: no error was returned, but no inbox notifications were returned",
                                                        details: nil))
                            return
                        }

                        callbacks.resolve(.dictionary([
                            "notifications": InboxBridge.serializeNotifications(notifications) as NSArray,
                            "endReached": NSNumber(value: endReached)
                        ] as NSDictionary))
                    }
                } catch {
                    reject(error)
                }
            }
        }
    }
    
    private func markAsRead(parameters: BridgeParameters) throws -> LightPromise {
        guard let notifID = parameters["notifID"] as? String else {
            throw BridgeError.makeBadArgumentError(argumentName: "notifID")
        }

        return LightPromise { resolve, reject in
            Task {
                do {
                    let fetcher = try await self.getFetcher(parameters)
                    let callbacks = LightPromise.Callbacks(resolve: resolve, reject: reject)

                    Task.detached(priority: .userInitiated) {
                        let nativeNotification = fetcher.allFetchedNotifications.first { $0.identifier == notifID }

                        if let nativeNotification = nativeNotification {
                            fetcher.markNotification(asRead: nativeNotification)
                        } else {
                            BatchFlutterLogger.logPublic(module: "Inbox", message: "Could not mark notification as read: No matching native notification. This can happen if you kept a Dart instance of a notification but are trying to use it with another fetcher, or if the fetcher has been reset inbetween.")
                        }

                        callbacks.resolve(.null)
                    }
                } catch {
                    reject(error)
                }
            }
        }
    }
    
    private func markAllAsRead(parameters: BridgeParameters) -> LightPromise {
		return LightPromise { resolve, reject in
			Task {
				do {
					let fetcher = try await self.getFetcher(parameters)
					fetcher.markAllNotificationsAsRead()
					resolve(.null)
				} catch {
					BatchFlutterLogger.logPublic(module: "Inbox", message: "Could not mark all notifications as read: \(error)")
					reject(error)
				}
			}
		}
    }
    
    private func markAsDeleted(parameters: BridgeParameters) throws -> LightPromise {
        guard let notifID = parameters["notifID"] as? String else {
            throw BridgeError.makeBadArgumentError(argumentName: "notifID")
        }

        return LightPromise { resolve, reject in
            Task {
                do {
                    let fetcher = try await self.getFetcher(parameters)
                    let callbacks = LightPromise.Callbacks(resolve: resolve, reject: reject)

                    Task.detached(priority: .userInitiated) {
                        let nativeNotification = fetcher.allFetchedNotifications.first { $0.identifier == notifID }

                        if let nativeNotification = nativeNotification {
                            fetcher.markNotification(asDeleted: nativeNotification)
                        } else {
                            BatchFlutterLogger.logPublic(module: "Inbox", message: "Could not mark notification as deleted: No matching native notification. This can happen if you kept a Dart instance of a notification but are trying to use it with another fetcher, or if the fetcher has been reset inbetween.")
                        }

                        callbacks.resolve(.null)
                    }
                } catch {
                    reject(error)
                }
            }
        }
    }

    private func displayLandingMessage(parameters: BridgeParameters) throws -> LightPromise {
        guard let notifID = parameters["notifID"] as? String else {
            throw BridgeError.makeBadArgumentError(argumentName: "notifID")
        }

        return LightPromise { resolve, reject in
            Task {
                do {
                    let fetcher = try await self.getFetcher(parameters)
                    let callbacks = LightPromise.Callbacks(resolve: resolve, reject: reject)

                    await MainActor.run {
                        let nativeNotification = fetcher.allFetchedNotifications.first { $0.identifier == notifID }
                        if let nativeNotification = nativeNotification {
                            nativeNotification.displayLandingMessage()
                        } else {
                            BatchFlutterLogger.logPublic(module: "Inbox", message: "Could not display the landing message: No matching native notification. This can happen if you kept a Dart instance of a notification but are trying to use it with another fetcher, or if the fetcher has been reset inbetween.")
                        }
                        callbacks.resolve(.null)
                    }
                } catch {
                    reject(error)
                }
            }
        }
    }
    
    private static func serializeNotifications(_ notifications: [BatchInboxNotificationContent]) -> [NSDictionary] {
        
        return notifications.filter{ !$0.isSilent }.map { notification in
            var serializedNotification = [String: AnyObject]()
            
            serializedNotification["id"] = notification.identifier as NSString
            // Body should never be nil, as we filtered silent notifications
            serializedNotification["body"] = (notification.message?.body ?? "") as NSString
            if let title = notification.message?.title {
                serializedNotification["title"] = title as NSString
            }
            
            serializedNotification["isUnread"] = NSNumber(value: notification.isUnread)
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
            serializedNotification["hasLandingMessage"] = NSNumber(value: notification.hasLandingMessage)
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
    
    private func getFetcher(_ parameters: BridgeParameters) async throws -> BatchInboxFetcher {
        let fetcherID = try getFetcherID(parameters)
        
		guard let fetcher = await fetcherStore.getFetcher(fetcherID) else {
            throw BridgeError(code: BridgeError.ErrorCode.internalBridgeError,
                              description: "The native inbox fetcher backing this object could not be found. Did you call dispose() and attempted to use the object afterwards?",
                              details: nil)
        }
        return fetcher
    }
    
    enum InboxBridgeError: Error {
        case payloadSerializationError
    }
}


