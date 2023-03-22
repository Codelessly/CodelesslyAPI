// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebviewNode _$WebviewNodeFromJson(Map json) => WebviewNode(
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
          ? EdgeInsetsModel.zero
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
      aspectRatioLock: json['aspectRatioLock'] as bool? ?? false,
      constraints: json['constraints'] == null
          ? const BoxConstraintsModel()
          : BoxConstraintsModel.fromJson(json['constraints'] as Map),
      positioningMode: $enumDecodeNullable(
              _$PositioningModeEnumMap, json['positioningMode']) ??
          PositioningMode.align,
      edgePins: json['edgePins'] == null
          ? EdgePinsModel.standard
          : EdgePinsModel.fromJson(
              Map<String, dynamic>.from(json['edgePins'] as Map)),
      properties: WebviewProperties.fromJson(json['properties'] as Map),
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
      ..type = json['type'] as String;

Map<String, dynamic> _$WebviewNodeToJson(WebviewNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'visible': instance.visible,
      'constraints': instance.constraints.toJson(),
      'edgePins': instance.edgePins.toJson(),
      'positioningMode': _$PositioningModeEnumMap[instance.positioningMode]!,
      'horizontalFit': _$SizeFitEnumMap[instance.horizontalFit]!,
      'verticalFit': _$SizeFitEnumMap[instance.verticalFit]!,
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
      'flex': instance.flex,
      'aspectRatioLock': instance.aspectRatioLock,
      'alignment': instance.alignment.toJson(),
      'outerBoxLocal': instance.outerBoxLocal.toJson(),
      'basicBoxLocal': instance.basicBoxLocal.toJson(),
      'margin': instance.margin.toJson(),
      'padding': instance.padding.toJson(),
      'rotation': instance.rotationDegrees,
      'variables': instance.variables,
      'multipleVariables': instance.multipleVariables,
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

WebPageWebviewProperties _$WebPageWebviewPropertiesFromJson(Map json) =>
    WebPageWebviewProperties(
      pageSourceType: $enumDecode(
          _$WebviewWebpageSourceTypeEnumMap, json['pageSourceType']),
      input: json['input'] as String,
      controlVerticalScrollGesture:
          json['controlVerticalScrollGesture'] as bool?,
      controlHorizontalScrollGesture:
          json['controlHorizontalScrollGesture'] as bool?,
      controlScaleGesture: json['controlScaleGesture'] as bool?,
      controlTapGesture: json['controlTapGesture'] as bool?,
      controlLongPressGesture: json['controlLongPressGesture'] as bool?,
      controlForcePressGesture: json['controlForcePressGesture'] as bool?,
      allowsInlineMediaPlayback: json['allowsInlineMediaPlayback'] as bool?,
      mediaAutoPlaybackPolicy: $enumDecodeNullable(
              _$WebviewMediaAutoPlaybackPolicyEnumMap,
              json['mediaAutoPlaybackPolicy']) ??
          WebviewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
      backgroundColor: json['backgroundColor'] == null
          ? null
          : ColorRGBA.fromJson(json['backgroundColor'] as Map),
    )
      ..src = _$JsonConverterFromJson<String, String?>(
          json['src'], const Base64JsonConverter().fromJson)
      ..webviewType = $enumDecode(_$WebviewTypeEnumMap, json['webviewType']);

Map<String, dynamic> _$WebPageWebviewPropertiesToJson(
    WebPageWebviewProperties instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('src', const Base64JsonConverter().toJson(instance.src));
  writeNotNull(
      'controlVerticalScrollGesture', instance.controlVerticalScrollGesture);
  writeNotNull('controlHorizontalScrollGesture',
      instance.controlHorizontalScrollGesture);
  writeNotNull('controlScaleGesture', instance.controlScaleGesture);
  writeNotNull('controlTapGesture', instance.controlTapGesture);
  writeNotNull('controlLongPressGesture', instance.controlLongPressGesture);
  writeNotNull('controlForcePressGesture', instance.controlForcePressGesture);
  writeNotNull('allowsInlineMediaPlayback', instance.allowsInlineMediaPlayback);
  val['mediaAutoPlaybackPolicy'] = _$WebviewMediaAutoPlaybackPolicyEnumMap[
      instance.mediaAutoPlaybackPolicy]!;
  writeNotNull('backgroundColor', instance.backgroundColor?.toJson());
  val['pageSourceType'] =
      _$WebviewWebpageSourceTypeEnumMap[instance.pageSourceType]!;
  val['input'] = instance.input;
  val['webviewType'] = _$WebviewTypeEnumMap[instance.webviewType]!;
  return val;
}

const _$WebviewWebpageSourceTypeEnumMap = {
  WebviewWebpageSourceType.url: 'url',
  WebviewWebpageSourceType.html: 'html',
  WebviewWebpageSourceType.asset: 'asset',
};

const _$WebviewMediaAutoPlaybackPolicyEnumMap = {
  WebviewMediaAutoPlaybackPolicy.requireUserActionForAllMedia:
      'requireUserActionForAllMedia',
  WebviewMediaAutoPlaybackPolicy.alwaysPlayAllMedia: 'alwaysPlayAllMedia',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

const _$WebviewTypeEnumMap = {
  WebviewType.webpage: 'webpage',
  WebviewType.googleMaps: 'googleMaps',
  WebviewType.twitter: 'twitter',
};
