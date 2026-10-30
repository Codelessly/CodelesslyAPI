// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signature_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$SignatureNodeOmitDefaults(
  SignatureNode instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.value, [])) json.remove('value');
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
  if (isJsonDefault(instance.floating, false)) json.remove('floating');
  if (isJsonDefault(instance.variables, {})) json.remove('variables');
  if (isJsonDefault(instance.multipleVariables, {}))
    json.remove('multipleVariables');
  if (isJsonDefault(instance.componentVersion, 1))
    json.remove('componentVersion');
  if (isJsonDefault(instance.componentSchema, {}))
    json.remove('componentSchema');
  if (isJsonDefault(instance.reactions, const [])) json.remove('reactions');
  return json;
}

Map<String, dynamic> _$SignaturePropertiesOmitDefaults(
  SignatureProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.inkColor, kSignatureDefaultInkColor))
    json.remove('inkColor');
  if (isJsonDefault(instance.inkWidth, 2.6)) json.remove('inkWidth');
  if (isJsonDefault(instance.backgroundColor, kSignatureDefaultBackgroundColor))
    json.remove('backgroundColor');
  if (isJsonDefault(instance.borderColor, kSignatureDefaultBorderColor))
    json.remove('borderColor');
  if (isJsonDefault(instance.borderWidth, 1.5)) json.remove('borderWidth');
  if (isJsonDefault(instance.errorBorderColor, kSignatureDefaultErrorColor))
    json.remove('errorBorderColor');
  if (isJsonDefault(instance.errorBorderWidth, 2))
    json.remove('errorBorderWidth');
  if (isJsonDefault(
    instance.cornerRadius,
    const CornerRadius.all(RadiusModel.circular(4)),
  ))
    json.remove('cornerRadius');
  if (isJsonDefault(instance.placeholder, kSignatureDefaultPlaceholder))
    json.remove('placeholder');
  if (isJsonDefault(instance.placeholderColor, kSignatureDefaultBorderColor))
    json.remove('placeholderColor');
  if (isJsonDefault(instance.placeholderFontSize, 12))
    json.remove('placeholderFontSize');
  if (isJsonDefault(instance.showSignLine, true)) json.remove('showSignLine');
  if (isJsonDefault(instance.signLineColor, kSignatureDefaultBorderColor))
    json.remove('signLineColor');
  if (isJsonDefault(instance.error, false)) json.remove('error');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignatureNode _$SignatureNodeFromJson(Map json) =>
    SignatureNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
        value: strokesFromJson(json['value']),
        visible: json['visible'] as bool? ?? true,
        enabled: json['enabled'] as bool? ?? true,
        alignment: json['alignment'] == null
            ? AlignmentModel.none
            : AlignmentModel.fromJson(json['alignment'] as Map),
        padding: json['padding'] == null
            ? EdgeInsetsModel.zero
            : EdgeInsetsModel.fromJson(json['padding']),
        margin: json['margin'] == null
            ? EdgeInsetsModel.zero
            : EdgeInsetsModel.fromJson(json['margin']),
        rotationDegrees: json['rotation'] == null
            ? 0
            : castRotation(json['rotation']),
        reactions:
            (json['reactions'] as List<dynamic>?)
                ?.map((e) => Reaction.fromJson(e as Map))
                .toList() ??
            const [],
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
        aspectRatioLock: json['aspectRatioLock'] as bool? ?? false,
        edgePins: json['edgePins'] == null
            ? EdgePinsModel.standard
            : EdgePinsModel.fromJson(
                Map<String, dynamic>.from(json['edgePins'] as Map),
              ),
        positioningMode:
            $enumDecodeNullable(
              _$PositioningModeEnumMap,
              json['positioningMode'],
            ) ??
            PositioningMode.align,
        properties: SignatureProperties.fromJson(json['properties'] as Map),
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
      ..motion = json['motion'] == null
          ? null
          : MotionModel.fromJson(json['motion'] as Map)
      ..floating = json['floating'] as bool? ?? false
      ..type = json['type'] as String;

Map<String, dynamic> _$SignatureNodeToJson(SignatureNode instance) =>
    <String, dynamic>{
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
      'squeezable': instance.squeezable,
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
      'enabled': instance.enabled,
      'motion': ?instance.motion?.toJson(),
      'floating': instance.floating,
      'type': instance.type,
      'properties': instance.properties.toJson(),
      'value': instance.value,
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
};

SignatureProperties _$SignaturePropertiesFromJson(
  Map json,
) => SignatureProperties(
  inkColor: json['inkColor'] == null
      ? kSignatureDefaultInkColor
      : ColorRGBA.fromJson(json['inkColor']),
  inkWidth: (json['inkWidth'] as num?)?.toDouble() ?? 2.6,
  backgroundColor: json['backgroundColor'] == null
      ? kSignatureDefaultBackgroundColor
      : ColorRGBA.fromJson(json['backgroundColor']),
  borderColor: json['borderColor'] == null
      ? kSignatureDefaultBorderColor
      : ColorRGBA.fromJson(json['borderColor']),
  borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 1.5,
  errorBorderColor: json['errorBorderColor'] == null
      ? kSignatureDefaultErrorColor
      : ColorRGBA.fromJson(json['errorBorderColor']),
  errorBorderWidth: (json['errorBorderWidth'] as num?)?.toDouble() ?? 2,
  cornerRadius: json['cornerRadius'] == null
      ? const CornerRadius.all(RadiusModel.circular(4))
      : CornerRadius.fromJson(json['cornerRadius']),
  placeholder: json['placeholder'] as String? ?? kSignatureDefaultPlaceholder,
  placeholderColor: json['placeholderColor'] == null
      ? kSignatureDefaultBorderColor
      : ColorRGBA.fromJson(json['placeholderColor']),
  placeholderFontSize: (json['placeholderFontSize'] as num?)?.toDouble() ?? 12,
  showSignLine: json['showSignLine'] as bool? ?? true,
  signLineColor: json['signLineColor'] == null
      ? kSignatureDefaultBorderColor
      : ColorRGBA.fromJson(json['signLineColor']),
  error: json['error'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
);

Map<String, dynamic> _$SignaturePropertiesToJson(
  SignatureProperties instance,
) => <String, dynamic>{
  'inkColor': instance.inkColor.toJson(),
  'inkWidth': instance.inkWidth,
  'backgroundColor': instance.backgroundColor.toJson(),
  'borderColor': instance.borderColor.toJson(),
  'borderWidth': instance.borderWidth,
  'errorBorderColor': instance.errorBorderColor.toJson(),
  'errorBorderWidth': instance.errorBorderWidth,
  'cornerRadius': instance.cornerRadius.toJson(),
  'placeholder': instance.placeholder,
  'placeholderColor': instance.placeholderColor.toJson(),
  'placeholderFontSize': instance.placeholderFontSize,
  'showSignLine': instance.showSignLine,
  'signLineColor': instance.signLineColor.toJson(),
  'error': instance.error,
  'enabled': instance.enabled,
};
