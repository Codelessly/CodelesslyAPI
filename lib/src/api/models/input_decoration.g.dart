// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_decoration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InputDecorationModel _$InputDecorationModelFromJson(Map json) =>
    InputDecorationModel(
      icon: json['icon'] == null
          ? const MultiSourceIconModel()
          : MultiSourceIconModel.fromJson(json['icon'] as Map),
      labelText: json['labelText'] as String?,
      labelStyle: json['labelStyle'] == null
          ? null
          : TextProp.fromJson(json['labelStyle'] as Map),
      floatingLabelStyle: json['floatingLabelStyle'] == null
          ? null
          : TextProp.fromJson(json['floatingLabelStyle'] as Map),
      helperText: json['helperText'] as String?,
      helperStyle: json['helperStyle'] == null
          ? null
          : TextProp.fromJson(json['helperStyle'] as Map),
      helperMaxLines: (json['helperMaxLines'] as num?)?.toInt() ?? 1,
      hintText: json['hintText'] as String?,
      hintStyle: json['hintStyle'] == null
          ? null
          : TextProp.fromJson(json['hintStyle'] as Map),
      hintMaxLines: (json['hintMaxLines'] as num?)?.toInt() ?? 1,
      errorText: json['errorText'] as String?,
      errorStyle: json['errorStyle'] == null
          ? null
          : TextProp.fromJson(json['errorStyle'] as Map),
      errorMaxLines: (json['errorMaxLines'] as num?)?.toInt() ?? 1,
      floatingLabelBehavior:
          $enumDecodeNullable(
            _$FloatingLabelBehaviorEnumEnumMap,
            json['floatingLabelBehavior'],
          ) ??
          FloatingLabelBehaviorEnum.auto,
      isCollapsed: json['isCollapsed'] as bool? ?? false,
      isDense: json['isDense'] as bool? ?? true,
      prefixIcon: json['prefixIcon'] == null
          ? null
          : ReactiveIconModel.fromJson(json['prefixIcon'] as Map),
      prefixIconConstraints: json['prefixIconConstraints'] == null
          ? const BoxConstraintsModel()
          : BoxConstraintsModel.fromJson(json['prefixIconConstraints'] as Map),
      prefixText: json['prefixText'] as String?,
      prefixStyle: json['prefixStyle'] == null
          ? null
          : TextProp.fromJson(json['prefixStyle'] as Map),
      suffixIcon: json['suffixIcon'] == null
          ? null
          : ReactiveIconModel.fromJson(json['suffixIcon'] as Map),
      suffixText: json['suffixText'] as String?,
      suffixStyle: json['suffixStyle'] == null
          ? null
          : TextProp.fromJson(json['suffixStyle'] as Map),
      suffixIconConstraints: json['suffixIconConstraints'] == null
          ? const BoxConstraintsModel()
          : BoxConstraintsModel.fromJson(json['suffixIconConstraints'] as Map),
      counterText: json['counterText'] as String?,
      counterStyle: json['counterStyle'] == null
          ? null
          : TextProp.fromJson(json['counterStyle'] as Map),
      filled: json['filled'] as bool? ?? false,
      fillColor: json['fillColor'] == null
          ? ColorRGBA.grey10
          : ColorRGBA.fromJson(json['fillColor']),
      focusColor: json['focusColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['focusColor']),
      hoverColor: json['hoverColor'] == null
          ? ColorRGBA.grey10
          : ColorRGBA.fromJson(json['hoverColor']),
      showCounter: json['showCounter'] as bool? ?? true,
      errorBorder: json['errorBorder'] == null
          ? const InputBorderModel(
              borderSide: BorderSideModel(color: ColorRGBA.red),
            )
          : InputBorderModel.fromJson(json['errorBorder'] as Map),
      focusedBorder: json['focusedBorder'] == null
          ? const InputBorderModel()
          : InputBorderModel.fromJson(json['focusedBorder'] as Map),
      focusedErrorBorder: json['focusedErrorBorder'] == null
          ? const InputBorderModel(
              borderSide: BorderSideModel(color: ColorRGBA.red),
            )
          : InputBorderModel.fromJson(json['focusedErrorBorder'] as Map),
      disabledBorder: json['disabledBorder'] == null
          ? const InputBorderModel(
              borderSide: BorderSideModel(color: ColorRGBA.grey10),
            )
          : InputBorderModel.fromJson(json['disabledBorder'] as Map),
      enabledBorder: json['enabledBorder'] == null
          ? const InputBorderModel(
              borderSide: BorderSideModel(color: ColorRGBA.grey),
            )
          : InputBorderModel.fromJson(json['enabledBorder'] as Map),
      border: json['border'] == null
          ? const InputBorderModel(
              borderSide: BorderSideModel(color: ColorRGBA.grey),
            )
          : InputBorderModel.fromJson(json['border'] as Map),
      enabled: json['enabled'] as bool? ?? true,
      semanticCounterText: json['semanticCounterText'] as String?,
      alignLabelWithHint: json['alignLabelWithHint'] as bool? ?? true,
      constraints: json['constraints'] == null
          ? const BoxConstraintsModel()
          : BoxConstraintsModel.fromJson(json['constraints'] as Map),
    );

Map<String, dynamic> _$InputDecorationModelToJson(
  InputDecorationModel instance,
) => <String, dynamic>{
  'icon': instance.icon.toJson(),
  'labelText': ?instance.labelText,
  'labelStyle': instance.labelStyle.toJson(),
  'floatingLabelStyle': instance.floatingLabelStyle.toJson(),
  'helperText': ?instance.helperText,
  'helperStyle': instance.helperStyle.toJson(),
  'helperMaxLines': instance.helperMaxLines,
  'hintText': ?instance.hintText,
  'hintStyle': instance.hintStyle.toJson(),
  'hintMaxLines': instance.hintMaxLines,
  'errorText': ?instance.errorText,
  'errorStyle': instance.errorStyle.toJson(),
  'errorMaxLines': instance.errorMaxLines,
  'floatingLabelBehavior':
      _$FloatingLabelBehaviorEnumEnumMap[instance.floatingLabelBehavior]!,
  'isCollapsed': instance.isCollapsed,
  'isDense': instance.isDense,
  'prefixText': ?instance.prefixText,
  'prefixStyle': instance.prefixStyle.toJson(),
  'prefixIcon': instance.prefixIcon.toJson(),
  'prefixIconConstraints': instance.prefixIconConstraints.toJson(),
  'suffixText': ?instance.suffixText,
  'suffixStyle': instance.suffixStyle.toJson(),
  'suffixIcon': instance.suffixIcon.toJson(),
  'suffixIconConstraints': instance.suffixIconConstraints.toJson(),
  'counterText': ?instance.counterText,
  'counterStyle': instance.counterStyle.toJson(),
  'filled': instance.filled,
  'fillColor': instance.fillColor.toJson(),
  'focusColor': instance.focusColor.toJson(),
  'hoverColor': instance.hoverColor.toJson(),
  'errorBorder': instance.errorBorder.toJson(),
  'focusedBorder': instance.focusedBorder.toJson(),
  'focusedErrorBorder': instance.focusedErrorBorder.toJson(),
  'disabledBorder': instance.disabledBorder.toJson(),
  'enabledBorder': instance.enabledBorder.toJson(),
  'border': instance.border.toJson(),
  'enabled': instance.enabled,
  'semanticCounterText': ?instance.semanticCounterText,
  'alignLabelWithHint': instance.alignLabelWithHint,
  'constraints': instance.constraints.toJson(),
  'showCounter': instance.showCounter,
};

const _$FloatingLabelBehaviorEnumEnumMap = {
  FloatingLabelBehaviorEnum.never: 'never',
  FloatingLabelBehaviorEnum.auto: 'auto',
  FloatingLabelBehaviorEnum.always: 'always',
};
