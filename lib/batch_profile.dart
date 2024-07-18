import 'dart:collection';

import 'package:batch_flutter/src/batch_logger.dart';
import 'package:batch_flutter/src/typed_attribute.dart';
import 'package:batch_flutter/src/profile_attribute_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Provides Profile related functionality, such as custom data and events.
/// Do not instantiate this: use the `instance` static property.
class BatchProfile {
  static const MethodChannel _channel =
  const MethodChannel('batch_flutter.profile');

  /// Batch Profile module singleton.
  static BatchProfile instance = new BatchProfile();

  /// Identifies this device with a profile using a Custom User ID
  ///
  /// [identifier] of the profile you want to identify against. If a profile already exists,
  /// this device will be attached to it.
  /// Must not be longer than 1024 characters.
  void identify(String? identifier) {
    _channel.invokeMethod("profile.identify", {'identifier': identifier});
  }

  /// Instantiate a new [BatchProfileAttributeEditor] to edit custom data attributes.
  ///
  /// See [BatchProfileAttributeEditor]'s documentation for more info.
  BatchProfileAttributeEditor newEditor() {
    return BatchProfileAttributeEditorImpl(_channel);
  }

  /// Track an event.
  ///
  /// The event name is required and must not be empty. It should be composed of letters,
  /// numbers or underscores (\[a-z0-9_\]) and can’t be longer than 30 characters.
  ///
  /// The event [attributes] are an optional object holding attributes related
  /// to the event. See [BatchEventAttributes]'s documentation for more info.
  void trackEvent({required String name, BatchEventAttributes? attributes}) {
    Map eventArgs = {"name": name};
    if (attributes != null) {
      eventArgs["event_data"] = attributes.internalGetBridgeRepresentation();
    }
    _channel.invokeMethod("profile.track.event", eventArgs).catchError((error) => {
      BatchLogger.public("Tracking event '"+ name +"' failed with error: " + error.toString())
    });
  }

  /// Track a geolocation update.
  ///
  /// Batch does not ask for location permission or acquire user location on
  /// your behalf. Acquire location permission and values on your own and
  /// communicate them to Batch (if needed) using this method.
  void trackLocation({required double latitude, required double longitude}) {
    _channel.invokeMethod(
        "profile.track.location", {"latitude": latitude, "longitude": longitude});
  }
}

/// Email subscription state
enum BatchEmailSubscriptionState { subscribed, unsubscribed }


/// Batch's user data editor.
/// This object is used to transactionally edit user data. Calls can be chained
/// in a builder-like fashion.
/// Once you're done with your changes, call [BatchUserDataEditor.save] to persist your changes.
abstract class BatchProfileAttributeEditor {
  /// Set the application language. Overrides Batch's automatically detected value.
  ///
  /// `null` deletes the override: Batch will autodetect the user language.
  BatchProfileAttributeEditor setLanguage(String? language);

  /// Set the application region. Overrides Batch's automatically detected value.
  ///
  /// `null` deletes the override: Batch will autodetect the user region.
  BatchProfileAttributeEditor setRegion(String? region);

  /// Set the user email address.
  ///
  /// This requires to have a custom user ID registered
  /// or to call the `identify` method beforehand.
  /// Null to erase. Addresses must be valid.
  BatchProfileAttributeEditor setEmailAddress(String? email);

  /// Set the user email marketing subscription state
  ///
  /// Use enum BatchEmailSubscriptionState.subscribed or BatchEmailSubscriptionState.unsubscribed
  BatchProfileAttributeEditor setEmailMarketingSubscription(BatchEmailSubscriptionState state);

  /// Set a string attribute for a key.
  ///
  /// Attribute's key cannot be empty. It should be made of letters, numbers or underscores (\[a-z0-9_\])
  /// and can't be longer than 30 characters.
  /// String attribute values are non-empty strings and can't be longer than 64 characters.
  ///
  /// Any attribute with an invalid key or value will be ignored.
  BatchProfileAttributeEditor setStringAttribute(String key, String value);

  /// Set an integer attribute for a key.
  ///
  /// Attribute's key cannot be empty. It should be made of letters, numbers or underscores (\[a-z0-9_\])
  /// and can't be longer than 30 characters.
  ///
  /// Any attribute with an invalid key or value will be ignored.
  BatchProfileAttributeEditor setIntegerAttribute(String key, int value);

  /// Set a double attribute for a key.
  ///
  /// Attribute's key cannot be empty. It should be made of letters, numbers or underscores (\[a-z0-9_\])
  /// and can't be longer than 30 characters.
  ///
  /// Any attribute with an invalid key or value will be ignored.
  BatchProfileAttributeEditor setDoubleAttribute(String key, double value);

  /// Set a boolean attribute for a key.
  ///
  /// Attribute's key cannot be empty. It should be made of letters, numbers or underscores (\[a-z0-9_\])
  /// and can't be longer than 30 characters.
  ///
  /// Any attribute with an invalid key or value will be ignored.
  BatchProfileAttributeEditor setBooleanAttribute(String key, bool value);

  /// Set a URL attribute for a key.
  ///
  /// Attribute's key cannot be empty. It should be made of letters, numbers or underscores (\[a-z0-9_\])
  /// and can't be longer than 30 characters.
  ///
  /// While the value is an Uri instance, it must be a valid URL and
  /// must not be longer than 2048 characters.
  ///
  /// Any attribute with an invalid key or value will be ignored.
  BatchProfileAttributeEditor setUrlAttribute(String key, Uri value);

  /// Set a Date attribute for a key.
  ///
  /// Attribute's key cannot be empty. It should be made of letters, numbers or underscores (\[a-z0-9_\])
  /// and can't be longer than 30 characters.
  ///
  /// Date attribute values are sent in UTC to Batch. If you notice that the reported
  /// time may be off, try making an UTC DateTime for consistency.
  ///
  /// Any attribute with an invalid key or value will be ignored.
  BatchProfileAttributeEditor setDateTimeAttribute(String key, DateTime value);

  /// Set a String List attribute for a key.
  ///
  /// Attribute's key cannot be empty. It should be made of letters, numbers or underscores (\[a-z0-9_\])
  /// and can't be longer than 30 characters.
  ///
  /// String List attribute values cannot have more than 25 items.
  /// Individual items cannot be longer than 64 characters. For better results, you should make them upper/lowercase and trim the whitespaces.
  ///
  /// Any attribute with an invalid key or value will be ignored.
  BatchProfileAttributeEditor setStringListAttribute(String key, List<String> value);

  /// Delete an attribute using its key.
  ///
  /// If the attribute doesn't exist, this method is silently ignored.
  BatchProfileAttributeEditor removeAttribute(String key);

  /// Add a string value in the specified array attribute.
  /// If empty, the array will automatically be created.
  ///
  /// The key must be a string of letters, numbers or
  /// underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  ///
  /// The value cannot be empty or longer than 64 characters.
  BatchProfileAttributeEditor addToArray(String key, String tag);

  /// Delete a string value from the specified array attribute.
  ///
  /// If the array is empty, it will be deleted.
  ///
  /// The key must be a string of letters, numbers or
  /// underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  ///
  /// If the specified array doesn't exist, this method will silently do nothing.
  BatchProfileAttributeEditor removeFromArray(String collection, String tag);

  /// Save all of the pending changes. This action cannot be undone.
  void save();
}

/// Object holding data to be associated to an event.
///
/// Events support at most 10 tags and 15 attributes. Event data that is over
/// the limit will be discarded.
/// Note: those limits are enforced by the native SDKs, they might be different
/// depending on the underlying SDK version your project is using.
///
/// Keys should be strings composed of letters, numbers or underscores
/// (\[a-z0-9_\]) and can't be longer than 30 characters.
class BatchEventAttributes {

  Map<String, TypedAttribute> _attributes = new HashMap();


  /// Add a string attribute for the given key.
  ///
  /// The attribute key should be a string composed of letters, numbers
  /// or underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  ///
  /// The attribute string value can't be empty or longer than 64 characters.
  /// For better results, you should trim/lowercase your strings
  /// and use slugs when possible.
  BatchEventAttributes putString(String key, String value) {
    _attributes[key.toLowerCase()] = TypedAttribute(type: TypedAttributeType.string, value: value);
    return this;
  }

  /// Add a URL attribute for the given key.
  ///
  /// The attribute key should be a string composed of letters, numbers
  /// or underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  ///
  /// While the value is an Uri instance, it must be a valid URL and
  /// not be longer than 2048 characters.
  BatchEventAttributes putUrl(String key, Uri value) {
    _attributes[key.toLowerCase()] = TypedAttribute(type: TypedAttributeType.url, value: value.toString());
    return this;
  }

  /// Add a boolean attribute for the given key.
  ///
  /// The attribute key should be a string composed of letters, numbers
  /// or underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  BatchEventAttributes putBoolean(String key, bool value) {
    _attributes[key.toLowerCase()] = TypedAttribute(type: TypedAttributeType.boolean, value: value);
    return this;
  }

  /// Add an integer attribute for the given key.
  ///
  /// The attribute key should be a string composed of letters, numbers
  /// or underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  BatchEventAttributes putInteger(String key, int value) {
    _attributes[key.toLowerCase()] = TypedAttribute(type: TypedAttributeType.integer, value: value);
    return this;
  }

  /// Add a double attribute for the given key.
  ///
  /// The attribute key should be a string composed of letters, numbers
  /// or underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  BatchEventAttributes putDouble(String key, double value) {
    _attributes[key.toLowerCase()] = TypedAttribute(type: TypedAttributeType.float, value: value);
    return this;
  }

  /// Add a DateTime attribute for the given key.
  ///
  /// The attribute key should be a string composed of letters, numbers
  /// or underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  ///
  /// Date attribute values are sent in UTC to Batch. If you notice that the reported
  /// time may be off, try making an UTC DateTime for consistency.
  BatchEventAttributes putDate(String key, DateTime value) {
    _attributes[key.toLowerCase()] = TypedAttribute(
        type: TypedAttributeType.date,
        value: value.toUtc().millisecondsSinceEpoch);
    return this;
  }

  /// Add a BatchEventData attribute for the given key.
  ///
  /// The attribute key should be a string composed of letters, numbers
  /// or underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  BatchEventAttributes putObject(String key, BatchEventAttributes value) {
    _attributes[key.toLowerCase()] = TypedAttribute(type: TypedAttributeType.object, value: value.internalGetBridgeRepresentation());
    return this;
  }

  /// Add an Object List attribute for the given key.
  ///
  /// The attribute key should be a string composed of letters, numbers
  /// or underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  BatchEventAttributes putObjectList(String key, List<BatchEventAttributes> value) {
    List array = [];
    value.forEach((element) {
      array.add(element.internalGetBridgeRepresentation());
    });
    _attributes[key.toLowerCase()] = TypedAttribute(type: TypedAttributeType.object_array, value: array);
    return this;
  }

  /// Add a String List attribute for the given key.
  ///
  /// The attribute key should be a string composed of letters, numbers
  /// or underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  BatchEventAttributes putStringList(String key, List<String> value) {
    _attributes[key.toLowerCase()] = TypedAttribute(type: TypedAttributeType.string_array, value: value);
    return this;
  }

  /// Internal method. Get the serializable representation of this object
  ///
  /// <nodoc>
  @protected
  Map internalGetBridgeRepresentation() {
    return _attributes.map((key, value) => MapEntry(key, value.toBridgeRepresentation()));
  }
}
