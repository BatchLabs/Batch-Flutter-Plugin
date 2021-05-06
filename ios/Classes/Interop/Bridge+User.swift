import Foundation
import Batch
import Flutter

extension Bridge {
    func trackEvent(_ parameters: BridgeParameters) throws {
        //TODO: Handle Event data
        guard let name = parameters["name"] as? String else {
            throw BridgeError.makeBadArgumentError(argumentName: "name")
        }
        
        let label = parameters["label"] as? String
        
        BatchUser.trackEvent(name, withLabel: label)
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
}
