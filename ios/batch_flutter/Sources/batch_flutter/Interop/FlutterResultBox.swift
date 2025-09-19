@preconcurrency import Flutter
import Foundation

/**
 * Thread-safe wrapper for FlutterResult callbacks.
 *
 * This struct encapsulates FlutterResult callbacks to make them safely passable
 * across thread boundaries in Swift 6's strict concurrency model.
 *
 * Marked as `@unchecked Sendable` because FlutterResult callbacks are thread-safe
 * by design (they're meant to be called from any thread), but Swift's type system
 * can't automatically verify this. This wrapper allows the plugin to safely pass
 * Flutter callbacks between different concurrency contexts.
 *
 * ## Usage
 * ```swift
 * let box = FlutterResultBox(result: flutterResult)
 * someAsyncOperation { data in
 *     box.result(data) // Safe to call from any thread
 * }
 * ```
 */
struct FlutterResultBox: @unchecked Sendable {
	/// The encapsulated Flutter result callback
	let result: FlutterResult
}
