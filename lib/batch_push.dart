import 'package:flutter/services.dart';

/// Provides push related functionality.
/// Do not instanciate this: use the `instance` static property.
class BatchPush {
  static const MethodChannel _channel =
      const MethodChannel('batch_flutter.push');

  /// Batch User module singleton.
  static BatchPush instance = new BatchPush();

  /// Get the last known push token.
  /// This might be null if the SDK never successfully registered to push notifcations.
  ///
  /// A number of issues can cause this: Invalid configuration, no permission
  /// to display notifications,
  /// running on an iOS simulator, Firebase unavailability, ...
  /// See your logs for more information.
  ///
  /// Note: Calling this method too early in the application lifecycle might
  /// return an out of date value.
  Future<String?> get lastKnownPushToken async {
    return await _channel.invokeMethod('push.getLastKnownPushToken');
  }

  void requestNotificationAuthorization() {
    _channel.invokeMethod('push.iOS.requestPermission');
  }
}
