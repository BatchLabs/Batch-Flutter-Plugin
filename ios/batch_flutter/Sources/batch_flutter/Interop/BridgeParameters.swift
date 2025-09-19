/**
 * Thread-safe wrapper for bridge method parameters.
 *
 * This struct provides a concurrency-safe way to handle parameters passed from
 * Flutter to native bridge methods. It encapsulates the parameter dictionary
 * and provides safe access through subscript notation.
 *
 * Marked as `@unchecked Sendable` because the underlying dictionary contains
 * AnyObject values which may not be Sendable, but in the context of bridge
 * parameters, these values are safe to pass between threads as they represent
 * immutable data from the Flutter layer.
 */
struct BridgeParameters: @unchecked Sendable {
	/// The underlying parameter dictionary
	private let value: [String: AnyObject]

	/**
	 * Initializes bridge parameters with a dictionary.
	 *
	 * - Parameter value: The parameter dictionary, defaults to empty
	 */
	init(value: [String : AnyObject] = [:]) {
		self.value = value
	}

	/**
	 * Accesses parameter values by key.
	 *
	 * - Parameter key: The parameter key to look up
	 * - Returns: The parameter value, or nil if key doesn't exist
	 */
	subscript(key: String) -> AnyObject? {
		return value[key]
	}
}
