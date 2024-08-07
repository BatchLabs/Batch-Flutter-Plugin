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
  Future<void> optIn() async {
    await _channel.invokeMethod('optIn');
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
  ///  - Make the Inbox module return an error immediately
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
  Future<void> optOut() async {
    await _channel.invokeMethod('optOut');
  }

  /// Opt-out from Batch SDK and wipe data.
  /// An installation data wipe command will be sent to Batch's servers if the user is connected to the internet.
  ///
  /// See `Batch.optOut()` for more info.
  ///
  /// Asking to opt out and wipe data while the SDK is already opted out from
  /// won't do anything: please temporarily opt-in so that the data wipe request
  /// can be sent to Batch's servers.
  Future<void> optOutAndWipeData() async {
    await _channel.invokeMethod('optOutAndWipeData');
  }

  /// Checks whether Batch has been opted out from or not.
  ///
  /// Returns a promise that resolves to a boolean value indicating whether Batch
  /// has been opted out from or not.
  Future<bool> isOptedOut() async {
    bool isOptedOut = await _channel.invokeMethod('isOptedOut');
    return isOptedOut;
  }

  /// Configure the SDK Automatic Data Collection by passing [dataCollectionConfig], a
  /// Map<String, bool> holding the configuration parameters.
  ///
  /// The following keys are allowed:
  /// -  "geoIP": (optional - default: false) Whether Batch can resolve the GeoIP on server side.
  /// -  "deviceBrand": (optional - default: false) Whether Batch can send the device brand information. (Android only)
  /// -  "deviceModel": (optional - default: false) Whether Batch can send the device model information.
  ///
  /// Example:
  /// ```dart
  ///     Batch.instance.setAutomaticDataCollection({
  ///        "geoIP": true, /// Enable GeoIP resolution on server side
  ///        "deviceBrand": true, /// Enable automatic collection of the device brand information (android only)
  ///        "deviceModel": true /// Enable automatic collection of the device model information
  ///     });
  /// ```
  void setAutomaticDataCollection(Map<String, bool> dataCollectionConfig) {
    _channel.invokeMethod('setAutomaticDataCollection', {"dataCollectionConfig": dataCollectionConfig});
  }
}
