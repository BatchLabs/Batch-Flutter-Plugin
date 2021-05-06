import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../batch_user.dart';

/// Private class: User data operations
/// <nodoc>
@protected
enum UserDataOperationKind {
  setLanguage,
  setRegion,
  setIdentifier,
  setAttribute,
  removeAttribute,
  clearAttributes,
  addTag,
  removeTag,
  clearTags,
  clearTagCollections
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
      case UserDataOperationKind.clearTagCollections:
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
       "kind": kind.toBridgeRepresentation(),
       ...arguments,
     };
  }
}

/// Private class: Do not instanciate this: use the `newEditor()` method on `BatchUser`.
/// <nodoc>
@protected
class BatchUserDataEditorImpl implements BatchUserDataEditor {
  List<UserDataOperation> _operationQueue = [];

  BatchUserDataEditorImpl(MethodChannel userMethodChannel) : this._userMethodChannel = userMethodChannel;

  MethodChannel _userMethodChannel;

  @override
  BatchUserDataEditor setLanguage(String? language) {
    if (language != null && language.length == 0) {
      //TODO: Log
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
      //TODO: Log
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
      //TODO: Log
      return this;
    }

    _enqueueOperation(UserDataOperationKind.setRegion, {
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

    _enqueueOperation(UserDataOperationKind.clearTagCollections, {
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

    _enqueueOperation(UserDataOperationKind.setAttribute, {
      "type": "string",
      "value": value,
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
      "operations": _operationQueue.map((e) => e.toBridgeRepresentation()),
    };
    _operationQueue.clear();
    _userMethodChannel.invokeMethod("user.edit", bridgeOperations);
  }

  bool _ensureValidAttributeKey(String key) {
    //TODO: Implement attribute key validation
    return true;
  }

  bool _ensureValidTagCollection(String collection) {
    //TODO: Implement attribute key validation
    return true;
  }

  bool _ensureValidTag(String tag) {
    //TODO: Implement attribute key validation
    return true;
  }

  void _enqueueOperation(UserDataOperationKind kind, Map<String, dynamic> arguments) {
    _operationQueue.add(UserDataOperation(kind: kind, arguments: arguments));
  }
}