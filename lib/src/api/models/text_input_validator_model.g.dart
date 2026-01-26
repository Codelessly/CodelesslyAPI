// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_input_validator_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoneTextInputValidatorModel _$NoneTextInputValidatorModelFromJson(Map json) =>
    NoneTextInputValidatorModel();

Map<String, dynamic> _$NoneTextInputValidatorModelToJson(
  NoneTextInputValidatorModel instance,
) => <String, dynamic>{'type': _$TextInputValidatorTypeEnumMap[instance.type]!};

const _$TextInputValidatorTypeEnumMap = {
  TextInputValidatorType.none: 'none',
  TextInputValidatorType.required: 'required',
  TextInputValidatorType.regex: 'regex',
  TextInputValidatorType.url: 'url',
};

RequiredTextInputValidatorModel _$RequiredTextInputValidatorModelFromJson(
  Map json,
) => RequiredTextInputValidatorModel(
  errorMessage: json['errorMessage'] as String? ?? 'This field is required.',
);

Map<String, dynamic> _$RequiredTextInputValidatorModelToJson(
  RequiredTextInputValidatorModel instance,
) => <String, dynamic>{
  'type': _$TextInputValidatorTypeEnumMap[instance.type]!,
  'errorMessage': instance.errorMessage,
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
  RegexTextInputValidatorModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'type': _$TextInputValidatorTypeEnumMap[instance.type]!,
  'required': instance.required,
  'errorMessage': instance.errorMessage,
  'pattern': instance.pattern,
  'caseSensitive': instance.caseSensitive,
  'dotAll': instance.dotAll,
  'multiLine': instance.multiLine,
  'unicode': instance.unicode,
  'allow': instance.allow,
};

UrlTextInputValidatorModel _$UrlTextInputValidatorModelFromJson(Map json) =>
    UrlTextInputValidatorModel(
      errorMessage: json['errorMessage'] as String? ?? 'Invalid URL',
      required: json['required'] as bool? ?? false,
    );

Map<String, dynamic> _$UrlTextInputValidatorModelToJson(
  UrlTextInputValidatorModel instance,
) => <String, dynamic>{
  'type': _$TextInputValidatorTypeEnumMap[instance.type]!,
  'required': instance.required,
  'errorMessage': instance.errorMessage,
};
