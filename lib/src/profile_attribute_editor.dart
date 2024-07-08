import 'package:batch_flutter/batch_profile.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'batch_logger.dart';

/// Private class: User data operations
/// <nodoc>
@protected
enum ProfileDataOperationKind {
  setLanguage,
  setRegion,
  setEmailAddress,
  setEmailMarketingSubscription,
  setAttribute,
  removeAttribute,
  addToArray,
  removeFromArray,
}

extension ProfileDataOperationKindBridge on ProfileDataOperationKind {
  String toBridgeRepresentation() {
    switch (this) {
      case ProfileDataOperationKind.setLanguage:
        return "SET_LANGUAGE";
      case ProfileDataOperationKind.setRegion:
        return "SET_REGION";
      case ProfileDataOperationKind.setEmailAddress:
        return "SET_EMAIL_ADDRESS";
      case ProfileDataOperationKind.setEmailMarketingSubscription:
        return "SET_EMAIL_MARKETING_SUBSCRIPTION";
      case ProfileDataOperationKind.setAttribute:
        return "SET_ATTRIBUTE";
      case ProfileDataOperationKind.removeAttribute:
        return "REMOVE_ATTRIBUTE";
      case ProfileDataOperationKind.addToArray:
        return "ADD_TO_ARRAY";
      case ProfileDataOperationKind.removeFromArray:
        return "REMOVE_FROM_ARRAY";
    }
  }
}

/// Private class: Represents a user data operation
/// <nodoc>
@protected
class ProfileDataOperation {
  ProfileDataOperation({required this.kind, required this.arguments});

  final ProfileDataOperationKind kind;
  final Map<String, dynamic> arguments;

  Map<String, dynamic> toBridgeRepresentation() {
    return {
      "operation": kind.toBridgeRepresentation(),
      ...arguments,
    };
  }
}

/// Private class: Do not instantiate this: use the `newEditor()` method on `BatchUser`.
/// <nodoc>
@protected
class BatchProfileAttributeEditorImpl implements BatchProfileAttributeEditor {
  static final RegExp _attributeKeyRegexp = RegExp("^[a-zA-Z0-9_]{1,30}\$");
  static const int _maxStringLength = 64;
  static const int _maxStringArrayLength = 25;

  List<ProfileDataOperation> _operationQueue = [];

  BatchProfileAttributeEditorImpl(MethodChannel userMethodChannel)
      : this._userMethodChannel = userMethodChannel;

  MethodChannel _userMethodChannel;

  @override
  BatchProfileAttributeEditor setLanguage(String? language) {
    if (language != null && language.length == 0) {
      BatchLogger.public(
          "BatchUserDataEditor - Language override cannot be empty. If " +
              "you meant to un-set the language, please use null.");
      return this;
    }

    _enqueueOperation(ProfileDataOperationKind.setLanguage, {
      "value": language,
    });

    return this;
  }

  @override
  BatchProfileAttributeEditor setRegion(String? region) {
    if (region != null && region.length == 0) {
      BatchLogger.public(
          "BatchUserDataEditor - Region override cannot be empty. If " +
              "you meant to un-set the region, please use null.");
      return this;
    }

    _enqueueOperation(ProfileDataOperationKind.setRegion, {
      "value": region,
    });

    return this;
  }


  @override
  BatchProfileAttributeEditor setEmailAddress(String? address) {
    if (address != null && address.length == 0) {
      BatchLogger.public(
          "BatchUserDataEditor - Email cannot be empty. If " +
              "you meant to un-set the email, please use null.");
      return this;
    }

    _enqueueOperation(ProfileDataOperationKind.setEmailAddress, {
      "value": address,
    });
    return this;
  }

  @override
  BatchProfileAttributeEditor setEmailMarketingSubscription(BatchEmailSubscriptionState state) {
    _enqueueOperation(ProfileDataOperationKind.setEmailMarketingSubscription, {
      "value": state.name,
    });
    return this;
  }

  @override
  BatchProfileAttributeEditor addToArray(String key, String value) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }

    if (!_ensureValidStringItem(value)) {
      return this;
    }

    _enqueueOperation(ProfileDataOperationKind.addToArray, {
      "key": key,
      "value": value,
    });

    return this;
  }

  @override
  BatchProfileAttributeEditor removeFromArray(String key, String value) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }

    if (!_ensureValidStringItem(value)) {
      return this;
    }

    _enqueueOperation(ProfileDataOperationKind.removeFromArray, {
      "key": key,
      "value": value,
    });

    return this;
  }

  @override
  BatchProfileAttributeEditor setBooleanAttribute(String key, bool value) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }

    _enqueueOperation(ProfileDataOperationKind.setAttribute, {
      "key": key,
      "type": "boolean",
      "value": value,
    });

    return this;
  }

  @override
  BatchProfileAttributeEditor setDateTimeAttribute(String key, DateTime value) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }

    _enqueueOperation(ProfileDataOperationKind.setAttribute, {
      "key": key,
      "type": "date",
      "value": value.toUtc().millisecondsSinceEpoch,
    });

    return this;
  }

  @override
  BatchProfileAttributeEditor setDoubleAttribute(String key, double value) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }

    _enqueueOperation(ProfileDataOperationKind.setAttribute, {
      "key": key,
      "type": "float",
      "value": value,
    });

    return this;
  }

  @override
  BatchProfileAttributeEditor setIntegerAttribute(String key, int value) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }

    _enqueueOperation(ProfileDataOperationKind.setAttribute, {
      "key": key,
      "type": "integer",
      "value": value,
    });

    return this;
  }

  @override
  BatchProfileAttributeEditor setStringAttribute(String key, String value) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }

    if (value.length <= _maxStringLength) {
      _enqueueOperation(ProfileDataOperationKind.setAttribute, {
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
  BatchProfileAttributeEditor setStringListAttribute(String key, List<String> value) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }
    if (value.length > _maxStringArrayLength) {
      BatchLogger.public(
          "BatchUserDataEditor - List of string attributes must not be longer than 25 items. " +
              "Ignoring attribute '$key'.");
    }
    for (String item in value) {
      if(!_ensureValidStringItem(item)) {
        BatchLogger.public(
            "BatchUserDataEditor - List of string attributes must respect the string attribute limitations. " +
                "Ignoring attribute '$key'.");
        return this;
      }
    }
    _enqueueOperation(ProfileDataOperationKind.setAttribute, {
      "key": key,
      "type": "array",
      "value": value,
    });
    return this;
  }


  @override
  BatchProfileAttributeEditor setUrlAttribute(String key, Uri value) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }

    _enqueueOperation(ProfileDataOperationKind.setAttribute, {
      "key": key,
      "type": "url",
      "value": value.toString(),
    });

    return this;
  }

  @override
  BatchProfileAttributeEditor removeAttribute(String key) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }

    _enqueueOperation(ProfileDataOperationKind.removeAttribute, {
      "key": key,
    });

    return this;
  }

  @override
  void save() {
    Map bridgeOperations = {
      "operations":
          _operationQueue.map((e) => e.toBridgeRepresentation()).toList(),
    };
    _operationQueue.clear();
    _userMethodChannel.invokeMethod("profile.edit", bridgeOperations);
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

  bool _ensureValidStringItem(String item) {
    if (item.length == 0 || item.length > _maxStringLength) {
      BatchLogger.public(
          "BatchUserDataEditor - Invalid string item. String items are not allowed to " +
              "be longer than 64 characters (bytes) and must not be empty. " +
              "Ignoring operation on string '$item'.");
      return false;
    }
    return true;
  }

  void _enqueueOperation(
      ProfileDataOperationKind kind, Map<String, dynamic> arguments) {
    _operationQueue.add(ProfileDataOperation(kind: kind, arguments: arguments));
  }
}
