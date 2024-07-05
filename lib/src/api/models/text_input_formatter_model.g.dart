// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_input_formatter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoneTextInputFormatter _$NoneTextInputFormatterFromJson(Map json) =>
    NoneTextInputFormatter();

Map<String, dynamic> _$NoneTextInputFormatterToJson(
        NoneTextInputFormatter instance) =>
    <String, dynamic>{
      'type': _$TextInputFormatterTypeEnumMap[instance.type]!,
    };

const _$TextInputFormatterTypeEnumMap = {
  TextInputFormatterType.none: 'none',
  TextInputFormatterType.regex: 'regex',
};

RegexTextInputFormatterModel _$RegexTextInputFormatterModelFromJson(Map json) =>
    RegexTextInputFormatterModel(
      name: json['name'] as String,
      pattern: json['pattern'] as String,
      allow: json['allow'] as bool? ?? true,
      caseSensitive: json['caseSensitive'] as bool? ?? true,
      dotAll: json['dotAll'] as bool? ?? false,
      multiLine: json['multiLine'] as bool? ?? false,
      unicode: json['unicode'] as bool? ?? false,
      replacementString: json['replacementString'] as String? ?? '',
    );

Map<String, dynamic> _$RegexTextInputFormatterModelToJson(
    RegexTextInputFormatterModel instance) {
  final val = <String, dynamic>{
    'name': instance.name,
    'type': _$TextInputFormatterTypeEnumMap[instance.type]!,
    'pattern': instance.pattern,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull(
      'caseSensitive', instance.caseSensitive, instance.caseSensitive, true);
  writeNotNull('dotAll', instance.dotAll, instance.dotAll, false);
  writeNotNull('multiLine', instance.multiLine, instance.multiLine, false);
  writeNotNull('unicode', instance.unicode, instance.unicode, false);
  writeNotNull('replacementString', instance.replacementString,
      instance.replacementString, '');
  writeNotNull('allow', instance.allow, instance.allow, true);
  return val;
}
