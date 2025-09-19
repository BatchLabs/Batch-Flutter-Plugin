import Foundation

enum LightPromiseObject: @unchecked Sendable {
	case string(String?)
	case number(NSNumber)
	case dictionary(NSDictionary)
	case null
	
	var value: AnyObject? {
		return switch self {
		case .string(let string): string as AnyObject?
		case .number(let number): number as AnyObject?
		case .dictionary(let dictionary): dictionary as AnyObject?
		case .null: nil
		}
	}
}
