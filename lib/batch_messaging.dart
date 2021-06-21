import 'package:flutter/services.dart';

/// Provides messaging related functionality, such as do not disturb.
/// Do not instanciate this: use the `instance` static property.
class BatchMessaging {
  static const MethodChannel _channel =
      const MethodChannel('batch_flutter.messaging');

  /// Batch Messaging module singleton.
  static BatchMessaging instance = new BatchMessaging();
}
