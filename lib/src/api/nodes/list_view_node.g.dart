// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_view_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListViewNode _$ListViewNodeFromJson(Map json) => ListViewNode(
      id: json['id'] as String,
      name: json['name'] as String,
      basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal'] as Map),
      outerBoxLocal: json['outerBoxLocal'] == null
          ? null
          : OuterNodeBox.fromJson(json['outerBoxLocal'] as Map),
      visible: json['visible'] as bool? ?? true,
      rotationDegrees:
          json['rotation'] == null ? 0 : castRotation(json['rotation']),
      alignment: json['alignment'] == null
          ? AlignmentModel.none
          : AlignmentModel.fromJson(json['alignment'] as Map),
      margin: json['margin'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['margin'] as Map),
      padding: json['padding'] == null
          ? EdgeInsetsModel.zero
          : EdgeInsetsModel.fromJson(json['padding'] as Map),
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
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map))
              .toList() ??
          const [],
      properties: ListViewProperties.fromJson(json['properties'] as Map),
      children:
          (json['children'] as List<dynamic>).map((e) => e as String).toList(),
      variables: (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {},
      clipsContent: json['clipsContent'] as bool? ?? true,
      scrollDirection:
          $enumDecodeNullable(_$AxisCEnumMap, json['scrollDirection']) ??
              AxisC.vertical,
      reverse: json['reverse'] as bool? ?? false,
      physics: $enumDecodeNullable(_$ScrollPhysicsCEnumMap, json['physics']) ??
          ScrollPhysicsC.alwaysScrollableScrollPhysics,
      primary: json['primary'] as bool? ?? false,
      keyboardDismissBehavior: $enumDecodeNullable(
              _$ScrollViewKeyboardDismissBehaviorCEnumMap,
              json['keyboardDismissBehavior']) ??
          ScrollViewKeyboardDismissBehaviorC.manual,
    )
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..allowedTypes = (json['allowedTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList()
      ..deniedTypes = (json['deniedTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList()
      ..maxAllowedSize = json['maxAllowedSize'] == null
          ? null
          : SizeC.fromJson(json['maxAllowedSize'] as Map)
      ..multipleVariables = (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {}
      ..isScrollable = json['isScrollable'] as bool
      ..useFlutterListView = json['useFlutterListView'] as bool
      ..type = json['type'] as String;

Map<String, dynamic> _$ListViewNodeToJson(ListViewNode instance) {
  final val = <String, dynamic>{
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
    'reactions': instance.reactions.map((e) => e.toJson()).toList(),
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
  val['children'] = instance.children;
  val['clipsContent'] = instance.clipsContent;
  val['allowedTypes'] = instance.allowedTypes;
  val['deniedTypes'] = instance.deniedTypes;
  writeNotNull('maxAllowedSize', instance.maxAllowedSize?.toJson());
  val['variables'] = instance.variables;
  val['multipleVariables'] = instance.multipleVariables;
  val['isScrollable'] = instance.isScrollable;
  val['scrollDirection'] = _$AxisCEnumMap[instance.scrollDirection]!;
  val['reverse'] = instance.reverse;
  val['primary'] = instance.primary;
  val['physics'] = _$ScrollPhysicsCEnumMap[instance.physics]!;
  val['keyboardDismissBehavior'] = _$ScrollViewKeyboardDismissBehaviorCEnumMap[
      instance.keyboardDismissBehavior]!;
  val['useFlutterListView'] = instance.useFlutterListView;
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

const _$AxisCEnumMap = {
  AxisC.horizontal: 'horizontal',
  AxisC.vertical: 'vertical',
};

const _$ScrollPhysicsCEnumMap = {
  ScrollPhysicsC.alwaysScrollableScrollPhysics: 'alwaysScrollableScrollPhysics',
  ScrollPhysicsC.bouncingScrollPhysics: 'bouncingScrollPhysics',
  ScrollPhysicsC.clampingScrollPhysics: 'clampingScrollPhysics',
  ScrollPhysicsC.neverScrollableScrollPhysics: 'neverScrollableScrollPhysics',
  ScrollPhysicsC.rangeMaintainingScrollPhysics: 'rangeMaintainingScrollPhysics',
};

const _$ScrollViewKeyboardDismissBehaviorCEnumMap = {
  ScrollViewKeyboardDismissBehaviorC.manual: 'manual',
  ScrollViewKeyboardDismissBehaviorC.onDrag: 'onDrag',
};

ListViewProperties _$ListViewPropertiesFromJson(Map json) => ListViewProperties(
      itemCount: json['itemCount'] as int?,
      itemExtent: (json['itemExtent'] as num?)?.toDouble(),
      cacheExtent: (json['cacheExtent'] as num?)?.toDouble(),
      separator:
          $enumDecodeNullable(_$ListItemSeparatorEnumMap, json['separator']) ??
              ListItemSeparator.space,
      separatorSpacing: (json['separatorSpacing'] as num?)?.toDouble() ?? 0,
      hasSeparator: json['hasSeparator'] as bool? ?? false,
      dividerProperties: json['dividerProperties'] == null
          ? null
          : DividerProperties.fromJson(json['dividerProperties'] as Map),
    );

Map<String, dynamic> _$ListViewPropertiesToJson(ListViewProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('itemCount', instance.itemCount);
  writeNotNull('itemExtent', instance.itemExtent);
  writeNotNull('cacheExtent', instance.cacheExtent);
  val['separatorSpacing'] = instance.separatorSpacing;
  val['separator'] = _$ListItemSeparatorEnumMap[instance.separator]!;
  val['hasSeparator'] = instance.hasSeparator;
  val['dividerProperties'] = instance.dividerProperties.toJson();
  return val;
}

const _$ListItemSeparatorEnumMap = {
  ListItemSeparator.divider: 'divider',
  ListItemSeparator.space: 'space',
};
