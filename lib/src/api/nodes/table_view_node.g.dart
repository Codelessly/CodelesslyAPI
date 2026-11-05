// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_view_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$TableColumnModelOmitDefaults(
  TableColumnModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.key, '')) json.remove('key');
  if (isJsonDefault(instance.label, '')) json.remove('label');
  return json;
}

Map<String, dynamic> _$TableViewNodeOmitDefaults(
  TableViewNode instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.ephemeral, false)) json.remove('ephemeral');
  if (isJsonDefault(instance.allowedTypes, <String>[]))
    json.remove('allowedTypes');
  if (isJsonDefault(instance.deniedTypes, <String>[]))
    json.remove('deniedTypes');
  if (isJsonDefault(instance.visible, true)) json.remove('visible');
  if (excludeConstraintsIf(instance)) json.remove('constraints');
  if (isJsonDefault(instance.constraints, const BoxConstraintsModel()))
    json.remove('constraints');
  if (isJsonDefault(instance.edgePins, EdgePinsModel.standard))
    json.remove('edgePins');
  if (isJsonDefault(instance.positioningMode, PositioningMode.align))
    json.remove('positioningMode');
  if (isJsonDefault(instance.horizontalFit, SizeFit.fixed))
    json.remove('horizontalFit');
  if (isJsonDefault(instance.verticalFit, SizeFit.fixed))
    json.remove('verticalFit');
  if (isJsonDefault(instance.flex, 1)) json.remove('flex');
  if (isJsonDefault(instance.squeezable, false)) json.remove('squeezable');
  if (isJsonDefault(instance.ignorePointer, false))
    json.remove('ignorePointer');
  if (isJsonDefault(instance.keepAspect, 0)) json.remove('keepAspect');
  if (isJsonDefault(instance.aspectRatioLock, false))
    json.remove('aspectRatioLock');
  if (isJsonDefault(instance.alignment, AlignmentModel.none))
    json.remove('alignment');
  if (isJsonDefault(instance.margin, EdgeInsetsModel.zero))
    json.remove('margin');
  if (isJsonDefault(instance.padding, EdgeInsetsModel.zero))
    json.remove('padding');
  if (isJsonDefault(instance.rotationDegrees, 0)) json.remove('rotation');
  if (isJsonDefault(instance.interactionStates, {}))
    json.remove('interactionStates');
  if (isJsonDefault(instance.tooltip, '')) json.remove('tooltip');
  if (isJsonDefault(instance.zoomable, false)) json.remove('zoomable');
  if (isJsonDefault(instance.transitionMs, 0)) json.remove('transitionMs');
  if (isJsonDefault(instance.drawScale, 1.0)) json.remove('drawScale');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.effectAnimations, []))
    json.remove('effectAnimations');
  if (isJsonDefault(instance.flightKey, '')) json.remove('flightKey');
  if (isJsonDefault(instance.floating, false)) json.remove('floating');
  if (isJsonDefault(instance.variables, {})) json.remove('variables');
  if (isJsonDefault(instance.multipleVariables, {}))
    json.remove('multipleVariables');
  if (isJsonDefault(instance.componentVersion, 1))
    json.remove('componentVersion');
  if (isJsonDefault(instance.componentSchema, {}))
    json.remove('componentSchema');
  if (isJsonDefault(instance.reactions, const [])) json.remove('reactions');
  if (isJsonDefault(instance.children, [])) json.remove('children');
  if (isJsonDefault(instance.clipsContent, true)) json.remove('clipsContent');
  return json;
}

Map<String, dynamic> _$TableViewPropertiesOmitDefaults(
  TableViewProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.columns, const [])) json.remove('columns');
  if (isJsonDefault(instance.cellNodeId, '')) json.remove('cellNodeId');
  if (isJsonDefault(instance.columnHeaderNodeId, ''))
    json.remove('columnHeaderNodeId');
  if (isJsonDefault(instance.rowHeaderNodeId, ''))
    json.remove('rowHeaderNodeId');
  if (isJsonDefault(instance.cornerNodeId, '')) json.remove('cornerNodeId');
  if (isJsonDefault(instance.rowHeight, 40)) json.remove('rowHeight');
  if (isJsonDefault(instance.headerHeight, 44)) json.remove('headerHeight');
  if (isJsonDefault(instance.columnWidth, 120)) json.remove('columnWidth');
  if (isJsonDefault(instance.rowHeaderWidth, 120))
    json.remove('rowHeaderWidth');
  if (isJsonDefault(instance.pinHeaderRow, true)) json.remove('pinHeaderRow');
  if (isJsonDefault(instance.pinHeaderColumn, true))
    json.remove('pinHeaderColumn');
  if (isJsonDefault(
    instance.gridLineColor,
    const ColorRGBA(r: 0.88, g: 0.89, b: 0.91, a: 1),
  ))
    json.remove('gridLineColor');
  if (isJsonDefault(instance.gridLineWidth, 1)) json.remove('gridLineWidth');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TableColumnModel _$TableColumnModelFromJson(Map json) => TableColumnModel(
  key: json['key'] as String? ?? '',
  label: json['label'] as String? ?? '',
  width: (json['width'] as num?)?.toDouble(),
);

Map<String, dynamic> _$TableColumnModelToJson(TableColumnModel instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'width': ?instance.width,
    };

TableViewNode _$TableViewNodeFromJson(Map json) =>
    TableViewNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
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
        reactions:
            (json['reactions'] as List<dynamic>?)
                ?.map((e) => Reaction.fromJson(e as Map))
                .toList() ??
            const [],
        properties: TableViewProperties.fromJson(json['properties'] as Map),
        children:
            (json['children'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        variables:
            (json['variables'] as Map?)?.map(
              (k, e) => MapEntry(k as String, e as String),
            ) ??
            {},
        multipleVariables:
            (json['multipleVariables'] as Map?)?.map(
              (k, e) => MapEntry(
                k as String,
                (e as List<dynamic>).map((e) => e as String).toList(),
              ),
            ) ??
            {},
        clipsContent: json['clipsContent'] as bool? ?? true,
      )
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
      ..squeezable = json['squeezable'] as bool? ?? false
      ..ignorePointer = json['ignorePointer'] as bool? ?? false
      ..keepAspect = (json['keepAspect'] as num?)?.toDouble() ?? 0
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..interactionStates =
          (json['interactionStates'] as Map?)?.map(
            (k, e) => MapEntry(
              $enumDecode(_$InteractionStateEnumMap, k),
              (e as Map).map(
                (k, e) =>
                    MapEntry(k as String, Map<String, dynamic>.from(e as Map)),
              ),
            ),
          ) ??
          {}
      ..tooltip = json['tooltip'] as String? ?? ''
      ..zoomable = json['zoomable'] as bool? ?? false
      ..loopAnimation = json['loopAnimation'] == null
          ? null
          : LoopAnimation.fromJson(json['loopAnimation'] as Map)
      ..transitionMs = (json['transitionMs'] as num?)?.toInt() ?? 0
      ..drawScale = (json['drawScale'] as num?)?.toDouble() ?? 1.0
      ..pulse = json['pulse'] == null
          ? null
          : PulseModel.fromJson(json['pulse'] as Map)
      ..draggable = json['draggable'] == null
          ? null
          : DraggableModel.fromJson(json['draggable'] as Map)
      ..dropTarget = json['dropTarget'] == null
          ? null
          : DropTargetModel.fromJson(json['dropTarget'] as Map)
      ..motion = json['motion'] == null
          ? null
          : MotionModel.fromJson(json['motion'] as Map)
      ..effectAnimations =
          (json['effectAnimations'] as List<dynamic>?)
              ?.map((e) => EffectAnimation.fromJson(e as Map))
              .toList() ??
          []
      ..particles = json['particles'] == null
          ? null
          : ParticleEmitter.fromJson(json['particles'] as Map)
      ..flightKey = json['flightKey'] as String? ?? ''
      ..strokePath = json['strokePath'] == null
          ? null
          : StrokePath.fromJson(json['strokePath'] as Map)
      ..reveal = json['reveal'] == null
          ? null
          : RevealModel.fromJson(json['reveal'] as Map)
      ..drag = json['drag'] == null
          ? null
          : DragModel.fromJson(json['drag'] as Map)
      ..floating = json['floating'] as bool? ?? false
      ..heroTag = json['heroTag'] as String?
      ..heroFlight = $enumDecodeNullable(
        _$HeroFlightEnumMap,
        json['heroFlight'],
      )
      ..layoutAspectRatio = (json['layoutAspectRatio'] as num?)?.toDouble()
      ..sizeTransition = json['sizeTransition'] == null
          ? null
          : NodeTransition.fromJson(json['sizeTransition'] as Map)
      ..ephemeral = json['ephemeral'] as bool? ?? false
      ..allowedTypes =
          (json['allowedTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          []
      ..deniedTypes =
          (json['deniedTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          []
      ..maxAllowedSize = json['maxAllowedSize'] == null
          ? null
          : SizeC.fromJson(json['maxAllowedSize'] as Map)
      ..type = json['type'] as String;

Map<String, dynamic> _$TableViewNodeToJson(
  TableViewNode instance,
) => <String, dynamic>{
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
  'squeezable': instance.squeezable,
  'reactions': instance.reactions.map((e) => e.toJson()).toList(),
  'ignorePointer': instance.ignorePointer,
  'keepAspect': instance.keepAspect,
  'aspectRatioLock': instance.aspectRatioLock,
  'alignment': instance.alignment.toJson(),
  'basicBoxLocal': instance.basicBoxLocal.toJson(),
  'margin': instance.margin.toJson(),
  'padding': instance.padding.toJson(),
  'rotation': instance.rotationDegrees,
  'widthFactor': ?instance.widthFactor,
  'heightFactor': ?instance.heightFactor,
  'interactionStates': instance.interactionStates.map(
    (k, e) => MapEntry(_$InteractionStateEnumMap[k]!, e),
  ),
  'tooltip': instance.tooltip,
  'zoomable': instance.zoomable,
  'loopAnimation': ?instance.loopAnimation?.toJson(),
  'transitionMs': instance.transitionMs,
  'drawScale': instance.drawScale,
  'pulse': ?instance.pulse?.toJson(),
  'draggable': ?instance.draggable?.toJson(),
  'dropTarget': ?instance.dropTarget?.toJson(),
  'enabled': instance.enabled,
  'motion': ?instance.motion?.toJson(),
  'effectAnimations': instance.effectAnimations.map((e) => e.toJson()).toList(),
  'particles': ?instance.particles?.toJson(),
  'flightKey': instance.flightKey,
  'strokePath': ?instance.strokePath?.toJson(),
  'reveal': ?instance.reveal?.toJson(),
  'drag': ?instance.drag?.toJson(),
  'floating': instance.floating,
  'heroTag': ?instance.heroTag,
  'heroFlight': ?_$HeroFlightEnumMap[instance.heroFlight],
  'layoutAspectRatio': ?instance.layoutAspectRatio,
  'sizeTransition': ?instance.sizeTransition?.toJson(),
  'children': instance.children,
  'clipsContent': instance.clipsContent,
  'ephemeral': instance.ephemeral,
  'allowedTypes': instance.allowedTypes,
  'deniedTypes': instance.deniedTypes,
  'maxAllowedSize': ?instance.maxAllowedSize?.toJson(),
  'type': instance.type,
  'properties': instance.properties.toJson(),
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

const _$ComponentMarkerTypeEnumMap = {
  ComponentMarkerType.component: 'component',
  ComponentMarkerType.instance: 'instance',
};

const _$InteractionStateEnumMap = {
  InteractionState.hovered: 'hovered',
  InteractionState.focused: 'focused',
  InteractionState.pressed: 'pressed',
  InteractionState.selected: 'selected',
  InteractionState.disabled: 'disabled',
  InteractionState.dragged: 'dragged',
};

const _$HeroFlightEnumMap = {
  HeroFlight.standard: 'standard',
  HeroFlight.morphCorners: 'morphCorners',
};

TableViewProperties _$TableViewPropertiesFromJson(Map json) =>
    TableViewProperties(
      columns:
          (json['columns'] as List<dynamic>?)
              ?.map((e) => TableColumnModel.fromJson(e as Map))
              .toList() ??
          const [],
      rowCount: (json['rowCount'] as num?)?.toInt(),
      cellNodeId: json['cellNodeId'] as String? ?? '',
      columnHeaderNodeId: json['columnHeaderNodeId'] as String? ?? '',
      rowHeaderNodeId: json['rowHeaderNodeId'] as String? ?? '',
      cornerNodeId: json['cornerNodeId'] as String? ?? '',
      rowHeight: (json['rowHeight'] as num?)?.toDouble() ?? 40,
      headerHeight: (json['headerHeight'] as num?)?.toDouble() ?? 44,
      columnWidth: (json['columnWidth'] as num?)?.toDouble() ?? 120,
      rowHeaderWidth: (json['rowHeaderWidth'] as num?)?.toDouble() ?? 120,
      pinHeaderRow: json['pinHeaderRow'] as bool? ?? true,
      pinHeaderColumn: json['pinHeaderColumn'] as bool? ?? true,
      gridLineColor: json['gridLineColor'] == null
          ? const ColorRGBA(r: 0.88, g: 0.89, b: 0.91, a: 1)
          : ColorRGBA.fromJson(json['gridLineColor']),
      gridLineWidth: (json['gridLineWidth'] as num?)?.toDouble() ?? 1,
      stripeColor: json['stripeColor'] == null
          ? null
          : ColorRGBA.fromJson(json['stripeColor']),
      headerColor: json['headerColor'] == null
          ? null
          : ColorRGBA.fromJson(json['headerColor']),
      cacheExtent: (json['cacheExtent'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TableViewPropertiesToJson(
  TableViewProperties instance,
) => <String, dynamic>{
  'columns': instance.columns.map((e) => e.toJson()).toList(),
  'rowCount': ?instance.rowCount,
  'cellNodeId': instance.cellNodeId,
  'columnHeaderNodeId': instance.columnHeaderNodeId,
  'rowHeaderNodeId': instance.rowHeaderNodeId,
  'cornerNodeId': instance.cornerNodeId,
  'rowHeight': instance.rowHeight,
  'headerHeight': instance.headerHeight,
  'columnWidth': instance.columnWidth,
  'rowHeaderWidth': instance.rowHeaderWidth,
  'pinHeaderRow': instance.pinHeaderRow,
  'pinHeaderColumn': instance.pinHeaderColumn,
  'gridLineColor': ?instance.gridLineColor?.toJson(),
  'gridLineWidth': instance.gridLineWidth,
  'stripeColor': ?instance.stripeColor?.toJson(),
  'headerColor': ?instance.headerColor?.toJson(),
  'cacheExtent': ?instance.cacheExtent,
};
