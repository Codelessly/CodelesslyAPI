// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_input_formatter_model.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$NoneTextInputFormatterModelOmitDefaults(
  NoneTextInputFormatterModel instance,
  Map<String, dynamic> json,
) {
  return json;
}

Map<String, dynamic> _$RegexTextInputFormatterModelOmitDefaults(
  RegexTextInputFormatterModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.caseSensitive, true)) json.remove('caseSensitive');
  if (isJsonDefault(instance.dotAll, false)) json.remove('dotAll');
  if (isJsonDefault(instance.multiLine, false)) json.remove('multiLine');
  if (isJsonDefault(instance.unicode, false)) json.remove('unicode');
  if (isJsonDefault(instance.replacementString, ''))
    json.remove('replacementString');
  if (isJsonDefault(instance.allow, true)) json.remove('allow');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoneTextInputFormatterModel _$NoneTextInputFormatterModelFromJson(Map json) =>
    NoneTextInputFormatterModel();

Map<String, dynamic> _$NoneTextInputFormatterModelToJson(
  NoneTextInputFormatterModel instance,
) => <String, dynamic>{'type': _$TextInputFormatterTypeEnumMap[instance.type]!};

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
  RegexTextInputFormatterModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'type': _$TextInputFormatterTypeEnumMap[instance.type]!,
  'pattern': instance.pattern,
  'caseSensitive': instance.caseSensitive,
  'dotAll': instance.dotAll,
  'multiLine': instance.multiLine,
  'unicode': instance.unicode,
  'replacementString': instance.replacementString,
  'allow': instance.allow,
};
