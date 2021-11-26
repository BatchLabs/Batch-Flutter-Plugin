import Foundation
import Batch
import Flutter

extension Bridge {
    func trackEvent(_ parameters: BridgeParameters) throws {
        guard let name = parameters["name"] as? String else {
            throw BridgeError.makeBadArgumentError(argumentName: "name")
        }
        
        let label = parameters["label"] as? String
        
        let data = try parseEventData(parameters)
        
        BatchUser.trackEvent(name, withLabel: label, data: data)
    }
    
    func trackTransaction(_ parameters: BridgeParameters) throws {
        guard let amount = parameters["amount"] as? Double else {
            throw BridgeError.makeBadArgumentError(argumentName: "amount")
        }
        
        BatchUser.trackTransaction(withAmount: amount)
    }
    
    func trackLocation(_ parameters: [String: AnyObject]) throws {
        guard let latitude = parameters["latitude"] as? Double else {
            throw BridgeError.makeBadArgumentError(argumentName: "latitude")
        }
        
        guard let longitude = parameters["longitude"] as? Double else {
            throw BridgeError.makeBadArgumentError(argumentName: "longitude")
        }
        
        BatchUser.trackLocation(CLLocation(latitude: latitude, longitude: longitude))
    }
    
    private func parseEventData(_ parameters: BridgeParameters) throws -> BatchEventData? {
        guard let rawEventData = parameters["event_data"] as? [String: AnyObject] else {
            // event_data is optional, ignore it if it is of the wrong type
            return nil
        }
        
        guard let tags = rawEventData["tags"] as? [String] else {
            throw BridgeError.makeBadArgumentError(argumentName: "event_data: tags")
        }
        
        guard let attributes = rawEventData["attributes"] as? [String: [String: AnyObject]] else {
            throw BridgeError.makeBadArgumentError(argumentName: "event_data: attributes")
        }
        
        let eventData = BatchEventData()
        
        tags.forEach { tag in
            eventData.add(tag: tag)
        }
        
        try attributes.forEach { (key, typedValue) in
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
                default:
                    throw BridgeError(code: BridgeError.ErrorCode.internalBridgeError,
                                      description: "event_data.attributes: unknown type '\(type)'",
                                      details: nil)
            }
        }
        
        return eventData
    }
}
