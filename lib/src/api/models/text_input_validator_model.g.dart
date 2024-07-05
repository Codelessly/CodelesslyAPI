// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_input_validator_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoneTextInputValidatorModel _$NoneTextInputValidatorModelFromJson(Map json) =>
    NoneTextInputValidatorModel();

Map<String, dynamic> _$NoneTextInputValidatorModelToJson(
        NoneTextInputValidatorModel instance) =>
    <String, dynamic>{
      'type': _$TextInputValidatorTypeEnumMap[instance.type]!,
    };

const _$TextInputValidatorTypeEnumMap = {
  TextInputValidatorType.none: 'none',
  TextInputValidatorType.required: 'required',
  TextInputValidatorType.regex: 'regex',
  TextInputValidatorType.url: 'url',
};

RequiredTextInputValidatorModel _$RequiredTextInputValidatorModelFromJson(
        Map json) =>
    RequiredTextInputValidatorModel();

Map<String, dynamic> _$RequiredTextInputValidatorModelToJson(
        RequiredTextInputValidatorModel instance) =>
    <String, dynamic>{
      'type': _$TextInputValidatorTypeEnumMap[instance.type]!,
    };

RegexTextInputValidatorModel _$RegexTextInputValidatorModelFromJson(Map json) =>
    RegexTextInputValidatorModel(
      name: json['name'] as String,
      pattern: json['pattern'] as String,
      errorMessage: json['errorMessage'] as String,
      caseSensitive: json['caseSensitive'] as bool? ?? true,
      dotAll: json['dotAll'] as bool? ?? false,
      multiLine: json['multiLine'] as bool? ?? false,
      unicode: json['unicode'] as bool? ?? false,
      allow: json['allow'] as bool? ?? true,
      required: json['required'] as bool? ?? false,
    );

Map<String, dynamic> _$RegexTextInputValidatorModelToJson(
    RegexTextInputValidatorModel instance) {
  final val = <String, dynamic>{
    'name': instance.name,
    'type': _$TextInputValidatorTypeEnumMap[instance.type]!,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('required', instance.required, instance.required, false);
  val['errorMessage'] = instance.errorMessage;
  val['pattern'] = instance.pattern;
  writeNotNull(
      'caseSensitive', instance.caseSensitive, instance.caseSensitive, true);
  writeNotNull('dotAll', instance.dotAll, instance.dotAll, false);
  writeNotNull('multiLine', instance.multiLine, instance.multiLine, false);
  writeNotNull('unicode', instance.unicode, instance.unicode, false);
  writeNotNull('allow', instance.allow, instance.allow, true);
  return val;
}

UrlTextInputValidatorModel _$UrlTextInputValidatorModelFromJson(Map json) =>
    UrlTextInputValidatorModel(
      errorMessage: json['errorMessage'] as String? ?? 'Invalid URL',
      required: json['required'] as bool? ?? false,
    );

Map<String, dynamic> _$UrlTextInputValidatorModelToJson(
    UrlTextInputValidatorModel instance) {
  final val = <String, dynamic>{
    'type': _$TextInputValidatorTypeEnumMap[instance.type]!,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('required', instance.required, instance.required, false);
  writeNotNull('errorMessage', instance.errorMessage, instance.errorMessage,
      'Invalid URL');
  return val;
}
