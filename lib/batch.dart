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

  /// Opt-in to Batch SDK.
  /// Will automatically restart the SDK with the configured API Key.
  void optIn() {
    _channel.invokeMethod('optIn');
  }

  /// Opt-out from Batch SDK.
  /// A opt-out request will also be sent to Batch servers if possible.
  /// The SDK will save the opt-out and stop running even if the network request
  /// fails.
  ///
  /// Some modules might behave unexpectedly
  /// when the SDK is opted out from.
  ///
  /// Opting out will:
  ///  - Prevent the SDK from being started until you call `optIn()`
  ///  - Disable any network capability from the SDK
  ///  - Disable all In-App campaigns
  ///  - Make the Inbox module return an error immediatly
  ///  - Make any call to `BatchUserDataEditor.save()` do nothing
  ///  - Make any "track" methods from BatchUser ineffective
  ///
  /// Even if you opt-in afterwards, data generated (such as user data or tracked events) while opted out WILL be lost.
  ///
  /// If you also want to delete user data, please see `Batch.optOutAndWipeData()`.
  ///
  /// To implement a consent request where Batch should not be enabled until
  /// the user explicitly opts-in, please see our documentation for opting out of
  /// Batch by default, rather than using this method.
  void optOut() {
    _channel.invokeMethod('optOut');
  }

  /// Opt-out from Batch SDK and wipe data.
  /// An installation data wipe command will be sent to Batch's servers if the user is connected to the internet.
  ///
  /// See `Batch.optOut()` for more info.
  ///
  /// Asking to opt out and wipe data while the SDK is already opted out from
  /// won't do anything: please temporarily opt-in so that the data wipe request
  /// can be sent to Batch's servers.
  void optOutAndWipeData() {
    _channel.invokeMethod('optOutAndWipeData');
  }
}
