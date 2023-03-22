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
          ? const TextProp.general(fontSize: 14, fills: [PaintModel.blackPaint])
          : TextProp.fromJson(json['labelStyle'] as Map),
      floatingLabelStyle: json['floatingLabelStyle'] == null
          ? const TextProp.general(fontSize: 14, fills: [PaintModel.blackPaint])
          : TextProp.fromJson(json['floatingLabelStyle'] as Map),
      helperText: json['helperText'] as String?,
      helperStyle: json['helperStyle'] == null
          ? const TextProp.general(fontSize: 14, fills: [PaintModel.blackPaint])
          : TextProp.fromJson(json['helperStyle'] as Map),
      helperMaxLines: json['helperMaxLines'] as int? ?? 1,
      hintText: json['hintText'] as String?,
      hintStyle: json['hintStyle'] == null
          ? const TextProp.general(fontSize: 14, fills: [
              PaintModel.solid(visible: true, opacity: 1, color: ColorRGB.grey)
            ])
          : TextProp.fromJson(json['hintStyle'] as Map),
      hintMaxLines: json['hintMaxLines'] as int? ?? 1,
      errorText: json['errorText'] as String?,
      errorStyle: json['errorStyle'] == null
          ? const TextProp.general(fills: [
              PaintModel.solid(visible: true, opacity: 1, color: ColorRGB.red)
            ])
          : TextProp.fromJson(json['errorStyle'] as Map),
      errorMaxLines: json['errorMaxLines'] as int? ?? 1,
      floatingLabelBehavior: $enumDecodeNullable(
              _$FloatingLabelBehaviorEnumEnumMap,
              json['floatingLabelBehavior']) ??
          FloatingLabelBehaviorEnum.auto,
      isCollapsed: json['isCollapsed'] as bool? ?? false,
      isDense: json['isDense'] as bool? ?? true,
      contentPadding: json['contentPadding'] == null
          ? const EdgeInsetsModel.symmetric(horizontal: 12, vertical: 16)
          : EdgeInsetsModel.fromJson(json['contentPadding'] as Map),
      prefixIcon: json['prefixIcon'] == null
          ? const MultiSourceIconModel()
          : MultiSourceIconModel.fromJson(json['prefixIcon'] as Map),
      prefixIconConstraints: json['prefixIconConstraints'] == null
          ? const BoxConstraintsModel()
          : BoxConstraintsModel.fromJson(json['prefixIconConstraints'] as Map),
      prefixText: json['prefixText'] as String?,
      prefixStyle: json['prefixStyle'] == null
          ? const TextProp.general()
          : TextProp.fromJson(json['prefixStyle'] as Map),
      suffixIcon: json['suffixIcon'] == null
          ? const MultiSourceIconModel()
          : MultiSourceIconModel.fromJson(json['suffixIcon'] as Map),
      suffixText: json['suffixText'] as String?,
      suffixStyle: json['suffixStyle'] == null
          ? const TextProp.general(fontSize: 14, fills: [PaintModel.blackPaint])
          : TextProp.fromJson(json['suffixStyle'] as Map),
      suffixIconConstraints: json['suffixIconConstraints'] == null
          ? const BoxConstraintsModel()
          : BoxConstraintsModel.fromJson(json['suffixIconConstraints'] as Map),
      counterText: json['counterText'] as String?,
      counterStyle: json['counterStyle'] == null
          ? const TextProp.general()
          : TextProp.fromJson(json['counterStyle'] as Map),
      filled: json['filled'] as bool? ?? false,
      fillColor: json['fillColor'] == null
          ? ColorRGBA.grey10
          : ColorRGBA.fromJson(json['fillColor'] as Map),
      focusColor: json['focusColor'] == null
          ? ColorRGBA.black
          : ColorRGBA.fromJson(json['focusColor'] as Map),
      hoverColor: json['hoverColor'] == null
          ? ColorRGBA.grey10
          : ColorRGBA.fromJson(json['hoverColor'] as Map),
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
  final val = <String, dynamic>{
    'icon': instance.icon.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('labelText', instance.labelText);
  val['labelStyle'] = instance.labelStyle.toJson();
  val['floatingLabelStyle'] = instance.floatingLabelStyle.toJson();
  writeNotNull('helperText', instance.helperText);
  val['helperStyle'] = instance.helperStyle.toJson();
  val['helperMaxLines'] = instance.helperMaxLines;
  writeNotNull('hintText', instance.hintText);
  val['hintStyle'] = instance.hintStyle.toJson();
  val['hintMaxLines'] = instance.hintMaxLines;
  writeNotNull('errorText', instance.errorText);
  val['errorStyle'] = instance.errorStyle.toJson();
  val['errorMaxLines'] = instance.errorMaxLines;
  val['floatingLabelBehavior'] =
      _$FloatingLabelBehaviorEnumEnumMap[instance.floatingLabelBehavior]!;
  val['isCollapsed'] = instance.isCollapsed;
  val['isDense'] = instance.isDense;
  val['contentPadding'] = instance.contentPadding.toJson();
  writeNotNull('prefixText', instance.prefixText);
  val['prefixStyle'] = instance.prefixStyle.toJson();
  val['prefixIcon'] = instance.prefixIcon.toJson();
  val['prefixIconConstraints'] = instance.prefixIconConstraints.toJson();
  writeNotNull('suffixText', instance.suffixText);
  val['suffixStyle'] = instance.suffixStyle.toJson();
  val['suffixIcon'] = instance.suffixIcon.toJson();
  val['suffixIconConstraints'] = instance.suffixIconConstraints.toJson();
  writeNotNull('counterText', instance.counterText);
  val['counterStyle'] = instance.counterStyle.toJson();
  val['filled'] = instance.filled;
  val['fillColor'] = instance.fillColor.toJson();
  val['focusColor'] = instance.focusColor.toJson();
  val['hoverColor'] = instance.hoverColor.toJson();
  val['errorBorder'] = instance.errorBorder.toJson();
  val['focusedBorder'] = instance.focusedBorder.toJson();
  val['focusedErrorBorder'] = instance.focusedErrorBorder.toJson();
  val['disabledBorder'] = instance.disabledBorder.toJson();
  val['enabledBorder'] = instance.enabledBorder.toJson();
  val['border'] = instance.border.toJson();
  val['enabled'] = instance.enabled;
  writeNotNull('semanticCounterText', instance.semanticCounterText);
  val['alignLabelWithHint'] = instance.alignLabelWithHint;
  val['constraints'] = instance.constraints.toJson();
  return val;
}

const _$FloatingLabelBehaviorEnumEnumMap = {
  FloatingLabelBehaviorEnum.never: 'never',
  FloatingLabelBehaviorEnum.auto: 'auto',
  FloatingLabelBehaviorEnum.always: 'always',
};
