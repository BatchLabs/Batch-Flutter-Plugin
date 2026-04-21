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
  setPhoneNumber,
  setSMSMarketingSubscription,
  setTopicPreferences,
  addToTopicPreferences,
  removeFromTopicPreferences,
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
      case ProfileDataOperationKind.setPhoneNumber:
        return "SET_PHONE_NUMBER";
      case ProfileDataOperationKind.setSMSMarketingSubscription:
        return "SET_SMS_MARKETING_SUBSCRIPTION";
      case ProfileDataOperationKind.setTopicPreferences:
        return "SET_TOPIC_PREFERENCES";
      case ProfileDataOperationKind.addToTopicPreferences:
        return "ADD_TO_TOPIC_PREFERENCES";
      case ProfileDataOperationKind.removeFromTopicPreferences:
        return "REMOVE_FROM_TOPIC_PREFERENCES";
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
  List<ProfileDataOperation> _operationQueue = [];

  BatchProfileAttributeEditorImpl(MethodChannel userMethodChannel)
      : this._userMethodChannel = userMethodChannel;

  MethodChannel _userMethodChannel;

  @override
  BatchProfileAttributeEditor setLanguage(String? language) {
    _enqueueOperation(ProfileDataOperationKind.setLanguage, {
      "value": language,
    });

    return this;
  }

  @override
  BatchProfileAttributeEditor setRegion(String? region) {
    _enqueueOperation(ProfileDataOperationKind.setRegion, {
      "value": region,
    });

    return this;
  }

  @override
  BatchProfileAttributeEditor setEmailAddress(String? address) {
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
  BatchProfileAttributeEditor setPhoneNumber(String? phoneNumber) {
    _enqueueOperation(ProfileDataOperationKind.setPhoneNumber, {
      "value": phoneNumber,
    });
    return this;
  }

  @override
  BatchProfileAttributeEditor setSMSMarketingSubscription(BatchSMSSubscriptionState state) {
    _enqueueOperation(ProfileDataOperationKind.setSMSMarketingSubscription, {
      "value": state.name,
    });
    return this;
  }

  @override
  BatchProfileAttributeEditor setTopicPreferences(List<String>? topics) {
    _enqueueOperation(ProfileDataOperationKind.setTopicPreferences, {
      "value": topics,
    });
    return this;
  }

  @override
  BatchProfileAttributeEditor addToTopicPreferences(List<String> topics) {
    _enqueueOperation(ProfileDataOperationKind.addToTopicPreferences, {
      "value": topics,
    });
    return this;
  }

  @override
  BatchProfileAttributeEditor removeFromTopicPreferences(List<String> topics) {
    _enqueueOperation(ProfileDataOperationKind.removeFromTopicPreferences, {
      "value": topics,
    });
    return this;
  }

  @override
  BatchProfileAttributeEditor addToArray(String key, String value) {
    _enqueueOperation(ProfileDataOperationKind.addToArray, {
      "key": key,
      "value": value,
    });

    return this;
  }

  @override
  BatchProfileAttributeEditor removeFromArray(String key, String value) {
    _enqueueOperation(ProfileDataOperationKind.removeFromArray, {
      "key": key,
      "value": value,
    });

    return this;
  }

  @override
  BatchProfileAttributeEditor setBooleanAttribute(String key, bool value) {
    _enqueueOperation(ProfileDataOperationKind.setAttribute, {
      "key": key,
      "type": "boolean",
      "value": value,
    });

    return this;
  }

  @override
  BatchProfileAttributeEditor setDateTimeAttribute(String key, DateTime value) {
    _enqueueOperation(ProfileDataOperationKind.setAttribute, {
      "key": key,
      "type": "date",
      "value": value.toUtc().millisecondsSinceEpoch,
    });
    return this;
  }

  @override
  BatchProfileAttributeEditor setDoubleAttribute(String key, double value) {
    _enqueueOperation(ProfileDataOperationKind.setAttribute, {
      "key": key,
      "type": "float",
      "value": value,
    });
    return this;
  }

  @override
  BatchProfileAttributeEditor setIntegerAttribute(String key, int value) {
    _enqueueOperation(ProfileDataOperationKind.setAttribute, {
      "key": key,
      "type": "integer",
      "value": value,
    });
    return this;
  }

  @override
  BatchProfileAttributeEditor setStringAttribute(String key, String value) {
    _enqueueOperation(ProfileDataOperationKind.setAttribute, {
      "key": key,
      "type": "string",
      "value": value,
    });
    return this;
  }

  @override
  BatchProfileAttributeEditor setStringListAttribute(String key, List<String> value) {
    _enqueueOperation(ProfileDataOperationKind.setAttribute, {
      "key": key,
      "type": "array",
      "value": value,
    });
    return this;
  }

  @override
  BatchProfileAttributeEditor setUrlAttribute(String key, Uri value) {
    _enqueueOperation(ProfileDataOperationKind.setAttribute, {
      "key": key,
      "type": "url",
      "value": value.toString(),
    });
    return this;
  }

  @override
  BatchProfileAttributeEditor removeAttribute(String key) {
    _enqueueOperation(ProfileDataOperationKind.removeAttribute, {
      "key": key,
    });

    return this;
  }

  @override
  void save() {
    Map bridgeOperations = {
      "operations": _operationQueue.map((e) => e.toBridgeRepresentation()).toList(),
    };
    _operationQueue.clear();
    _userMethodChannel.invokeMethod("profile.edit", bridgeOperations);
  }

  void _enqueueOperation(ProfileDataOperationKind kind, Map<String, dynamic> arguments) {
    _operationQueue.add(ProfileDataOperation(kind: kind, arguments: arguments));
  }
}
