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
}
