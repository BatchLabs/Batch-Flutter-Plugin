import Foundation
import Batch
import Flutter

extension Bridge {
    
    fileprivate enum UserDataOperation: String {
        case setLanguage = "SET_LANGUAGE"
        case setRegion = "SET_REGION"
        case setIdentifier = "SET_IDENTIFIER"
        case setAttribute = "SET_ATTRIBUTE"
        case removeAttribute = "REMOVE_ATTRIBUTE"
        case clearAttributes = "CLEAR_ATTRIBUTES"
        case addTag = "ADD_TAG"
        case removeTag = "REMOVE_TAG"
        case clearTags = "CLEAR_TAGS"
        case clearTagCollection = "CLEAR_TAG_COLLECTION"
    }
    
    fileprivate enum UserDataType: String {
        case integer
        case float
        case string
        case date
        case boolean
    }
    
    func userDataEdit(parameters: BridgeParameters) throws {
        guard let operations = parameters["operations"] as? [[String: AnyObject]] else {
            throw BridgeError.makeBadArgumentError(argumentName: "operations")
        }
        
        let userDataEditor = BatchUser.editor()
        
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
                case .setIdentifier:
                    let rawValue = operationDescription["value"]
                    if rawValue == nil || rawValue is NSNull {
                        userDataEditor.setIdentifier(nil)
                    } else {
                        guard let value = rawValue as? String else {
                            throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".value")
                        }
                        userDataEditor.setIdentifier(value)
                    }
                    break;
                case .setLanguage:
                    let rawValue = operationDescription["value"]
                    if rawValue == nil || rawValue is NSNull {
                        userDataEditor.setLanguage(nil)
                    } else {
                        guard let value = rawValue as? String else {
                            throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".value")
                        }
                        userDataEditor.setLanguage(value)
                    }
                    break;
                case .setRegion:
                    let rawValue = operationDescription["value"]
                    if rawValue == nil || rawValue is NSNull {
                        userDataEditor.setRegion(nil)
                    } else {
                        guard let value = rawValue as? String else {
                            throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".value")
                        }
                        userDataEditor.setRegion(value)
                    }
                    break;
                case .addTag:
                    guard let tag = operationDescription["tag"] as? String else {
                        throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".tag")
                    }
                    guard let collection = operationDescription["collection"] as? String else {
                        throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".collection")
                    }
                    userDataEditor.addTag(tag, inCollection: collection)
                    break;
                case .removeTag:
                    guard let tag = operationDescription["tag"] as? String else {
                        throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".tag")
                    }
                    guard let collection = operationDescription["collection"] as? String else {
                        throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".collection")
                    }
                    userDataEditor.removeTag(tag, fromCollection: collection)
                    break;
                case .clearTagCollection:
                    guard let collection = operationDescription["collection"] as? String else {
                        throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".collection")
                    }
                    userDataEditor.clearTagCollection(collection)
                    break;
                case .clearTags:
                    userDataEditor.clearTags()
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
                            try? userDataEditor.set(attribute: boolValue, forKey: key)
                            break
                        case .integer:
                            guard let intValue = value as? Int64 else {
                                throw BridgeError.makeBadArgumentError(argumentName: errorArgumentName)
                            }
                            try? userDataEditor.set(attribute: intValue, forKey: key)
                            break
                        case .float:
                            guard let doubleValue = value as? Double else {
                                throw BridgeError.makeBadArgumentError(argumentName: errorArgumentName)
                            }
                            try? userDataEditor.set(attribute: doubleValue, forKey: key)
                            break
                        case .string:
                            guard let stringValue = value as? String else {
                                throw BridgeError.makeBadArgumentError(argumentName: errorArgumentName)
                            }
                            try? userDataEditor.set(attribute: stringValue, forKey: key)
                            break
                        case .date:
                            guard let rawTimestamp = value as? Int64 else {
                                throw BridgeError.makeBadArgumentError(argumentName: errorArgumentName)
                            }
                            let dateValue = Date(timeIntervalSince1970: Double(rawTimestamp) / 1000)
                            try? userDataEditor.set(attribute: dateValue, forKey: key)
                            break
                    }
                    
                    break;
                case .removeAttribute:
                    guard let key = operationDescription["key"] as? String else {
                        throw BridgeError.makeBadArgumentError(argumentName: rawOperation + ".key")
                    }
                    userDataEditor.removeAttribute(forKey: key)
                    break;
                case .clearAttributes:
                    userDataEditor.clearAttributes()
                    break;
            }
            
        }
        
        userDataEditor.save()
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
                                bridgeType = "e"
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
