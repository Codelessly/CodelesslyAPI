// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_field_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextFieldNode _$TextFieldNodeFromJson(Map json) => TextFieldNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal'] as Map),
      outerBoxLocal: json['outerBoxLocal'] == null
          ? null
          : OuterNodeBox.fromJson(json['outerBoxLocal'] as Map),
      visible: json['visible'] as bool? ?? true,
      alignment: json['alignment'] == null
          ? AlignmentModel.none
          : AlignmentModel.fromJson(json['alignment'] as Map),
      padding: json['padding'] == null
          ? const EdgeInsetsModel.symmetric(horizontal: 12, vertical: 16)
          : EdgeInsetsModel.fromJson(json['padding'] as Map),
      margin: json['margin'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['margin'] as Map),
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          const [],
      horizontalFit:
          $enumDecodeNullable(_$SizeFitEnumMap, json['horizontalFit']) ??
              SizeFit.fixed,
      verticalFit: $enumDecodeNullable(_$SizeFitEnumMap, json['verticalFit']) ??
          SizeFit.fixed,
      flex: json['flex'] as int? ?? 1,
      constraints: json['constraints'] == null
          ? const BoxConstraintsModel()
          : BoxConstraintsModel.fromJson(json['constraints'] as Map),
      edgePins: json['edgePins'] == null
          ? EdgePinsModel.standard
          : EdgePinsModel.fromJson(
              Map<String, dynamic>.from(json['edgePins'] as Map)),
      aspectRatioLock: json['aspectRatioLock'] as bool? ?? false,
      positioningMode: $enumDecodeNullable(
              _$PositioningModeEnumMap, json['positioningMode']) ??
          PositioningMode.align,
      properties: TextFieldProperties.fromJson(json['properties'] as Map),
    )
      ..variables = (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {}
      ..multipleVariables = (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {}
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..type = json['type'] as String;

Map<String, dynamic> _$TextFieldNodeToJson(TextFieldNode instance) {
  final val = <String, dynamic>{
    'reactions': instance.reactions.map((e) => e.toJson()).toList(),
    'variables': instance.variables,
    'multipleVariables': instance.multipleVariables,
    'id': instance.id,
    'name': instance.name,
    'visible': instance.visible,
    'constraints': instance.constraints.toJson(),
    'edgePins': instance.edgePins.toJson(),
    'positioningMode': _$PositioningModeEnumMap[instance.positioningMode]!,
    'horizontalFit': _$SizeFitEnumMap[instance.horizontalFit]!,
    'verticalFit': _$SizeFitEnumMap[instance.verticalFit]!,
    'flex': instance.flex,
    'aspectRatioLock': instance.aspectRatioLock,
    'alignment': instance.alignment.toJson(),
    'outerBoxLocal': instance.outerBoxLocal.toJson(),
    'basicBoxLocal': instance.basicBoxLocal.toJson(),
    'margin': instance.margin.toJson(),
    'padding': instance.padding.toJson(),
    'rotation': instance.rotationDegrees,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('widthFactor', instance.widthFactor);
  writeNotNull('heightFactor', instance.heightFactor);
  val['type'] = instance.type;
  val['properties'] = instance.properties.toJson();
  return val;
}

const _$SizeFitEnumMap = {
  SizeFit.locked: 'locked',
  SizeFit.fixed: 'fixed',
  SizeFit.expanded: 'expanded',
  SizeFit.flexible: 'flexible',
  SizeFit.shrinkWrap: 'shrinkWrap',
};

const _$PositioningModeEnumMap = {
  PositioningMode.align: 'align',
  PositioningMode.pin: 'pin',
};

TextFieldProperties _$TextFieldPropertiesFromJson(Map json) =>
    TextFieldProperties(
      autoCorrect: json['autoCorrect'] as bool? ?? true,
      autoFocus: json['autoFocus'] as bool? ?? false,
      enableInteractiveSelection:
          json['enableInteractiveSelection'] as bool? ?? true,
      enabled: json['enabled'] as bool? ?? true,
      obscureText: json['obscureText'] as bool? ?? false,
      readOnly: json['readOnly'] as bool? ?? false,
      showCursor: json['showCursor'] as bool? ?? true,
      keyboardType: $enumDecodeNullable(
              _$TextInputTypeEnumEnumMap, json['keyboardType']) ??
          TextInputTypeEnum.text,
      selectionHeightStyle: $enumDecodeNullable(
              _$BoxHeightStyleEnumEnumMap, json['selectionHeightStyle'],
              unknownValue: BoxHeightStyleEnum.tight) ??
          BoxHeightStyleEnum.tight,
      selectionWidthStyle: $enumDecodeNullable(
              _$BoxWidthStyleEnumEnumMap, json['selectionWidthStyle'],
              unknownValue: BoxWidthStyleEnum.tight) ??
          BoxWidthStyleEnum.tight,
      textAlign: $enumDecodeNullable(
              _$TextAlignHorizontalEnumEnumMap, json['textAlign']) ??
          TextAlignHorizontalEnum.left,
      textAlignVertical: $enumDecodeNullable(
              _$TextAlignVerticalEnumEnumMap, json['textAlignVertical']) ??
          TextAlignVerticalEnum.center,
      cursorColor: json['cursorColor'] == null
          ? ColorRGB.black
          : ColorRGB.fromJson(json['cursorColor'] as Map),
      cursorHeight: (json['cursorHeight'] as num?)?.toDouble() ?? 14,
      cursorWidth: (json['cursorWidth'] as num?)?.toDouble() ?? 2.0,
      cursorRadius: (json['cursorRadius'] as num?)?.toDouble() ?? 2.0,
      maxLength: json['maxLength'] as int?,
      maxLines: json['maxLines'] as int? ?? 1,
      minLines: json['minLines'] as int?,
      obscuringCharacter: json['obscuringCharacter'] as String? ?? '•',
      inputStyle: json['inputStyle'] == null
          ? null
          : TextProp.fromJson(json['inputStyle'] as Map),
      decoration: json['decoration'] == null
          ? null
          : InputDecorationModel.fromJson(json['decoration'] as Map),
    );

Map<String, dynamic> _$TextFieldPropertiesToJson(TextFieldProperties instance) {
  final val = <String, dynamic>{
    'autoCorrect': instance.autoCorrect,
    'autoFocus': instance.autoFocus,
    'enableInteractiveSelection': instance.enableInteractiveSelection,
    'enabled': instance.enabled,
    'obscureText': instance.obscureText,
    'readOnly': instance.readOnly,
    'showCursor': instance.showCursor,
    'keyboardType': _$TextInputTypeEnumEnumMap[instance.keyboardType]!,
    'selectionHeightStyle':
        _$BoxHeightStyleEnumEnumMap[instance.selectionHeightStyle]!,
    'selectionWidthStyle':
        _$BoxWidthStyleEnumEnumMap[instance.selectionWidthStyle]!,
    'textAlign': _$TextAlignHorizontalEnumEnumMap[instance.textAlign]!,
    'textAlignVertical':
        _$TextAlignVerticalEnumEnumMap[instance.textAlignVertical]!,
    'cursorColor': instance.cursorColor.toJson(),
    'cursorHeight': instance.cursorHeight,
    'cursorWidth': instance.cursorWidth,
    'cursorRadius': instance.cursorRadius,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('maxLength', instance.maxLength);
  writeNotNull('maxLines', instance.maxLines);
  writeNotNull('minLines', instance.minLines);
  val['obscuringCharacter'] = instance.obscuringCharacter;
  val['inputStyle'] = instance.inputStyle.toJson();
  val['decoration'] = instance.decoration.toJson();
  return val;
}

const _$TextInputTypeEnumEnumMap = {
  TextInputTypeEnum.dateTime: 'dateTime',
  TextInputTypeEnum.emailAddress: 'emailAddress',
  TextInputTypeEnum.multiline: 'multiline',
  TextInputTypeEnum.name: 'name',
  TextInputTypeEnum.none: 'none',
  TextInputTypeEnum.number: 'number',
  TextInputTypeEnum.phone: 'phone',
  TextInputTypeEnum.streetAddress: 'streetAddress',
  TextInputTypeEnum.text: 'text',
  TextInputTypeEnum.url: 'url',
  TextInputTypeEnum.visiblePassword: 'visiblePassword',
};

const _$BoxHeightStyleEnumEnumMap = {
  BoxHeightStyleEnum.includeLineSpacingBottom: 'includeLineSpacingBottom',
  BoxHeightStyleEnum.includeLineSpacingMiddle: 'includeLineSpacingMiddle',
  BoxHeightStyleEnum.includeLineSpacingTop: 'includeLineSpacingTop',
  BoxHeightStyleEnum.max: 'max',
  BoxHeightStyleEnum.strut: 'strut',
  BoxHeightStyleEnum.tight: 'tight',
};

const _$BoxWidthStyleEnumEnumMap = {
  BoxWidthStyleEnum.max: 'max',
  BoxWidthStyleEnum.tight: 'tight',
};

const _$TextAlignHorizontalEnumEnumMap = {
  TextAlignHorizontalEnum.left: 'left',
  TextAlignHorizontalEnum.center: 'center',
  TextAlignHorizontalEnum.right: 'right',
  TextAlignHorizontalEnum.justified: 'justified',
};

const _$TextAlignVerticalEnumEnumMap = {
  TextAlignVerticalEnum.top: 'top',
  TextAlignVerticalEnum.center: 'center',
  TextAlignVerticalEnum.bottom: 'bottom',
};
