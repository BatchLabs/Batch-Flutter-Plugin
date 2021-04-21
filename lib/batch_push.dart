import 'package:flutter/services.dart';

class BatchPush {
  static const MethodChannel _channel =
      const MethodChannel('batch_flutter.push');

  /// Batch User module singleton.
  static BatchPush instance = new BatchPush();

  Future<String?> get lastKnownPushToken async {
    return await _channel.invokeMethod('push.getLastKnownPushToken');
  }
}
