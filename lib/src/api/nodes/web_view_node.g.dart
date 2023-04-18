// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_view_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebViewNode _$WebViewNodeFromJson(Map json) => WebViewNode(
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
      properties: WebViewProperties.fromJson(json['properties'] as Map),
      variables: (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {},
    )
      ..widthFactor = (json['widthFactor'] as num?)?.toDouble()
      ..heightFactor = (json['heightFactor'] as num?)?.toDouble()
      ..multipleVariables = (json['multipleVariables'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          {}
      ..type = json['type'] as String;

Map<String, dynamic> _$WebViewNodeToJson(WebViewNode instance) {
  final val = <String, dynamic>{
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
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('widthFactor', instance.widthFactor);
  writeNotNull('heightFactor', instance.heightFactor);
  val['variables'] = instance.variables;
  val['multipleVariables'] = instance.multipleVariables;
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

WebPageWebViewProperties _$WebPageWebViewPropertiesFromJson(Map json) =>
    WebPageWebViewProperties(
      pageSourceType: $enumDecode(
          _$WebViewWebpageSourceTypeEnumMap, json['pageSourceType']),
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
              _$WebViewMediaAutoPlaybackPolicyEnumMap,
              json['mediaAutoPlaybackPolicy']) ??
          WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia,
      backgroundColor: json['backgroundColor'] == null
          ? null
          : ColorRGBA.fromJson(json['backgroundColor'] as Map),
    )
      ..src = _$JsonConverterFromJson<String, String?>(
          json['src'], const Base64JsonConverter().fromJson)
      ..webviewType = $enumDecode(_$WebViewTypeEnumMap, json['webviewType']);

Map<String, dynamic> _$WebPageWebViewPropertiesToJson(
    WebPageWebViewProperties instance) {
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
  val['mediaAutoPlaybackPolicy'] = _$WebViewMediaAutoPlaybackPolicyEnumMap[
      instance.mediaAutoPlaybackPolicy]!;
  writeNotNull('backgroundColor', instance.backgroundColor?.toJson());
  val['pageSourceType'] =
      _$WebViewWebpageSourceTypeEnumMap[instance.pageSourceType]!;
  val['input'] = instance.input;
  val['webviewType'] = _$WebViewTypeEnumMap[instance.webviewType]!;
  return val;
}

const _$WebViewWebpageSourceTypeEnumMap = {
  WebViewWebpageSourceType.url: 'url',
  WebViewWebpageSourceType.html: 'html',
  WebViewWebpageSourceType.asset: 'asset',
};

const _$WebViewMediaAutoPlaybackPolicyEnumMap = {
  WebViewMediaAutoPlaybackPolicy.requireUserActionForAllMedia:
      'requireUserActionForAllMedia',
  WebViewMediaAutoPlaybackPolicy.alwaysPlayAllMedia: 'alwaysPlayAllMedia',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

const _$WebViewTypeEnumMap = {
  WebViewType.webpage: 'webpage',
  WebViewType.googleMaps: 'googleMaps',
  WebViewType.twitter: 'twitter',
};
