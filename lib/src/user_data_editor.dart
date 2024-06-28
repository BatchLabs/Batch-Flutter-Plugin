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
  setEmailAddress,
  setEmailMarketingSubscription,
  setAttribute,
  removeAttribute,
  addToArray,
  removeFromArray,
}

extension UserDataOperationKindBridge on UserDataOperationKind {
  String toBridgeRepresentation() {
    switch (this) {
      case UserDataOperationKind.setLanguage:
        return "SET_LANGUAGE";
      case UserDataOperationKind.setRegion:
        return "SET_REGION";
      case UserDataOperationKind.setEmailAddress:
        return "SET_EMAIL_ADDRESS";
      case UserDataOperationKind.setEmailMarketingSubscription:
        return "SET_EMAIL_MARKETING_SUBSCRIPTION";
      case UserDataOperationKind.setAttribute:
        return "SET_ATTRIBUTE";
      case UserDataOperationKind.removeAttribute:
        return "REMOVE_ATTRIBUTE";
      case UserDataOperationKind.addToArray:
        return "ADD_TO_ARRAY";
      case UserDataOperationKind.removeFromArray:
        return "REMOVE_FROM_ARRAY";
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

/// Private class: Do not instantiate this: use the `newEditor()` method on `BatchUser`.
/// <nodoc>
@protected
class BatchUserDataEditorImpl implements BatchUserDataEditor {
  static final RegExp _attributeKeyRegexp = RegExp("^[a-zA-Z0-9_]{1,30}\$");
  static const int _maxStringLength = 64;
  static const int _maxStringArrayLength = 25;

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
  BatchUserDataEditor setEmailAddress(String? address) {
    if (address != null && address.length == 0) {
      BatchLogger.public(
          "BatchUserDataEditor - Email cannot be empty. If " +
              "you meant to un-set the email, please use null.");
      return this;
    }

    _enqueueOperation(UserDataOperationKind.setEmailAddress, {
      "value": address,
    });
    return this;
  }

  @override
  BatchUserDataEditor setEmailMarketingSubscription(BatchEmailSubscriptionState state) {
    _enqueueOperation(UserDataOperationKind.setEmailMarketingSubscription, {
      "value": state.name,
    });
    return this;
  }

  @override
  BatchUserDataEditor addToArray(String key, String value) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }

    if (!_ensureValidStringItem(value)) {
      return this;
    }

    _enqueueOperation(UserDataOperationKind.addToArray, {
      "key": key,
      "value": value,
    });

    return this;
  }

  @override
  BatchUserDataEditor removeFromArray(String key, String value) {
    if (!_ensureValidAttributeKey(key)) {
      return this;
    }

    if (!_ensureValidStringItem(value)) {
      return this;
    }

    _enqueueOperation(UserDataOperationKind.removeFromArray, {
      "key": key,
      "value": value,
    });

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
  BatchUserDataEditor setStringListAttribute(String key, List<String> value) {
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
    _enqueueOperation(UserDataOperationKind.setAttribute, {
      "key": key,
      "type": "array",
      "value": value,
    });
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
      UserDataOperationKind kind, Map<String, dynamic> arguments) {
    _operationQueue.add(UserDataOperation(kind: kind, arguments: arguments));
  }
}
