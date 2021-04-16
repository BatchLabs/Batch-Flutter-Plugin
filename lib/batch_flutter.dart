
import 'dart:async';

import 'package:flutter/services.dart';

class BatchFlutter {
  static const MethodChannel _channel =
      const MethodChannel('batch_flutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
