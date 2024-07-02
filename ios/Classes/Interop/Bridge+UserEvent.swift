import Foundation
import Batch
import Flutter

extension Bridge {
    func trackEvent(_ parameters: BridgeParameters) -> LightPromise<AnyObject?> {
        return LightPromise<AnyObject?> { resolve, reject in
            guard let name = parameters["name"] as? String else {
                reject(BridgeError.makeBadArgumentError(argumentName: "name"))
                return
            }
            guard let rawEventData = parameters["event_data"] as? [String: AnyObject] else {
                // event_data is optional, ignore it if it is of the wrong type
                BatchProfile.trackEvent(name: name, attributes: nil)
                resolve(nil)
                return
            }
            let attributes = try? parseEventData(rawEventData)
            do {
                let _ = try attributes?.validate()
                BatchProfile.trackEvent(name: name, attributes: attributes)
                resolve(nil)
            } catch let error {
                reject(error)
            }
        }
        
    }
    
    func trackLocation(_ parameters: [String: AnyObject]) throws {
        guard let latitude = parameters["latitude"] as? Double else {
            throw BridgeError.makeBadArgumentError(argumentName: "latitude")
        }
        
        guard let longitude = parameters["longitude"] as? Double else {
            throw BridgeError.makeBadArgumentError(argumentName: "longitude")
        }
        
        BatchProfile.trackLocation(CLLocation(latitude: latitude, longitude: longitude))
    }
    
    private func parseEventData(_ rawEventData: BridgeParameters) throws -> BatchEventAttributes? {
        
        let eventData = BatchEventAttributes()
    
        try rawEventData.forEach { (key, typedValue) in
            guard let type = typedValue["type"] as? String else {
                throw BridgeError.makeBadArgumentError(argumentName: "event_data: type")
            }
            
            let argumentErrorDescription = "event_data: attribute value"
            
            switch type {
                case "s":
                    guard let value = typedValue["value"] as? String else {
                        throw BridgeError.makeBadArgumentError(argumentName: argumentErrorDescription)
                    }
                    eventData.put(value, forKey: key)
                    break
                case "u":
                    guard let value = typedValue["value"] as? String, let urlValue = URL(string: value) else {
                        throw BridgeError.makeBadArgumentError(argumentName: argumentErrorDescription)
                    }
                    eventData.put(urlValue, forKey: key)
                    break
                case "b":
                    guard let value = typedValue["value"] as? Bool else {
                        throw BridgeError.makeBadArgumentError(argumentName: argumentErrorDescription)
                    }
                    eventData.put(value, forKey: key)
                    break
                case "i":
                    guard let value = typedValue["value"] as? Int64 else {
                        throw BridgeError.makeBadArgumentError(argumentName: argumentErrorDescription)
                    }
                    eventData.put(Int(truncatingIfNeeded: value), forKey: key)
                    break
                case "f":
                    guard let value = typedValue["value"] as? Double else {
                        throw BridgeError.makeBadArgumentError(argumentName: argumentErrorDescription)
                    }
                    eventData.put(value, forKey: key)
                    break
                case "d":
                    guard let rawTimestamp = typedValue["value"] as? Int64 else {
                        throw BridgeError.makeBadArgumentError(argumentName: argumentErrorDescription)
                    }
                    let date = Date(timeIntervalSince1970: Double(rawTimestamp) / 1000)
                    eventData.put(date, forKey: key)
                    break
                case "o":
                    guard let value = typedValue["value"] as? BridgeParameters else {
                        throw BridgeError.makeBadArgumentError(argumentName: argumentErrorDescription)
                    }
                    guard let objectAttribute = try parseEventData(value) else {
                        throw BridgeError.makeBadArgumentError(argumentName: argumentErrorDescription)
                    }
                    eventData.put(objectAttribute, forKey:key)
                    break
                case "sa":
                    guard let value = typedValue["value"] as? Array<String> else {
                        throw BridgeError.makeBadArgumentError(argumentName: argumentErrorDescription)
                    }
                    eventData.put(value, forKey: key)
                    break
                case "oa":
                    guard let value = typedValue["value"] as? Array<BridgeParameters> else {
                        throw BridgeError.makeBadArgumentError(argumentName: argumentErrorDescription)
                    }
                    var objectArray: [BatchEventAttributes] = []
                    for objectAttribute in value {
                        if let object = try parseEventData(objectAttribute) {
                            objectArray.append(object)
                        }
                    }
                    eventData.put(objectArray, forKey: key)
                    break
                default:
                    throw BridgeError(code: BridgeError.ErrorCode.internalBridgeError,
                                      description: "event_data.attributes: unknown type '\(type)'",
                                      details: nil)
            }
        }
        
        return eventData
    }
}
