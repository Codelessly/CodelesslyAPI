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
      helperMaxLines: json['helperMaxLines'] as int? ?? 1,
      hintText: json['hintText'] as String?,
      hintStyle: json['hintStyle'] == null
          ? null
          : TextProp.fromJson(json['hintStyle'] as Map),
      hintMaxLines: json['hintMaxLines'] as int? ?? 1,
      errorText: json['errorText'] as String?,
      errorStyle: json['errorStyle'] == null
          ? null
          : TextProp.fromJson(json['errorStyle'] as Map),
      errorMaxLines: json['errorMaxLines'] as int? ?? 1,
      floatingLabelBehavior: $enumDecodeNullable(
              _$FloatingLabelBehaviorEnumEnumMap,
              json['floatingLabelBehavior']) ??
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
              borderSide: BorderSideModel(color: ColorRGBA.red))
          : InputBorderModel.fromJson(json['errorBorder'] as Map),
      focusedBorder: json['focusedBorder'] == null
          ? const InputBorderModel()
          : InputBorderModel.fromJson(json['focusedBorder'] as Map),
      focusedErrorBorder: json['focusedErrorBorder'] == null
          ? const InputBorderModel(
              borderSide: BorderSideModel(color: ColorRGBA.red))
          : InputBorderModel.fromJson(json['focusedErrorBorder'] as Map),
      disabledBorder: json['disabledBorder'] == null
          ? const InputBorderModel(
              borderSide: BorderSideModel(color: ColorRGBA.grey10))
          : InputBorderModel.fromJson(json['disabledBorder'] as Map),
      enabledBorder: json['enabledBorder'] == null
          ? const InputBorderModel(
              borderSide: BorderSideModel(color: ColorRGBA.grey))
          : InputBorderModel.fromJson(json['enabledBorder'] as Map),
      border: json['border'] == null
          ? const InputBorderModel(
              borderSide: BorderSideModel(color: ColorRGBA.grey))
          : InputBorderModel.fromJson(json['border'] as Map),
      enabled: json['enabled'] as bool? ?? true,
      semanticCounterText: json['semanticCounterText'] as String?,
      alignLabelWithHint: json['alignLabelWithHint'] as bool? ?? true,
      constraints: json['constraints'] == null
          ? const BoxConstraintsModel()
          : BoxConstraintsModel.fromJson(json['constraints'] as Map),
    );

Map<String, dynamic> _$InputDecorationModelToJson(
    InputDecorationModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('icon', instance.icon, instance.icon.toJson(),
      const MultiSourceIconModel());
  writeNotNull('labelText', instance.labelText, instance.labelText, null);
  val['labelStyle'] = instance.labelStyle.toJson();
  val['floatingLabelStyle'] = instance.floatingLabelStyle.toJson();
  writeNotNull('helperText', instance.helperText, instance.helperText, null);
  val['helperStyle'] = instance.helperStyle.toJson();
  writeNotNull(
      'helperMaxLines', instance.helperMaxLines, instance.helperMaxLines, 1);
  writeNotNull('hintText', instance.hintText, instance.hintText, null);
  val['hintStyle'] = instance.hintStyle.toJson();
  writeNotNull('hintMaxLines', instance.hintMaxLines, instance.hintMaxLines, 1);
  writeNotNull('errorText', instance.errorText, instance.errorText, null);
  val['errorStyle'] = instance.errorStyle.toJson();
  writeNotNull(
      'errorMaxLines', instance.errorMaxLines, instance.errorMaxLines, 1);
  writeNotNull(
      'floatingLabelBehavior',
      instance.floatingLabelBehavior,
      _$FloatingLabelBehaviorEnumEnumMap[instance.floatingLabelBehavior]!,
      FloatingLabelBehaviorEnum.auto);
  writeNotNull(
      'isCollapsed', instance.isCollapsed, instance.isCollapsed, false);
  writeNotNull('isDense', instance.isDense, instance.isDense, true);
  writeNotNull('prefixText', instance.prefixText, instance.prefixText, null);
  val['prefixStyle'] = instance.prefixStyle.toJson();
  val['prefixIcon'] = instance.prefixIcon.toJson();
  writeNotNull('prefixIconConstraints', instance.prefixIconConstraints,
      instance.prefixIconConstraints.toJson(), const BoxConstraintsModel());
  writeNotNull('suffixText', instance.suffixText, instance.suffixText, null);
  val['suffixStyle'] = instance.suffixStyle.toJson();
  val['suffixIcon'] = instance.suffixIcon.toJson();
  writeNotNull('suffixIconConstraints', instance.suffixIconConstraints,
      instance.suffixIconConstraints.toJson(), const BoxConstraintsModel());
  writeNotNull('counterText', instance.counterText, instance.counterText, null);
  val['counterStyle'] = instance.counterStyle.toJson();
  writeNotNull('filled', instance.filled, instance.filled, false);
  writeNotNull('fillColor', instance.fillColor, instance.fillColor.toJson(),
      ColorRGBA.grey10);
  writeNotNull('focusColor', instance.focusColor, instance.focusColor.toJson(),
      ColorRGBA.black);
  writeNotNull('hoverColor', instance.hoverColor, instance.hoverColor.toJson(),
      ColorRGBA.grey10);
  writeNotNull(
      'errorBorder',
      instance.errorBorder,
      instance.errorBorder.toJson(),
      const InputBorderModel(
          borderSide: BorderSideModel(color: ColorRGBA.red)));
  writeNotNull('focusedBorder', instance.focusedBorder,
      instance.focusedBorder.toJson(), const InputBorderModel());
  writeNotNull(
      'focusedErrorBorder',
      instance.focusedErrorBorder,
      instance.focusedErrorBorder.toJson(),
      const InputBorderModel(
          borderSide: BorderSideModel(color: ColorRGBA.red)));
  writeNotNull(
      'disabledBorder',
      instance.disabledBorder,
      instance.disabledBorder.toJson(),
      const InputBorderModel(
          borderSide: BorderSideModel(color: ColorRGBA.grey10)));
  writeNotNull(
      'enabledBorder',
      instance.enabledBorder,
      instance.enabledBorder.toJson(),
      const InputBorderModel(
          borderSide: BorderSideModel(color: ColorRGBA.grey)));
  writeNotNull(
      'border',
      instance.border,
      instance.border.toJson(),
      const InputBorderModel(
          borderSide: BorderSideModel(color: ColorRGBA.grey)));
  writeNotNull('enabled', instance.enabled, instance.enabled, true);
  writeNotNull('semanticCounterText', instance.semanticCounterText,
      instance.semanticCounterText, null);
  writeNotNull('alignLabelWithHint', instance.alignLabelWithHint,
      instance.alignLabelWithHint, true);
  writeNotNull('constraints', instance.constraints,
      instance.constraints.toJson(), const BoxConstraintsModel());
  writeNotNull('showCounter', instance.showCounter, instance.showCounter, true);
  return val;
}

const _$FloatingLabelBehaviorEnumEnumMap = {
  FloatingLabelBehaviorEnum.never: 'never',
  FloatingLabelBehaviorEnum.auto: 'auto',
  FloatingLabelBehaviorEnum.always: 'always',
};
