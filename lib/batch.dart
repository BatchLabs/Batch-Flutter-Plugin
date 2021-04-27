import 'dart:async';

import 'package:flutter/services.dart';

/// Batch SDK Flutter Plugin main module.
///
/// The plugin is split into multiple modules.
/// Use the "instance" property on the following classes to use them.
///  - Batch
///  - BatchUser
///  - BatchInbox
///
/// Even though you can instantiate the base class, Batch's native SDKs are mostly
/// composed of static methods, which is why the Flutter plugin should also
/// be used that way.
class Batch {
  /// Batch Plugin singleton.
  static Batch instance = new Batch();

  static const MethodChannel _channel = const MethodChannel('batch_flutter');

  /// Get the debug view controller.
  /// For development purposes only, this contains UI with multiple debug
  /// features allowing you to debug your Batch implementation more easily.
  /// If you want to make it accessible in production, you should hide it
  /// in a hard to reproduce sequence.
  void showDebugView() {
    _channel.invokeMethod('debug.showDebugView');
  }
}
