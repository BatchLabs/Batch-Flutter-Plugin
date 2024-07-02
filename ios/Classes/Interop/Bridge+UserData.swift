import Foundation
import Batch
import Flutter

extension Bridge {
    
    fileprivate enum UserDataOperation: String {
        case setLanguage = "SET_LANGUAGE"
        case setRegion = "SET_REGION"
        case setEmailAddress = "SET_EMAIL_ADDRESS"
        case setEmailMarketingSubscription = "SET_EMAIL_MARKETING_SUBSCRIPTION"
        case setAttribute = "SET_ATTRIBUTE"
        case removeAttribute = "REMOVE_ATTRIBUTE"
        case addToStringArray = "ADD_TO_ARRAY"
        case removeFromStringArray = "REMOVE_FROM_ARRAY"
    }
    
    fileprivate enum UserDataType: String {
        case integer
        case float
        case string
        case date
        case boolean
        case url
        case array
    }	
    
    func userDataEdit(parameters: BridgeParameters) throws {
        guard let operations = parameters["operations"] as? [[String: AnyObject]] else {
            throw BridgeError.makeBadArgumentError(argumentName: "operations")
        }
        
        let profileAttributeEditor = BatchProfile.editor()
        
        try operations.forEach { operationDescription in
            guard let rawOperation = operationDescription["operation"] as? String else {
                throw BridgeError.makeBadArgumentError(argumentName: "operation")
            }
            
            guard let operation = UserDataOperation.init(rawValue: rawOperation) else {
                throw BridgeError(code: BridgeError.ErrorCode.internalBridgeError,
                                  description: "Unknown user data operation '\(rawOperation)'",
                                  details: nil)
            }
            
            switch operation {
                case .setEmailAddress:
                    let rawValue = operationDescription["value"]
                    if rawValue == nil || rawValue is NSNull {
                        try? profileAttributeEditor.setEmailAddress(nil)
                    } else {
                        guard let value = rawValue as? String else {
                            throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".value")
                        }
                        try? profileAttributeEditor.setEmailAddress(value)
                    }
                    break;
                case .setEmailMarketingSubscription:
                    let rawValue = operationDescription["value"]
                    guard let value = rawValue as? String else {
                        throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".value")
                    }
                    if (value == "subscribed") {
                        profileAttributeEditor.setEmailMarketingSubscriptionState(.subscribed)
                    } else if (value == "unsubscribed") {
                        profileAttributeEditor.setEmailMarketingSubscriptionState(.unsubscribed)
                    } else {
                        throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".value")
                    }
                    break;
                case .setLanguage:
                    let rawValue = operationDescription["value"]
                    if rawValue == nil || rawValue is NSNull {
                        try? profileAttributeEditor.setLanguage(nil)
                    } else {
                        guard let value = rawValue as? String else {
                            throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".value")
                        }
                        try? profileAttributeEditor.setLanguage(value)
                    }
                    break;
                case .setRegion:
                    let rawValue = operationDescription["value"]
                    if rawValue == nil || rawValue is NSNull {
                        try? profileAttributeEditor.setRegion(nil)
                    } else {
                        guard let value = rawValue as? String else {
                            throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".value")
                        }
                        try? profileAttributeEditor.setRegion(value)
                    }
                    break;
                case .addToStringArray:
                    guard let value = operationDescription["value"] as? String else {
                        throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".value")
                    }
                    guard let key = operationDescription["key"] as? String else {
                        throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".key")
                    }
                    try? profileAttributeEditor.addToStringArray(item: value, forKey:key)
                    break;
                case .removeFromStringArray:
                    guard let value = operationDescription["value"] as? String else {
                        throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".value")
                    }
                    guard let key = operationDescription["key"] as? String else {
                        throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".key")
                    }
                    try? profileAttributeEditor.removeFromStringArray(item: value, forKey: key)
                    break;
                case .setAttribute:
                    guard let key = operationDescription["key"] as? String else {
                        throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".key")
                    }
                    
                    guard let rawType = operationDescription["type"] as? String, let type = UserDataType.init(rawValue: rawType) else {
                        throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".type")
                    }
                    
                    let errorArgumentName = rawOperation + ".value (\(rawType))"
                    
                    guard let value = operationDescription["value"] else {
                        throw BridgeError.makeBadArgumentError(argumentName: errorArgumentName)
                    }
                    
                    // Errors are not ignored here as we don't want to crash the flutter application for this
                    
                    switch type {
                        case .boolean:
                            guard let boolValue = value as? Bool else {
                                throw BridgeError.makeBadArgumentError(argumentName: errorArgumentName)
                            }
                            try? profileAttributeEditor.set(attribute: boolValue, forKey: key)
                            break
                        case .integer:
                            guard let intValue = value as? Int64 else {
                                throw BridgeError.makeBadArgumentError(argumentName: errorArgumentName)
                            }
                            try? profileAttributeEditor.set(attribute: intValue, forKey: key)
                            break
                        case .float:
                            guard let doubleValue = value as? Double else {
                                throw BridgeError.makeBadArgumentError(argumentName: errorArgumentName)
                            }
                            try? profileAttributeEditor.set(attribute: doubleValue, forKey: key)
                            break
                        case .string:
                            guard let stringValue = value as? String else {
                                throw BridgeError.makeBadArgumentError(argumentName: errorArgumentName)
                            }
                            try? profileAttributeEditor.set(attribute: stringValue, forKey: key)
                            break
                        case .url:
                            guard let stringValue = value as? String, let urlValue = URL(string: stringValue) else {
                                throw BridgeError.makeBadArgumentError(argumentName: errorArgumentName)
                            }
                            try? profileAttributeEditor.set(attribute: urlValue, forKey: key)
                            break
                        case .date:
                            guard let rawTimestamp = value as? Int64 else {
                                throw BridgeError.makeBadArgumentError(argumentName: errorArgumentName)
                            }
                            let dateValue = Date(timeIntervalSince1970: Double(rawTimestamp) / 1000)
                            try? profileAttributeEditor.set(attribute: dateValue, forKey: key)
                            break
                        case .array:
                            guard let stringArrayValue = value as? Array<String> else {
                                throw BridgeError.makeBadArgumentError(argumentName: errorArgumentName)
                            }
                            try? profileAttributeEditor.set(attribute: stringArrayValue, forKey: key)
                            break
                    }
                    break;
                case .removeAttribute:
                    guard let key = operationDescription["key"] as? String else {
                        throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".key")
                    }
                    try? profileAttributeEditor.removeAttribute(key:key)
                    break;

            }
            
        }
        
        profileAttributeEditor.save()
    }
    
    func userDataFetchAttributes() -> LightPromise<AnyObject?> {
        return LightPromise<AnyObject?> { resolve, reject in
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
                    
                    resolve(bridgeAttributes as NSDictionary)
                } catch {
                    reject(error)
                }
            }
        }
    }
    
    func userDataFetchTags() -> LightPromise<AnyObject?> {
        return LightPromise<AnyObject?> { resolve, reject in
            BatchUser.fetchTagCollections { tagCollections in
                guard let tagCollections = tagCollections else {
                    reject(BridgeError.init(code: BridgeError.ErrorCode.internalSDKError,
                                            description: "Native SDK fetchTagCollections returned an error",
                                            details: nil))
                    return
                }
                
                let bridgeTagCollections: [String: [String]] = tagCollections.mapValues { tags in
                    return Array(tags)
                }
                
                resolve(bridgeTagCollections as NSDictionary)
            }
        }
        
    }
}
