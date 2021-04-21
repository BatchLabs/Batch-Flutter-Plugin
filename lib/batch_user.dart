import 'package:flutter/services.dart';

class BatchUser {
  static const MethodChannel _channel =
      const MethodChannel('batch_flutter.user');

  /// Batch User module singleton.
  static BatchUser instance = new BatchUser();

  Future<String?> get installationID async {
    return await _channel.invokeMethod('user.getInstallationID');
  }
}
