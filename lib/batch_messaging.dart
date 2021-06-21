import 'package:flutter/services.dart';

/// Provides messaging related functionality, such as do not disturb.
/// Do not instanciate this: use the `instance` static property.
class BatchMessaging {
  static const MethodChannel _channel =
      const MethodChannel('batch_flutter.messaging');

  /// Batch Messaging module singleton.
  static BatchMessaging instance = new BatchMessaging();

  /// Toogles whether BatchMessaging should enter its "do not disturb" (DnD) mode or exit it.
  /// While in DnD, Batch will not display message, not matter if they've been
  /// triggered by notifications (mobile landings) or an In-App Campaign.
  ///
  /// This mode is useful for times where you don't want Batch to interrupt your user, such as during a splashscreen, a video or an interstitial ad.
  ///
  /// If a message should have been displayed during DnD, Batch will enqueue it,
  /// overwriting any previously enqueued message.
  /// When exiting DnD, Batch will not display the message automatically:
  /// you'll have to call the queue management methods to display the message,
  /// if you want to.
  ///
  /// While DnD is disabled by default, the default state can be configured
  /// in your Info.plist/AndroidManifest.xml
  void setDoNotDisturbEnabled(bool enableDoNotDisturb) {
    _channel.invokeMethod(
        'messaging.setDoNotDisturbEnabled', {'enabled': enableDoNotDisturb});
  }

  /// Shows the currently enqueued message, if any.
  /// This removes the message from the queue.
  void showPendingMessage() {
    _channel.invokeMethod('messaging.showPendingMessage');
  }
}
