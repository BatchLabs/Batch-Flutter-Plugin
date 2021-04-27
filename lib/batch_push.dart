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

  /// Call this method to trigger the iOS popup that asks the user if they want
  /// to allow notifications to be displayed, then get a Push token.
  /// The default registration is made with Badge, Sound and Alert.
  /// You should call this at a strategic moment, like at the end of your onboarding.
  ///
  /// Batch will automatically ask for a push token if the user replies positively.
  void requestNotificationAuthorization() {
    _channel.invokeMethod('push.iOS.requestPermission');
  }

  /// Call this method to ask iOS for a provisional notification authorization.
  /// Batch will then automatically ask for a push token.
  ///
  /// Provisional authorization will NOT show a popup asking for user authorization,
  /// but notifications will NOT be displayed on the lock screen, or as a banner
  /// when the phone is unlocked.
  /// They will directly be sent to the notification center,
  /// accessible when the user swipes up on the lockscreen,
  /// or down from the statusbar when unlocked.
  ///
  /// This method does nothing on iOS 11 or lower.
  void requestProvisionalNotificationAuthorization() {
    _channel.invokeMethod('push.iOS.requestProvisionalPermission');
  }
}
