import 'package:flutter/widgets.dart';

/// Private class.
/// A typed attribute (value + underlying type)
/// <nodoc>
@protected
class TypedAttribute {
  TypedAttribute({required this.type, required this.value});

  final TypedAttributeType type;
  final dynamic value;

  Map toBridgeRepresentation() {
    return {"type": type.toBridgeRepresentation(), "value": value};
  }
}

/// Private enum.
/// A typed attribute's type
/// <nodoc>
@protected
enum TypedAttributeType { string, boolean, integer, float, date, url, object, string_array, object_array }

extension TypedAttributeTypeBridge on TypedAttributeType {
  String toBridgeRepresentation() {
    switch (this) {
      case TypedAttributeType.string:
        return "s";
      case TypedAttributeType.boolean:
        return "b";
      case TypedAttributeType.integer:
        return "i";
      case TypedAttributeType.float:
        return "f";
      case TypedAttributeType.date:
        return "d";
      case TypedAttributeType.url:
        return "u";
      case TypedAttributeType.object:
        return "o";
      case TypedAttributeType.string_array:
        return "sa";
      case TypedAttributeType.object_array:
        return "oa";
    }
  }
}
