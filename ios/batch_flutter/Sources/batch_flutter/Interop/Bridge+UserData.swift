import Foundation
import Batch
import Flutter

extension Bridge {
    
    func userDataFetchAttributes() -> LightPromise {
        return LightPromise { resolve, reject in
			let callbacks = LightPromise.Callbacks(resolve: resolve, reject: reject)
            BatchUser.fetchAttributes { attributes in
                do {
                    guard let attributes = attributes else {
                        throw BridgeError.init(code: BridgeError.ErrorCode.internalSDKError,
                                        description: "Native SDK fetchAttributes returned an error",
                                            details: nil)
                    }
                    
                    let bridgeAttributes: [String: [String: AnyObject]] = try attributes.mapValues { userAttribute in
                        
                        var bridgeValue: AnyObject? = nil
                        let bridgeType: String
                        switch userAttribute.type {
                            case BatchUserAttributeType.bool:
                                bridgeType = "b"
                                bridgeValue = userAttribute.numberValue()
                                break
                            case BatchUserAttributeType.date:
                                bridgeType = "d"
                                if let dateValue = userAttribute.dateValue() {
                                    bridgeValue = NSNumber(value: Int64(floor(dateValue.timeIntervalSince1970 * 1000)))
                                }
                                break
                            case BatchUserAttributeType.string:
                                bridgeType = "s"
                                bridgeValue = userAttribute.stringValue() as NSString?
                                break
                            case BatchUserAttributeType.longLong:
                                bridgeType = "i"
                                bridgeValue = userAttribute.numberValue()
                                break
                            case BatchUserAttributeType.double:
                                bridgeType = "f"
                                bridgeValue = userAttribute.numberValue()
                                break
                            case BatchUserAttributeType.URL:
                                bridgeType = "u"
                                bridgeValue = userAttribute.urlValue()?.absoluteString as NSString?
                                break
                            default:
                                throw BridgeError.init(code: BridgeError.ErrorCode.internalBridgeError,
                                                description: "Fetch attribute: Unknown attribute type \(userAttribute.type).",
                                                    details: nil)
                        }
                        
                        guard let finalBridgeValue = bridgeValue else {
                            throw BridgeError.init(code: BridgeError.ErrorCode.internalBridgeError,
                                            description: "Fetch attribute: Failed to serialize attribute for type \(bridgeType)",
                                                details: nil)
                        }
                        
                        return [
                            "type": bridgeType as NSString,
                            "value": finalBridgeValue
                        ]
                    }
                    
					callbacks.resolve(.dictionary(bridgeAttributes as NSDictionary))
                } catch {
                    callbacks.reject(error)
                }
            }
        }
    }
    
    func userDataFetchTags() -> LightPromise {
        return LightPromise { resolve, reject in
			let callbacks = LightPromise.Callbacks(resolve: resolve, reject: reject)
            BatchUser.fetchTagCollections { tagCollections in
                guard let tagCollections = tagCollections else {
                    callbacks.reject(BridgeError.init(code: BridgeError.ErrorCode.internalSDKError,
                                            description: "Native SDK fetchTagCollections returned an error",
                                            details: nil))
                    return
                }
                
                let bridgeTagCollections: [String: [String]] = tagCollections.mapValues { tags in
                    return Array(tags)
                }
                
                callbacks.resolve(.dictionary(bridgeTagCollections as NSDictionary))
            }
        }
        
    }
}

