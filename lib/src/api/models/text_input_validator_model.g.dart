// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_input_validator_model.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$NoneTextInputValidatorModelOmitDefaults(
  NoneTextInputValidatorModel instance,
  Map<String, dynamic> json,
) {
  return json;
}

Map<String, dynamic> _$RequiredTextInputValidatorModelOmitDefaults(
  RequiredTextInputValidatorModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.errorMessage, 'This field is required.'))
    json.remove('errorMessage');
  return json;
}

Map<String, dynamic> _$RegexTextInputValidatorModelOmitDefaults(
  RegexTextInputValidatorModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.caseSensitive, true)) json.remove('caseSensitive');
  if (isJsonDefault(instance.dotAll, false)) json.remove('dotAll');
  if (isJsonDefault(instance.multiLine, false)) json.remove('multiLine');
  if (isJsonDefault(instance.unicode, false)) json.remove('unicode');
  if (isJsonDefault(instance.allow, true)) json.remove('allow');
  if (isJsonDefault(instance.required, false)) json.remove('required');
  return json;
}

Map<String, dynamic> _$UrlTextInputValidatorModelOmitDefaults(
  UrlTextInputValidatorModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.required, false)) json.remove('required');
  if (isJsonDefault(instance.errorMessage, 'Invalid URL'))
    json.remove('errorMessage');
  return json;
}

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
