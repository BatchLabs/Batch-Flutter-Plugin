import 'dart:collection';

import 'package:batch_flutter/src/batch_logger.dart';
import 'package:batch_flutter/src/typed_attribute.dart';
import 'package:batch_flutter/src/user_data_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Provides user related functionality, such as custom data and events.
/// Do not instanciate this: use the `instance` static property.
class BatchUser {
  static const MethodChannel _channel =
      const MethodChannel('batch_flutter.user');

  /// Batch User module singleton.
  static BatchUser instance = new BatchUser();

  /// Get the user identifier.
  /// Returns null if you didn't set one.
  Future<String?> get identifier async {
    return await _channel.invokeMethod('user.getIdentifier');
  }

  /// Get the language override.
  /// Returns null if you didn't set a custom language.
  Future<String?> get language async {
    return await _channel.invokeMethod('user.getLanguage');
  }

  /// Get the region override.
  /// Returns null if you didn't set a custom language.
  Future<String?> get region async {
    return await _channel.invokeMethod('user.getRegion');
  }

  /// Get the unique Installation ID, generated by the SDK.
  Future<String?> get installationID async {
    return await _channel.invokeMethod('user.getInstallationID');
  }

  /// Instanciate a new [BatchUserDataEditor] to edit custom data attributes and tags.
  ///
  /// See [BatchUserDataEditor]'s documentation for more info.
  BatchUserDataEditor newEditor() {
    return BatchUserDataEditorImpl(_channel);
  }

  /// Track an event.
  ///
  /// The event name is required and must not be empty. It should be composed of letters,
  /// numbers or underscores (\[a-z0-9_\]) and can’t be longer than 30 characters.
  ///
  /// The event label is an optional string, which must not be empty or longer
  /// than 200 characters. If the label is too long, it will be ignored.
  ///
  /// The event data is an optional object holding attributes and tags related
  /// to the event. See [BatchEventData]'s documentation for more info.
  void trackEvent({required String name, String? label, BatchEventData? data}) {
    Map eventArgs = {"name": name, "label": label};
    if (data != null) {
      eventArgs["event_data"] = data.internalGetBridgeRepresentation();
    }
    _channel.invokeMethod("user.track.event", eventArgs);
  }

  /// Track a transaction.
  void trackTransaction(double amount) {
    _channel.invokeMethod("user.track.transaction", {"amount": amount});
  }

  /// Track a geolocation update.
  ///
  /// Batch does not ask for location permission or acquire user location on
  /// your behalf. Acquire location permission and values on your own and
  /// communicate them to Batch (if needed) using this method.
  void trackLocation({required double latitude, required double longitude}) {
    _channel.invokeMethod(
        "user.track.location", {"latitude": latitude, "longitude": longitude});
  }

  /// Read the saved attributes.
  /// Reading is asynchronous so as not to interfere with saving operations.
  Future<Map<String, BatchUserAttribute>> get attributes async {
    Map<String, Map<dynamic, dynamic>>? rawAttributes =
        await _channel.invokeMapMethod("user.fetch.attributes");

    if (rawAttributes == null) {
      throw BatchUserInternalError(code: 1);
    }

    Map<String, BatchUserAttribute> attributes = {};
    rawAttributes.forEach((key, rawTypedValue) {
      dynamic castedValue;
      BatchUserAttributeType type;
      dynamic rawValue = rawTypedValue["value"];

      if (rawValue == null) {
        throw BatchUserInternalError(code: 2);
      }

      String? rawType = rawTypedValue["type"];
      switch (rawType) {
        case "d":
          type = BatchUserAttributeType.date;
          int rawDate = rawValue as int;
          castedValue =
              DateTime.fromMillisecondsSinceEpoch(rawDate, isUtc: true);
          break;
        case "i":
          type = BatchUserAttributeType.integer;
          castedValue = rawValue as int;
          break;
        case "f":
          type = BatchUserAttributeType.double;
          castedValue = rawValue as double;
          break;
        case "b":
          type = BatchUserAttributeType.boolean;
          castedValue = rawValue as bool;
          break;
        case "s":
          type = BatchUserAttributeType.string;
          castedValue = rawValue as String;
          break;
        case "u":
          type = BatchUserAttributeType.url;
          castedValue = Uri.parse(rawValue as String);
          break;
        default:
          throw BatchUserInternalError(code: 3);
      }

      attributes[key] = BatchUserAttribute(type: type, value: castedValue);
    });
    return attributes;
  }

  /// Read the saved tag collections.
  /// Reading is asynchronous so as not to interfere with saving operations.
  Future<Map<String, List<String>>> get tagCollections async {
    Map<String, List<dynamic>>? rawTagCollections =
        await _channel.invokeMapMethod("user.fetch.tags");

    if (rawTagCollections == null) {
      throw BatchUserInternalError(code: 4);
    }

    Map<String, List<String>> castedTagCollections = {};
    rawTagCollections.forEach((key, value) {
      List<String> tags = List.castFrom(value);
      castedTagCollections[key] = tags;
    });
    return castedTagCollections;
  }
}

/// Batch's user data editor.
/// This object is used to transactionally edit user data. Calls can be chained
/// in a builder-like fashion.
/// Once you're done with your changes, call [BatchUserDataEditor.save] to persist your changes.
abstract class BatchUserDataEditor {
  /// Set the application language. Overrides Batch's automatically detected value.
  ///
  /// `null` deletes the override: Batch will autodetect the user language.
  BatchUserDataEditor setLanguage(String? language);

  /// Set the application region. Overrides Batch's automatically detected value.
  ///
  /// `null` deletes the override: Batch will autodetect the user region.
  BatchUserDataEditor setRegion(String? region);

  /// Set the custom user identifier.
  ///
  /// Be careful: you should make sure the identifier uniquely identifies a user.
  /// When pushing using an identifier, all installations with that identifier will get the Push,
  /// which can cause some privacy issues if done wrong.
  BatchUserDataEditor setIdentifier(String? identifier);

  /// Set a string attribute for a key.
  ///
  /// Attribute's key cannot be empty. It should be made of letters, numbers or underscores (\[a-z0-9_\])
  /// and can't be longer than 30 characters.
  /// String attribut values are non-empty strings and can't be longer than 64 characters.
  ///
  /// Any attribute with an invalid key or value will be ignored.
  BatchUserDataEditor setStringAttribute(String key, String value);

  /// Set an integer attribute for a key.
  ///
  /// Attribute's key cannot be empty. It should be made of letters, numbers or underscores (\[a-z0-9_\])
  /// and can't be longer than 30 characters.
  ///
  /// Any attribute with an invalid key or value will be ignored.
  BatchUserDataEditor setIntegerAttribute(String key, int value);

  /// Set a double attribute for a key.
  ///
  /// Attribute's key cannot be empty. It should be made of letters, numbers or underscores (\[a-z0-9_\])
  /// and can't be longer than 30 characters.
  ///
  /// Any attribute with an invalid key or value will be ignored.
  BatchUserDataEditor setDoubleAttribute(String key, double value);

  /// Set a boolean attribute for a key.
  ///
  /// Attribute's key cannot be empty. It should be made of letters, numbers or underscores (\[a-z0-9_\])
  /// and can't be longer than 30 characters.
  ///
  /// Any attribute with an invalid key or value will be ignored.
  BatchUserDataEditor setBooleanAttribute(String key, bool value);

  /// Set a URL attribute for a key.
  ///
  /// Attribute's key cannot be empty. It should be made of letters, numbers or underscores (\[a-z0-9_\])
  /// and can't be longer than 30 characters.
  ///
  /// While the value is an Uri instance, it must be a valid URL and
  /// must not be longer than 2048 characters.
  ///
  /// Any attribute with an invalid key or value will be ignored.
  BatchUserDataEditor setUrlAttribute(String key, Uri value);

  /// Set a Date attribute for a key.
  ///
  /// Attribute's key cannot be empty. It should be made of letters, numbers or underscores (\[a-z0-9_\])
  /// and can't be longer than 30 characters.
  ///
  /// Date attribute values are sent in UTC to Batch. If you notice that the reported
  /// time may be off, try making an UTC DateTime for consistency.
  ///
  /// Any attribute with an invalid key or value will be ignored.
  BatchUserDataEditor setDateTimeAttribute(String key, DateTime value);

  /// Delete an attribute using its key.
  ///
  /// If the attribute doesn't exist, this method is silently ignored.
  BatchUserDataEditor removeAttribute(String key);

  /// Delete all attributes.
  BatchUserDataEditor clearAttributes();

  /// Add a tag to a collection.
  ///
  /// If the collection doesn't exist, it will be created.
  ///
  /// The tag collection name must be a string of letters, numbers or
  /// underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  ///
  /// The tag cannot be empty or longer than 64 characters.
  BatchUserDataEditor addTag(String collection, String tag);

  /// Delete a tag from a collection.
  ///
  /// If the collection is empty, it will be deleted.
  ///
  /// The tag collection name must be a string of letters, numbers or
  /// underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  ///
  /// If the tag doesn't exist, this method will silently do nothing.
  BatchUserDataEditor removeTag(String collection, String tag);

  /// Removes all tags from a collection.
  ///
  /// The tag collection name must be a string of letters, numbers or
  /// underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  BatchUserDataEditor clearTagCollection(String collection);

  /// Removes all tags.
  BatchUserDataEditor clearTags();

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
class BatchEventData {
  static final RegExp _attributeKeyRegexp = RegExp("^[a-zA-Z0-9_]{1,30}\$");
  static const int _maxStringLength = 64;

  Set<String> _tags = new HashSet();
  Map<String, TypedAttribute> _attributes = new HashMap();

  /// Add a tag.
  /// Collections are not supported.
  ///
  /// Tags can't be longer than 64 characters, and can't be empty.
  /// For better results, you should trim/lowercase your strings,
  /// and use slugs when possible.
  BatchEventData addTag(String tag) {
    if (tag.length == 0 || tag.length > _maxStringLength) {
      BatchLogger.public(
          "BatchEventData - Invalid tag. Tags are not allowed to " +
              "be longer than 64 characters (bytes) and must not be empty. " +
              "Ignoring tag '$tag'.");
      return this;
    }
    _tags.add(tag.toLowerCase());
    return this;
  }

  /// Add a string attribute for the given key.
  ///
  /// The attribute key should be a string composed of letters, numbers
  /// or underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  ///
  /// The attribute string value can't be empty or longer than 64 characters.
  /// For better results, you should trim/lowercase your strings
  /// and use slugs when possible.
  BatchEventData putString(String key, String value) {
    if (_validateAttributeKey(key)) {
      _attributes[key.toLowerCase()] =
          TypedAttribute(type: TypedAttributeType.string, value: value);
    }
    return this;
  }

  /// Add a URL attribute for the given key.
  ///
  /// The attribute key should be a string composed of letters, numbers
  /// or underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  ///
  /// While the value is an Uri instance, it must be a valid URL and
  /// not be longer than 2048 characters.
  BatchEventData putUrl(String key, Uri value) {
    if (_validateAttributeKey(key)) {
      _attributes[key.toLowerCase()] =
          TypedAttribute(type: TypedAttributeType.url, value: value.toString());
    }
    return this;
  }

  /// Add a boolean attribute for the given key.
  ///
  /// The attribute key should be a string composed of letters, numbers
  /// or underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  BatchEventData putBoolean(String key, bool value) {
    if (_validateAttributeKey(key)) {
      _attributes[key.toLowerCase()] =
          TypedAttribute(type: TypedAttributeType.boolean, value: value);
    }
    return this;
  }

  /// Add an integer attribute for the given key.
  ///
  /// The attribute key should be a string composed of letters, numbers
  /// or underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  BatchEventData putInteger(String key, int value) {
    if (_validateAttributeKey(key)) {
      _attributes[key.toLowerCase()] =
          TypedAttribute(type: TypedAttributeType.integer, value: value);
    }
    return this;
  }

  /// Add a double attribute for the given key.
  ///
  /// The attribute key should be a string composed of letters, numbers
  /// or underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  BatchEventData putDouble(String key, double value) {
    if (_validateAttributeKey(key)) {
      _attributes[key.toLowerCase()] =
          TypedAttribute(type: TypedAttributeType.float, value: value);
    }
    return this;
  }

  /// Add a DateTime attribute for the given key.
  ///
  /// The attribute key should be a string composed of letters, numbers
  /// or underscores (\[a-z0-9_\]) and can't be longer than 30 characters.
  ///
  /// Date attribute values are sent in UTC to Batch. If you notice that the reported
  /// time may be off, try making an UTC DateTime for consistency.
  BatchEventData putDate(String key, DateTime value) {
    if (_validateAttributeKey(key)) {
      _attributes[key.toLowerCase()] = TypedAttribute(
          type: TypedAttributeType.date,
          value: value.toUtc().millisecondsSinceEpoch);
    }
    return this;
  }

  /// Internal method. Get the serializable representation of this object
  ///
  /// <nodoc>
  @protected
  Map internalGetBridgeRepresentation() {
    return {
      "attributes": _attributes
          .map((key, value) => MapEntry(key, value.toBridgeRepresentation())),
      "tags": _tags.toList()
    };
  }

  bool _validateAttributeKey(String key) {
    if (!_attributeKeyRegexp.hasMatch(key)) {
      BatchLogger.public(
          "BatchEventData - Invalid attribute key. Please make sure that " +
              "the key is made of letters, underscores and numbers only " +
              "(a-zA-Z0-9_). It also can't be longer than 30 characters. " +
              "Ignoring attribute '$key'.");
      return false;
    }
    return true;
  }
}

/// Object representing a user attribute.
/// An attribute is represented by it's type, which maches the one you've used
/// when setting the attribute, and its value.
///
/// You can get the attribute using the generic getter, or use the typed ones
/// that will cast the value or return null if the type doesn't match.
class BatchUserAttribute {
  BatchUserAttribute({required this.type, required this.value});

  final BatchUserAttributeType type;
  final dynamic value;

  String? getStringValue() {
    if (type == BatchUserAttributeType.string) {
      return value;
    }
    return null;
  }

  DateTime? getDateValue() {
    if (type == BatchUserAttributeType.date) {
      return value;
    }
    return null;
  }

  int? getIntegerValue() {
    if (type == BatchUserAttributeType.integer) {
      return value;
    }
    return null;
  }

  double? getDoubleValue() {
    if (type == BatchUserAttributeType.double) {
      return value;
    }
    return null;
  }

  bool? getBoolValue() {
    if (type == BatchUserAttributeType.boolean) {
      return value;
    }
    return null;
  }

  Uri? getUriValue() {
    if (type == BatchUserAttributeType.url) {
      return value;
    }
    return null;
  }

  @override
  String toString() {
    return ("${value.toString()} (${type.toString()})");
  }
}

/// User attribute types.
enum BatchUserAttributeType { string, boolean, integer, double, date, url }

/// Error thrown when an internal user module error happens.
class BatchUserInternalError extends Error {
  BatchUserInternalError({required this.code});

  final int code;

  @override
  String toString() {
    return "BatchUserInternalError: An internal BatchUser error has occurred, something might be wrong with the native implementation. Code: $code";
  }
}
