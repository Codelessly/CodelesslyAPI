// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'canvas_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CanvasNode _$CanvasNodeFromJson(Map json) => CanvasNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      rowColumnType:
          $enumDecodeNullable(_$RowColumnTypeEnumMap, json['rowColumnType']) ??
              RowColumnType.column,
      mainAxisAlignment: $enumDecodeNullable(
              _$MainAxisAlignmentCEnumMap, json['mainAxisAlignment']) ??
          MainAxisAlignmentC.center,
      crossAxisAlignment: $enumDecodeNullable(
              _$CrossAxisAlignmentCEnumMap, json['crossAxisAlignment']) ??
          CrossAxisAlignmentC.center,
      scaleMode: $enumDecodeNullable(_$ScaleModeEnumMap, json['scaleMode']) ??
          ScaleMode.autoScale,
      visible: json['visible'] as bool? ?? true,
      enabled: json['enabled'] as bool? ?? true,
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
      alignment: json['alignment'] == null
          ? AlignmentModel.none
          : AlignmentModel.fromJson(json['alignment'] as Map),
      margin: json['margin'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['margin']),
      padding: json['padding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['padding']),
      horizontalFit:
          $enumDecodeNullable(_$SizeFitEnumMap, json['horizontalFit']) ??
              SizeFit.fixed,
      verticalFit: $enumDecodeNullable(_$SizeFitEnumMap, json['verticalFit']) ??
          SizeFit.fixed,
      flex: (json['flex'] as num?)?.toInt() ?? 1,
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
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
      isMask: json['isMask'] as bool? ?? false,
      effects: (json['effects'] as List<dynamic>?)
              ?.map((e) => Effect.fromJson(e as Map))
              .toList() ??
          [],
      blendMode: $enumDecodeNullable(_$BlendModeCEnumMap, json['blendMode'],
              unknownValue: BlendModeC.srcOver) ??
          BlendModeC.srcOver,
      fills: (json['fills'] as List<dynamic>?)
          ?.map((e) => PaintModel.fromJson(e as Map))
          .toList(),
      strokes: (json['strokes'] as List<dynamic>?)
              ?.map((e) => PaintModel.fromJson(e as Map))
              .toList() ??
          [],
      strokeWeight: (json['strokeWeight'] as num?)?.toDouble() ?? 0,
      strokeMiterLimit: (json['strokeMiterLimit'] as num?)?.toDouble() ?? 4.0,
      strokeAlign:
          $enumDecodeNullable(_$StrokeAlignCEnumMap, json['strokeAlign']) ??
              StrokeAlignC.inside,
      strokeCap: $enumDecodeNullable(_$StrokeCapEnumEnumMap, json['strokeCap'],
              unknownValue: StrokeCapEnum.none) ??
          StrokeCapEnum.none,
      dashPattern: (json['dashPattern'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      strokeSide:
          $enumDecodeNullable(_$StrokeSideEnumMap, json['strokeSide']) ??
              StrokeSide.all,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          [],
      createdTimestamp: const DateTimeConverter()
          .fromJson((json['createdTimestamp'] as num?)?.toInt()),
      clipsContent: json['clipsContent'] as bool? ?? true,
      isScrollable: json['isScrollable'] as bool? ?? false,
      scrollDirection:
          $enumDecodeNullable(_$AxisCEnumMap, json['scrollDirection']) ??
              AxisC.vertical,
      reverse: json['reverse'] as bool? ?? false,
      physics: $enumDecodeNullable(_$ScrollPhysicsCEnumMap, json['physics'],
              unknownValue: ScrollPhysicsC.platformDependent) ??
          ScrollPhysicsC.platformDependent,
      primary: json['primary'] as bool? ?? true,
      keyboardDismissBehavior: $enumDecodeNullable(
              _$ScrollViewKeyboardDismissBehaviorCEnumMap,
              json['keyboardDismissBehavior']) ??
          ScrollViewKeyboardDismissBehaviorC.manual,
      useFlutterListView: json['useFlutterListView'] as bool? ?? false,
      shouldAlwaysScroll: json['shouldAlwaysScroll'] as bool? ?? true,
      properties: CanvasProperties.fromJson(json['properties'] as Map),
      variables: (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {},
    )
      ..multipleVariables = (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {}
      ..componentId = json['componentId'] as String?
      ..markerType =
          $enumDecodeNullable(_$ComponentMarkerTypeEnumMap, json['markerType'])
      ..componentVersion = (json['componentVersion'] as num?)?.toInt() ?? 1
      ..componentSchema = (json['componentSchema'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e),
          ) ??
          {}
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..inkWell = json['inkWell'] == null
          ? null
          : InkWellModel.fromJson(
              Map<String, dynamic>.from(json['inkWell'] as Map))
      ..type = json['type'] as String;

Map<String, dynamic> _$CanvasNodeToJson(CanvasNode instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('alignment', instance.alignment, instance.alignment.toJson(),
      AlignmentModel.none);
  writeNotNull('reactions', instance.reactions,
      instance.reactions.map((e) => e.toJson()).toList(), const []);
  writeNotNull('variables', instance.variables, instance.variables, {});
  writeNotNull('multipleVariables', instance.multipleVariables,
      instance.multipleVariables, {});
  writeNotNull('componentId', instance.componentId, instance.componentId, null);
  writeNotNull('markerType', instance.markerType,
      _$ComponentMarkerTypeEnumMap[instance.markerType], null);
  writeNotNull('componentVersion', instance.componentVersion,
      instance.componentVersion, 1);
  writeNotNull('componentSchema', instance.componentSchema,
      instance.componentSchema, {});
  val['id'] = instance.id;
  val['name'] = instance.name;
  writeNotNull('visible', instance.visible, instance.visible, true);
  if (!excludeConstraintsIf(instance)) {
    writeNotNull('constraints', instance.constraints,
        instance.constraints.toJson(), const BoxConstraintsModel());
  }
  writeNotNull('edgePins', instance.edgePins, instance.edgePins.toJson(),
      EdgePinsModel.standard);
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
  val['basicBoxLocal'] = instance.basicBoxLocal.toJson();
  writeNotNull('margin', instance.margin, instance.margin.toJson(),
      EdgeInsetsModel.zero);
  writeNotNull('padding', instance.padding, instance.padding.toJson(),
      EdgeInsetsModel.zero);
  writeNotNull(
      'rotation', instance.rotationDegrees, instance.rotationDegrees, 0);
  writeNotNull('widthFactor', instance.widthFactor, instance.widthFactor, null);
  writeNotNull(
      'heightFactor', instance.heightFactor, instance.heightFactor, null);
  writeNotNull('enabled', instance.enabled, instance.enabled, true);
  writeNotNull('children', instance.children, instance.children, []);
  writeNotNull('opacity', instance.opacity, instance.opacity, 1);
  writeNotNull('blendMode', instance.blendMode,
      _$BlendModeCEnumMap[instance.blendMode]!, BlendModeC.srcOver);
  writeNotNull('isMask', instance.isMask, instance.isMask, false);
  writeNotNull('effects', instance.effects,
      instance.effects.map((e) => e.toJson()).toList(), const []);
  writeNotNull('inkWell', instance.inkWell, instance.inkWell?.toJson(), null);
  val['fills'] = instance.fills.map((e) => e.toJson()).toList();
  writeNotNull('strokes', instance.strokes,
      instance.strokes.map((e) => e.toJson()).toList(), const []);
  writeNotNull('strokeWeight', instance.strokeWeight, instance.strokeWeight, 0);
  writeNotNull('strokeMiterLimit', instance.strokeMiterLimit,
      instance.strokeMiterLimit, 4.0);
  writeNotNull('strokeAlign', instance.strokeAlign,
      _$StrokeAlignCEnumMap[instance.strokeAlign]!, StrokeAlignC.inside);
  writeNotNull('strokeCap', instance.strokeCap,
      _$StrokeCapEnumEnumMap[instance.strokeCap]!, StrokeCapEnum.none);
  writeNotNull(
      'dashPattern', instance.dashPattern, instance.dashPattern, const []);
  writeNotNull('strokeSide', instance.strokeSide,
      _$StrokeSideEnumMap[instance.strokeSide]!, StrokeSide.all);
  writeNotNull(
      'clipsContent', instance.clipsContent, instance.clipsContent, true);
  writeNotNull('rowColumnType', instance.rowColumnType,
      _$RowColumnTypeEnumMap[instance.rowColumnType]!, RowColumnType.column);
  writeNotNull(
      'mainAxisAlignment',
      instance.mainAxisAlignment,
      _$MainAxisAlignmentCEnumMap[instance.mainAxisAlignment]!,
      MainAxisAlignmentC.center);
  writeNotNull(
      'crossAxisAlignment',
      instance.crossAxisAlignment,
      _$CrossAxisAlignmentCEnumMap[instance.crossAxisAlignment]!,
      CrossAxisAlignmentC.center);
  writeNotNull(
      'isScrollable', instance.isScrollable, instance.isScrollable, false);
  writeNotNull('scrollDirection', instance.scrollDirection,
      _$AxisCEnumMap[instance.scrollDirection]!, AxisC.vertical);
  writeNotNull('reverse', instance.reverse, instance.reverse, false);
  writeNotNull('primary', instance.primary, instance.primary, true);
  writeNotNull(
      'physics',
      instance.physics,
      _$ScrollPhysicsCEnumMap[instance.physics]!,
      ScrollPhysicsC.platformDependent);
  writeNotNull(
      'keyboardDismissBehavior',
      instance.keyboardDismissBehavior,
      _$ScrollViewKeyboardDismissBehaviorCEnumMap[
          instance.keyboardDismissBehavior]!,
      ScrollViewKeyboardDismissBehaviorC.manual);
  writeNotNull('useFlutterListView', instance.useFlutterListView,
      instance.useFlutterListView, false);
  writeNotNull('shouldAlwaysScroll', instance.shouldAlwaysScroll,
      instance.shouldAlwaysScroll, true);
  val['type'] = instance.type;
  writeNotNull('createdTimestamp', instance.createdTimestamp,
      const DateTimeConverter().toJson(instance.createdTimestamp), null);
  val['properties'] = instance.properties.toJson();
  writeNotNull('scaleMode', instance.scaleMode,
      _$ScaleModeEnumMap[instance.scaleMode]!, ScaleMode.autoScale);
  return val;
}

const _$RowColumnTypeEnumMap = {
  RowColumnType.row: 'row',
  RowColumnType.column: 'column',
};

const _$MainAxisAlignmentCEnumMap = {
  MainAxisAlignmentC.start: 'start',
  MainAxisAlignmentC.center: 'center',
  MainAxisAlignmentC.end: 'end',
  MainAxisAlignmentC.spaceBetween: 'spaceBetween',
  MainAxisAlignmentC.spaceAround: 'spaceAround',
  MainAxisAlignmentC.spaceEvenly: 'spaceEvenly',
};

const _$CrossAxisAlignmentCEnumMap = {
  CrossAxisAlignmentC.start: 'start',
  CrossAxisAlignmentC.center: 'center',
  CrossAxisAlignmentC.end: 'end',
  CrossAxisAlignmentC.stretch: 'stretch',
  CrossAxisAlignmentC.baseline: 'baseline',
};

const _$ScaleModeEnumMap = {
  ScaleMode.autoScale: 'autoScale',
  ScaleMode.responsive: 'responsive',
};

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

const _$BlendModeCEnumMap = {
  BlendModeC.clear: 'clear',
  BlendModeC.src: 'src',
  BlendModeC.dst: 'dst',
  BlendModeC.srcOver: 'srcOver',
  BlendModeC.dstOver: 'dstOver',
  BlendModeC.srcIn: 'srcIn',
  BlendModeC.dstIn: 'dstIn',
  BlendModeC.srcOut: 'srcOut',
  BlendModeC.dstOut: 'dstOut',
  BlendModeC.srcATop: 'srcATop',
  BlendModeC.dstATop: 'dstATop',
  BlendModeC.xor: 'xor',
  BlendModeC.plus: 'plus',
  BlendModeC.modulate: 'modulate',
  BlendModeC.screen: 'screen',
  BlendModeC.overlay: 'overlay',
  BlendModeC.darken: 'darken',
  BlendModeC.lighten: 'lighten',
  BlendModeC.colorDodge: 'colorDodge',
  BlendModeC.colorBurn: 'colorBurn',
  BlendModeC.hardLight: 'hardLight',
  BlendModeC.softLight: 'softLight',
  BlendModeC.difference: 'difference',
  BlendModeC.exclusion: 'exclusion',
  BlendModeC.multiply: 'multiply',
  BlendModeC.hue: 'hue',
  BlendModeC.saturation: 'saturation',
  BlendModeC.color: 'color',
  BlendModeC.luminosity: 'luminosity',
};

const _$StrokeAlignCEnumMap = {
  StrokeAlignC.center: 'center',
  StrokeAlignC.outside: 'outside',
  StrokeAlignC.inside: 'inside',
};

const _$StrokeCapEnumEnumMap = {
  StrokeCapEnum.round: 'round',
  StrokeCapEnum.none: 'none',
  StrokeCapEnum.square: 'square',
};

const _$StrokeSideEnumMap = {
  StrokeSide.left: 'left',
  StrokeSide.right: 'right',
  StrokeSide.bottom: 'bottom',
  StrokeSide.top: 'top',
  StrokeSide.all: 'all',
};

const _$AxisCEnumMap = {
  AxisC.horizontal: 'horizontal',
  AxisC.vertical: 'vertical',
};

const _$ScrollPhysicsCEnumMap = {
  ScrollPhysicsC.platformDependent: 'platformDependent',
  ScrollPhysicsC.bouncingScrollPhysics: 'bouncingScrollPhysics',
  ScrollPhysicsC.clampingScrollPhysics: 'clampingScrollPhysics',
  ScrollPhysicsC.neverScrollableScrollPhysics: 'neverScrollableScrollPhysics',
  ScrollPhysicsC.rangeMaintainingScrollPhysics: 'rangeMaintainingScrollPhysics',
};

const _$ScrollViewKeyboardDismissBehaviorCEnumMap = {
  ScrollViewKeyboardDismissBehaviorC.manual: 'manual',
  ScrollViewKeyboardDismissBehaviorC.onDrag: 'onDrag',
};

const _$ComponentMarkerTypeEnumMap = {
  ComponentMarkerType.component: 'component',
  ComponentMarkerType.instance: 'instance',
};

CanvasProperties _$CanvasPropertiesFromJson(Map json) => CanvasProperties(
      bodyId: json['bodyId'] as String,
      navigationBarPlaceholderId: json['navigationBarPlaceholderId'] as String?,
      topAppBarPlaceholderId: json['topAppBarPlaceholderId'] as String?,
      floatingActionButton: json['floatingActionButton'] == null
          ? null
          : FloatingActionButtonProperties.fromJson(
              json['floatingActionButton'] as Map),
      safeArea: json['safeArea'] == null
          ? const SafeAreaModel.all(true)
          : SafeAreaModel.fromJson(json['safeArea']),
      brightness:
          $enumDecodeNullable(_$BrightnessModelEnumMap, json['brightness']) ??
              BrightnessModel.system,
    );

Map<String, dynamic> _$CanvasPropertiesToJson(CanvasProperties instance) {
  final val = <String, dynamic>{
    'bodyId': instance.bodyId,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull(
      'navigationBarPlaceholderId',
      instance.navigationBarPlaceholderId,
      instance.navigationBarPlaceholderId,
      null);
  writeNotNull('topAppBarPlaceholderId', instance.topAppBarPlaceholderId,
      instance.topAppBarPlaceholderId, null);
  writeNotNull('floatingActionButton', instance.floatingActionButton,
      instance.floatingActionButton?.toJson(), null);
  writeNotNull('safeArea', instance.safeArea, instance.safeArea.toJson(),
      const SafeAreaModel.all(true));
  writeNotNull('brightness', instance.brightness,
      _$BrightnessModelEnumMap[instance.brightness]!, BrightnessModel.system);
  return val;
}

const _$BrightnessModelEnumMap = {
  BrightnessModel.light: 'light',
  BrightnessModel.dark: 'dark',
  BrightnessModel.system: 'system',
};
