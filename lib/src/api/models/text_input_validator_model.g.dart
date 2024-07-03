// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_input_validator_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextInputValidatorModel _$TextInputValidatorModelFromJson(Map json) =>
    TextInputValidatorModel(
      name: json['name'] as String,
      pattern: json['pattern'] as String,
      errorMessage: json['errorMessage'] as String,
    );

Map<String, dynamic> _$TextInputValidatorModelToJson(
        TextInputValidatorModel instance) =>
    <String, dynamic>{
      'pattern': instance.pattern,
      'name': instance.name,
      'errorMessage': instance.errorMessage,
    };
