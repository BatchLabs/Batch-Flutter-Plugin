import 'package:flutter/widgets.dart';

/// Private class: Batch Logger
/// <nodoc>
@protected
class BatchLogger {
  static const bool enableInternalLogs = true;

  static void public(String message) {
    debugPrint("batch_flutter: $message");
  }

  static void internal(String message) {
    if (enableInternalLogs) {
      debugPrint("batch_flutter (internal): $message");
    }
  }
}
