// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'canvas_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CanvasNode _$CanvasNodeFromJson(Map json) =>
    CanvasNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
        children:
            (json['children'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        rowColumnType:
            $enumDecodeNullable(
              _$RowColumnTypeEnumMap,
              json['rowColumnType'],
            ) ??
            RowColumnType.column,
        mainAxisAlignment:
            $enumDecodeNullable(
              _$MainAxisAlignmentCEnumMap,
              json['mainAxisAlignment'],
            ) ??
            MainAxisAlignmentC.center,
        crossAxisAlignment:
            $enumDecodeNullable(
              _$CrossAxisAlignmentCEnumMap,
              json['crossAxisAlignment'],
            ) ??
            CrossAxisAlignmentC.center,
        scaleMode:
            $enumDecodeNullable(_$ScaleModeEnumMap, json['scaleMode']) ??
            ScaleMode.autoScale,
        visible: json['visible'] as bool? ?? true,
        enabled: json['enabled'] as bool? ?? true,
        rotationDegrees: json['rotation'] == null
            ? 0
            : castRotation(json['rotation']),
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
        verticalFit:
            $enumDecodeNullable(_$SizeFitEnumMap, json['verticalFit']) ??
            SizeFit.fixed,
        flex: (json['flex'] as num?)?.toInt() ?? 1,
        constraints: json['constraints'] == null
            ? const BoxConstraintsModel()
            : BoxConstraintsModel.fromJson(json['constraints'] as Map),
        edgePins: json['edgePins'] == null
            ? EdgePinsModel.standard
            : EdgePinsModel.fromJson(
                Map<String, dynamic>.from(json['edgePins'] as Map),
              ),
        aspectRatioLock: json['aspectRatioLock'] as bool? ?? false,
        positioningMode:
            $enumDecodeNullable(
              _$PositioningModeEnumMap,
              json['positioningMode'],
            ) ??
            PositioningMode.align,
        opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
        isMask: json['isMask'] as bool? ?? false,
        effects:
            (json['effects'] as List<dynamic>?)
                ?.map((e) => Effect.fromJson(e as Map))
                .toList() ??
            const [],
        blendMode:
            $enumDecodeNullable(
              _$BlendModeCEnumMap,
              json['blendMode'],
              unknownValue: BlendModeC.srcOver,
            ) ??
            BlendModeC.srcOver,
        fills: (json['fills'] as List<dynamic>?)
            ?.map((e) => PaintModel.fromJson(e as Map))
            .toList(),
        strokes:
            (json['strokes'] as List<dynamic>?)
                ?.map((e) => PaintModel.fromJson(e as Map))
                .toList() ??
            const [],
        strokeWeight: (json['strokeWeight'] as num?)?.toDouble() ?? 0,
        strokeMiterLimit: (json['strokeMiterLimit'] as num?)?.toDouble() ?? 4.0,
        strokeAlign:
            $enumDecodeNullable(_$StrokeAlignCEnumMap, json['strokeAlign']) ??
            StrokeAlignC.inside,
        strokeCap:
            $enumDecodeNullable(
              _$StrokeCapEnumEnumMap,
              json['strokeCap'],
              unknownValue: StrokeCapEnum.none,
            ) ??
            StrokeCapEnum.none,
        dashPattern:
            (json['dashPattern'] as List<dynamic>?)
                ?.map((e) => (e as num).toDouble())
                .toList() ??
            const [],
        strokeSide:
            $enumDecodeNullable(_$StrokeSideEnumMap, json['strokeSide']) ??
            StrokeSide.all,
        reactions:
            (json['reactions'] as List<dynamic>?)
                ?.map((e) => Reaction.fromJson(e as Map))
                .toList() ??
            const [],
        createdTimestamp: const DateTimeConverter().fromJson(
          (json['createdTimestamp'] as num?)?.toInt(),
        ),
        clipsContent: json['clipsContent'] as bool? ?? true,
        isScrollable: json['isScrollable'] as bool? ?? false,
        scrollDirection:
            $enumDecodeNullable(_$AxisCEnumMap, json['scrollDirection']) ??
            AxisC.vertical,
        reverse: json['reverse'] as bool? ?? false,
        physics:
            $enumDecodeNullable(
              _$ScrollPhysicsCEnumMap,
              json['physics'],
              unknownValue: ScrollPhysicsC.platformDependent,
            ) ??
            ScrollPhysicsC.platformDependent,
        primary: json['primary'] as bool? ?? true,
        keyboardDismissBehavior:
            $enumDecodeNullable(
              _$ScrollViewKeyboardDismissBehaviorCEnumMap,
              json['keyboardDismissBehavior'],
            ) ??
            ScrollViewKeyboardDismissBehaviorC.manual,
        useFlutterListView: json['useFlutterListView'] as bool? ?? false,
        shouldAlwaysScroll: json['shouldAlwaysScroll'] as bool? ?? true,
        properties: CanvasProperties.fromJson(json['properties'] as Map),
        variables:
            (json['variables'] as Map?)?.map(
              (k, e) => MapEntry(k as String, e as String),
            ) ??
            {},
      )
      ..multipleVariables =
          (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(
              k as String,
              (e as List<dynamic>).map((e) => e as String).toList(),
            ),
          ) ??
          {}
      ..componentId = json['componentId'] as String?
      ..markerType = $enumDecodeNullable(
        _$ComponentMarkerTypeEnumMap,
        json['markerType'],
      )
      ..componentVersion = (json['componentVersion'] as num?)?.toInt() ?? 1
      ..componentSchema =
          (json['componentSchema'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e),
          ) ??
          {}
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..inkWell = json['inkWell'] == null
          ? null
          : InkWellModel.fromJson(
              Map<String, dynamic>.from(json['inkWell'] as Map),
            )
      ..type = json['type'] as String;

Map<String, dynamic> _$CanvasNodeToJson(
  CanvasNode instance,
) => <String, dynamic>{
  'reactions': instance.reactions.map((e) => e.toJson()).toList(),
  'variables': instance.variables,
  'multipleVariables': instance.multipleVariables,
  'componentId': ?instance.componentId,
  'markerType': ?_$ComponentMarkerTypeEnumMap[instance.markerType],
  'componentVersion': instance.componentVersion,
  'componentSchema': instance.componentSchema,
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
  'basicBoxLocal': instance.basicBoxLocal.toJson(),
  'margin': instance.margin.toJson(),
  'padding': instance.padding.toJson(),
  'rotation': instance.rotationDegrees,
  'widthFactor': ?instance.widthFactor,
  'heightFactor': ?instance.heightFactor,
  'enabled': instance.enabled,
  'children': instance.children,
  'opacity': instance.opacity,
  'blendMode': _$BlendModeCEnumMap[instance.blendMode]!,
  'isMask': instance.isMask,
  'effects': instance.effects.map((e) => e.toJson()).toList(),
  'inkWell': ?instance.inkWell?.toJson(),
  'fills': instance.fills.map((e) => e.toJson()).toList(),
  'strokes': instance.strokes.map((e) => e.toJson()).toList(),
  'strokeWeight': instance.strokeWeight,
  'strokeMiterLimit': instance.strokeMiterLimit,
  'strokeAlign': _$StrokeAlignCEnumMap[instance.strokeAlign]!,
  'strokeCap': _$StrokeCapEnumEnumMap[instance.strokeCap]!,
  'dashPattern': instance.dashPattern,
  'strokeSide': _$StrokeSideEnumMap[instance.strokeSide]!,
  'clipsContent': instance.clipsContent,
  'rowColumnType': _$RowColumnTypeEnumMap[instance.rowColumnType]!,
  'mainAxisAlignment': _$MainAxisAlignmentCEnumMap[instance.mainAxisAlignment]!,
  'crossAxisAlignment':
      _$CrossAxisAlignmentCEnumMap[instance.crossAxisAlignment]!,
  'isScrollable': instance.isScrollable,
  'scrollDirection': _$AxisCEnumMap[instance.scrollDirection]!,
  'reverse': instance.reverse,
  'primary': instance.primary,
  'physics': _$ScrollPhysicsCEnumMap[instance.physics]!,
  'keyboardDismissBehavior':
      _$ScrollViewKeyboardDismissBehaviorCEnumMap[instance
          .keyboardDismissBehavior]!,
  'useFlutterListView': instance.useFlutterListView,
  'shouldAlwaysScroll': instance.shouldAlwaysScroll,
  'type': instance.type,
  'createdTimestamp': ?const DateTimeConverter().toJson(
    instance.createdTimestamp,
  ),
  'properties': instance.properties.toJson(),
  'scaleMode': _$ScaleModeEnumMap[instance.scaleMode]!,
};

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
          json['floatingActionButton'] as Map,
        ),
  safeArea: json['safeArea'] == null
      ? const SafeAreaModel.all(true)
      : SafeAreaModel.fromJson(json['safeArea']),
  brightness:
      $enumDecodeNullable(_$BrightnessModelEnumMap, json['brightness']) ??
      BrightnessModel.system,
);

Map<String, dynamic> _$CanvasPropertiesToJson(CanvasProperties instance) =>
    <String, dynamic>{
      'bodyId': instance.bodyId,
      'navigationBarPlaceholderId': ?instance.navigationBarPlaceholderId,
      'topAppBarPlaceholderId': ?instance.topAppBarPlaceholderId,
      'floatingActionButton': ?instance.floatingActionButton?.toJson(),
      'safeArea': instance.safeArea.toJson(),
      'brightness': _$BrightnessModelEnumMap[instance.brightness]!,
    };

const _$BrightnessModelEnumMap = {
  BrightnessModel.light: 'light',
  BrightnessModel.dark: 'dark',
  BrightnessModel.system: 'system',
};
