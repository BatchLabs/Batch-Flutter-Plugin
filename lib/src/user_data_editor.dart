import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../batch_user.dart';
import 'batch_logger.dart';

/// Private class: User data operations
/// <nodoc>
@protected
enum UserDataOperationKind {
  setLanguage,
  setRegion,
  setIdentifier,
  setEmail,
  setEmailMarketingSubscriptionState,
  setAttributionId,
  setAttribute,
  removeAttribute,
  clearAttributes,
  addTag,
  removeTag,
  clearTags,
  clearTagCollection
}

extension UserDataOperationKindBridge on UserDataOperationKind {
  String toBridgeRepresentation() {
    switch (this) {
      case UserDataOperationKind.setLanguage:
        return "SET_LANGUAGE";
      case UserDataOperationKind.setRegion:
        return "SET_REGION";
      case UserDataOperationKind.setIdentifier:
        return "SET_IDENTIFIER";
      case UserDataOperationKind.setEmail:
        return "SET_EMAIL";
      case UserDataOperationKind.setEmailMarketingSubscriptionState:
        return "SET_EMAIL_MARKETING_SUBSCRIPTION";
      case UserDataOperationKind.setAttributionId:
        return "SET_ATTRIBUTION_ID";
      case UserDataOperationKind.setAttribute:
        return "SET_ATTRIBUTE";
      case UserDataOperationKind.removeAttribute:
        return "REMOVE_ATTRIBUTE";
      case UserDataOperationKind.clearAttributes:
        return "CLEAR_ATTRIBUTES";
      case UserDataOperationKind.addTag:
        return "ADD_TAG";
      case UserDataOperationKind.removeTag:
        return "REMOVE_TAG";
      case UserDataOperationKind.clearTags:
        return "CLEAR_TAGS";
      case UserDataOperationKind.clearTagCollection:
        return "CLEAR_TAG_COLLECTION";
    }
  }
}

/// Private class: Represents a user data operation
/// <nodoc>
@protected
class UserDataOperation {
  UserDataOperation({required this.kind, required this.arguments});

  final UserDataOperationKind kind;
  final Map<String, dynamic> arguments;

  Map<String, dynamic> toBridgeRepresentation() {
    return {
      "operation": kind.toBridgeRepresentation(),
      ...arguments,
    };
  }
}

/// Private class: Do not instanciate this: use the `newEditor()` method on `BatchUser`.
/// <nodoc>
@protected
class BatchUserDataEditorImpl implements BatchUserDataEditor {
  static final RegExp _attributeKeyRegexp = RegExp("^[a-zA-Z0-9_]{1,30}\$");
  static const int _maxStringLength = 64;

  List<UserDataOperation> _operationQueue = [];

  BatchUserDataEditorImpl(MethodChannel userMethodChannel)
      : this._userMethodChannel = userMethodChannel;

  MethodChannel _userMethodChannel;

  @override
  BatchUserDataEditor setLanguage(String? language) {
    if (language != null && language.length == 0) {
      BatchLogger.public(
          "BatchUserDataEditor - Language override cannot be empty. If " +
              "you meant to un-set the language, please use null.");
      return this;
    }

    _enqueueOperation(UserDataOperationKind.setLanguage, {
      "value": language,
    });

    return this;
  }

  @override
  BatchUserDataEditor setRegion(String? region) {
    if (region != null && region.length == 0) {
      BatchLogger.public(
          "BatchUserDataEditor - Region override cannot be empty. If " +
              "you meant to un-set the region, please use null.");
      return this;
    }

    _enqueueOperation(UserDataOperationKind.setRegion, {
      "value": region,
    });

    return this;
  }

  @override
  BatchUserDataEditor setIdentifier(String? identifier) {
    if (identifier != null && identifier.length == 0) {
      BatchLogger.public(
          "BatchUserDataEditor - Identifier cannot be empty. If " +
              "you meant to un-set the identifier, please use null.");
      return this;
    }

    _enqueueOperation(UserDataOperationKind.setIdentifier, {
      "value": identifier,
    });

    return this;
  }

  @override
  BatchUserDataEditor setEmail(String? address) {
    if (address != null && address.length == 0) {
      BatchLogger.public(
          "BatchUserDataEditor - Email cannot be empty. If " +
              "you meant to un-set the email, please use null.");
      return this;
    }

    _enqueueOperation(UserDataOperationKind.setEmail, {
      "value": address,
    });
    return this;
  }

  @override
  BatchUserDataEditor setEmailMarketingSubscriptionState(BatchEmailSubscriptionState state) {
    _enqueueOperation(UserDataOperationKind.setEmailMarketingSubscriptionState, {
      "value": state.name,
    });
    return this;
  }

  @override
  BatchUserDataEditor setAttributionIdentifier(String? identifier) {
    if (identifier != null && identifier.length == 0) {
      BatchLogger.public(
          "BatchUserDataEditor - Attribution identifier cannot be empty. If " +
              "you meant to un-set the attribution identifier, please use null.");
      return this;
    }
    _enqueueOperation(UserDataOperationKind.setAttributionId, {
      "value": identifier,
    });
    return this;
  }

  @override
  BatchUserDataEditor addTag(String collection, String tag) {
    if (!_ensureValidTagCollection(collection)) {
      return this;
    }

    if (!_ensureValidTag(tag)) {
      return this;
    }

    _enqueueOperation(UserDataOperationKind.addTag, {
      "collection": collection,
      "tag": tag,
    });

    return this;
  }

  @override
  BatchUserDataEditor removeTag(String collection, String tag) {
    if (!_ensureValidTagCollection(collection)) {
      return this;
    }

    if (!_ensureValidTag(tag)) {
      return this;
    }

    _enqueueOperation(UserDataOperationKind.removeTag, {
      "collection": collection,
      "tag": tag,
    });

    return this;
  }

  @override
  BatchUserDataEditor clearTagCollection(String collection) {
    if (!_ensureValidTagCollection(collection)) {
      return this;
    }

    _enqueueOperation(UserDataOperationKind.clearTagCollection, {
      "collection": collection,
    });

    return this;
  }

  @override
  BatchUserDataEditor clearTags() {
    _enqueueOperation(UserDataOperationKind.clearTags, {});

    return this;
  }

  @override
  BatchUserDataEditor setBooleanAttribute(String key, bool value) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }

    _enqueueOperation(UserDataOperationKind.setAttribute, {
      "key": key,
      "type": "boolean",
      "value": value,
    });

    return this;
  }

  @override
  BatchUserDataEditor setDateTimeAttribute(String key, DateTime value) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }

    _enqueueOperation(UserDataOperationKind.setAttribute, {
      "key": key,
      "type": "date",
      "value": value.toUtc().millisecondsSinceEpoch,
    });

    return this;
  }

  @override
  BatchUserDataEditor setDoubleAttribute(String key, double value) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }

    _enqueueOperation(UserDataOperationKind.setAttribute, {
      "key": key,
      "type": "float",
      "value": value,
    });

    return this;
  }

  @override
  BatchUserDataEditor setIntegerAttribute(String key, int value) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }

    _enqueueOperation(UserDataOperationKind.setAttribute, {
      "key": key,
      "type": "integer",
      "value": value,
    });

    return this;
  }

  @override
  BatchUserDataEditor setStringAttribute(String key, String value) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }

    if (value.length <= _maxStringLength) {
      _enqueueOperation(UserDataOperationKind.setAttribute, {
        "key": key,
        "type": "string",
        "value": value,
      });
    } else {
      BatchLogger.public(
          "BatchUserDataEditor - Invalid attribute string value. String " +
              "attributes cannot be longer than 64 characters (bytes). " +
              "Ignoring attribute '$key'.");
    }

    return this;
  }

  @override
  BatchUserDataEditor setUrlAttribute(String key, Uri value) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }

    _enqueueOperation(UserDataOperationKind.setAttribute, {
      "key": key,
      "type": "url",
      "value": value.toString(),
    });

    return this;
  }

  @override
  BatchUserDataEditor removeAttribute(String key) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }

    _enqueueOperation(UserDataOperationKind.removeAttribute, {
      "key": key,
    });

    return this;
  }

  @override
  BatchUserDataEditor clearAttributes() {
    _enqueueOperation(UserDataOperationKind.clearAttributes, {});
    return this;
  }

  @override
  void save() {
    Map bridgeOperations = {
      "operations":
          _operationQueue.map((e) => e.toBridgeRepresentation()).toList(),
    };
    _operationQueue.clear();
    _userMethodChannel.invokeMethod("user.edit", bridgeOperations);
  }

  bool _ensureValidAttributeKey(String key) {
    if (!_attributeKeyRegexp.hasMatch(key)) {
      BatchLogger.public(
          "BatchUserDataEditor - Invalid attribute key. Please make sure that " +
              "the key is made of letters, underscores and numbers only " +
              "(a-zA-Z0-9_). It also can't be longer than 30 characters. " +
              "Ignoring attribute '$key'.");
      return false;
    }
    return true;
  }

  bool _ensureValidTagCollection(String collection) {
    if (!_attributeKeyRegexp.hasMatch(collection)) {
      BatchLogger.public(
          "BatchUserDataEditor - Invalid collection. Please make sure that " +
              "the collection is made of letters, underscores and numbers only " +
              "(a-zA-Z0-9_). It also can't be longer than 30 characters. " +
              "Ignoring collection '$collection'.");
      return false;
    }
    return true;
  }

  bool _ensureValidTag(String tag) {
    if (tag.length == 0 || tag.length > _maxStringLength) {
      BatchLogger.public(
          "BatchUserDataEditor - Invalid tag. Tags are not allowed to " +
              "be longer than 64 characters (bytes) and must not be empty. " +
              "Ignoring operation on tag '$tag'.");
      return false;
    }
    return true;
  }

  void _enqueueOperation(
      UserDataOperationKind kind, Map<String, dynamic> arguments) {
    _operationQueue.add(UserDataOperation(kind: kind, arguments: arguments));
  }
}
