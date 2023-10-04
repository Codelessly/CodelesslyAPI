// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_field_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextFieldNode _$TextFieldNodeFromJson(Map json) => TextFieldNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
      visible: json['visible'] as bool? ?? true,
      alignment: json['alignment'] == null
          ? AlignmentModel.none
          : AlignmentModel.fromJson(json['alignment'] as Map),
      padding: json['padding'] == null
          ? const EdgeInsetsModel.symmetric(horizontal: 12, vertical: 16)
          : EdgeInsetsModel.fromJson(json['padding']),
      margin: json['margin'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['margin']),
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
      initialText: json['initialText'] as String? ?? '',
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
  final val = <String, dynamic>{};

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool listsEqual(List? a, List? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool mapsEqual(Map? a, Map? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final k in a.keys) {
      var bValue = b[k];
      if (bValue == null && !b.containsKey(k)) return false;
      if (bValue != a[k]) return false;
    }

    return true;
  }

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool setsEqual(Set? a, Set? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    return a.containsAll(b);
  }

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    if (value == null) return;
    bool areEqual = false;
    if (value is List) {
      areEqual = listsEqual(value, defaultValue);
    } else if (value is Map) {
      areEqual = mapsEqual(value, defaultValue);
    } else if (value is Set) {
      areEqual = setsEqual(value, defaultValue);
    } else {
      areEqual = value == defaultValue;
    }

    if (!areEqual) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('reactions', instance.reactions,
      instance.reactions.map((e) => e.toJson()).toList(), const []);
  writeNotNull('variables', instance.variables, instance.variables, {});
  writeNotNull('multipleVariables', instance.multipleVariables,
      instance.multipleVariables, {});
  val['id'] = instance.id;
  val['name'] = instance.name;
  writeNotNull('visible', instance.visible, instance.visible, true);
  if (!excludeConstraintsIf(instance)) {
    writeNotNull('constraints', instance.constraints,
        instance.constraints.toJson(), const BoxConstraintsModel());
  }
  if (!excludeEdgePinsIf(instance)) {
    writeNotNull('edgePins', instance.edgePins, instance.edgePins.toJson(),
        EdgePinsModel.standard);
  }
  writeNotNull(
      'positioningMode',
      instance.positioningMode,
      _$PositioningModeEnumMap[instance.positioningMode]!,
      PositioningMode.align);
  writeNotNull('horizontalFit', instance.horizontalFit,
      _$SizeFitEnumMap[instance.horizontalFit]!, SizeFit.fixed);
  writeNotNull('verticalFit', instance.verticalFit,
      _$SizeFitEnumMap[instance.verticalFit]!, SizeFit.fixed);
  writeNotNull('flex', instance.flex, instance.flex, 1);
  writeNotNull('aspectRatioLock', instance.aspectRatioLock,
      instance.aspectRatioLock, false);
  writeNotNull('alignment', instance.alignment, instance.alignment.toJson(),
      AlignmentModel.none);
  val['basicBoxLocal'] = instance.basicBoxLocal.toJson();
  writeNotNull('margin', instance.margin, instance.margin.toJson(),
      EdgeInsetsModel.zero);
  writeNotNull('padding', instance.padding, instance.padding.toJson(),
      const EdgeInsetsModel.symmetric(horizontal: 12, vertical: 16));
  writeNotNull(
      'rotation', instance.rotationDegrees, instance.rotationDegrees, 0);
  writeNotNull('widthFactor', instance.widthFactor, instance.widthFactor, null);
  writeNotNull(
      'heightFactor', instance.heightFactor, instance.heightFactor, null);
  val['type'] = instance.type;
  val['properties'] = instance.properties.toJson();
  writeNotNull('initialText', instance.initialText, instance.initialText, '');
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
          : ColorRGB.fromJson(json['cursorColor']),
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
      expands: json['expands'] as bool? ?? false,
    );

Map<String, dynamic> _$TextFieldPropertiesToJson(TextFieldProperties instance) {
  final val = <String, dynamic>{};

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool listsEqual(List? a, List? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool mapsEqual(Map? a, Map? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final k in a.keys) {
      var bValue = b[k];
      if (bValue == null && !b.containsKey(k)) return false;
      if (bValue != a[k]) return false;
    }

    return true;
  }

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool setsEqual(Set? a, Set? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    return a.containsAll(b);
  }

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    if (value == null) return;
    bool areEqual = false;
    if (value is List) {
      areEqual = listsEqual(value, defaultValue);
    } else if (value is Map) {
      areEqual = mapsEqual(value, defaultValue);
    } else if (value is Set) {
      areEqual = setsEqual(value, defaultValue);
    } else {
      areEqual = value == defaultValue;
    }

    if (!areEqual) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('autoCorrect', instance.autoCorrect, instance.autoCorrect, true);
  writeNotNull('autoFocus', instance.autoFocus, instance.autoFocus, false);
  writeNotNull(
      'enableInteractiveSelection',
      instance.enableInteractiveSelection,
      instance.enableInteractiveSelection,
      true);
  writeNotNull('enabled', instance.enabled, instance.enabled, true);
  writeNotNull(
      'obscureText', instance.obscureText, instance.obscureText, false);
  writeNotNull('readOnly', instance.readOnly, instance.readOnly, false);
  writeNotNull('showCursor', instance.showCursor, instance.showCursor, true);
  writeNotNull(
      'keyboardType',
      instance.keyboardType,
      _$TextInputTypeEnumEnumMap[instance.keyboardType]!,
      TextInputTypeEnum.text);
  writeNotNull(
      'selectionHeightStyle',
      instance.selectionHeightStyle,
      _$BoxHeightStyleEnumEnumMap[instance.selectionHeightStyle]!,
      BoxHeightStyleEnum.tight);
  writeNotNull(
      'selectionWidthStyle',
      instance.selectionWidthStyle,
      _$BoxWidthStyleEnumEnumMap[instance.selectionWidthStyle]!,
      BoxWidthStyleEnum.tight);
  writeNotNull(
      'textAlign',
      instance.textAlign,
      _$TextAlignHorizontalEnumEnumMap[instance.textAlign]!,
      TextAlignHorizontalEnum.left);
  writeNotNull(
      'textAlignVertical',
      instance.textAlignVertical,
      _$TextAlignVerticalEnumEnumMap[instance.textAlignVertical]!,
      TextAlignVerticalEnum.center);
  writeNotNull('cursorColor', instance.cursorColor,
      instance.cursorColor.toJson(), ColorRGB.black);
  writeNotNull(
      'cursorHeight', instance.cursorHeight, instance.cursorHeight, 14);
  writeNotNull('cursorWidth', instance.cursorWidth, instance.cursorWidth, 2.0);
  writeNotNull(
      'cursorRadius', instance.cursorRadius, instance.cursorRadius, 2.0);
  writeNotNull('maxLength', instance.maxLength, instance.maxLength, null);
  writeNotNull('maxLines', instance.maxLines, instance.maxLines, 1);
  writeNotNull('minLines', instance.minLines, instance.minLines, null);
  writeNotNull('obscuringCharacter', instance.obscuringCharacter,
      instance.obscuringCharacter, '•');
  val['inputStyle'] = instance.inputStyle.toJson();
  val['decoration'] = instance.decoration.toJson();
  writeNotNull('expands', instance.expands, instance.expands, false);
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
