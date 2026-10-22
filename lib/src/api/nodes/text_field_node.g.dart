// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_field_node.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$TextFieldNodeOmitDefaults(
  TextFieldNode instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.initialText, '')) json.remove('initialText');
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
  if (isJsonDefault(instance.aspectRatioLock, false))
    json.remove('aspectRatioLock');
  if (isJsonDefault(instance.alignment, AlignmentModel.none))
    json.remove('alignment');
  if (isJsonDefault(instance.margin, EdgeInsetsModel.zero))
    json.remove('margin');
  if (isJsonDefault(
    instance.padding,
    const EdgeInsetsModel.symmetric(horizontal: 12, vertical: 16),
  ))
    json.remove('padding');
  if (isJsonDefault(instance.rotationDegrees, 0)) json.remove('rotation');
  if (isJsonDefault(instance.interactionStates, {}))
    json.remove('interactionStates');
  if (isJsonDefault(instance.tooltip, '')) json.remove('tooltip');
  if (isJsonDefault(instance.zoomable, false)) json.remove('zoomable');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
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

Map<String, dynamic> _$TextFieldPropertiesOmitDefaults(
  TextFieldProperties instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.autoCorrect, true)) json.remove('autoCorrect');
  if (isJsonDefault(instance.autoFocus, false)) json.remove('autoFocus');
  if (isJsonDefault(instance.enableInteractiveSelection, true))
    json.remove('enableInteractiveSelection');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.obscureText, false)) json.remove('obscureText');
  if (isJsonDefault(instance.readOnly, false)) json.remove('readOnly');
  if (isJsonDefault(instance.showCursor, true)) json.remove('showCursor');
  if (isJsonDefault(instance.showDecimalKey, false))
    json.remove('showDecimalKey');
  if (isJsonDefault(instance.showSignKey, false)) json.remove('showSignKey');
  if (isJsonDefault(instance.keyboardType, TextInputTypeEnum.text))
    json.remove('keyboardType');
  if (isJsonDefault(instance.selectionHeightStyle, BoxHeightStyleEnum.tight))
    json.remove('selectionHeightStyle');
  if (isJsonDefault(instance.selectionWidthStyle, BoxWidthStyleEnum.tight))
    json.remove('selectionWidthStyle');
  if (isJsonDefault(instance.textAlign, TextAlignHorizontalEnum.left))
    json.remove('textAlign');
  if (isJsonDefault(instance.textAlignVertical, TextAlignVerticalEnum.center))
    json.remove('textAlignVertical');
  if (isJsonDefault(instance.cursorColor, ColorRGB.black))
    json.remove('cursorColor');
  if (isJsonDefault(instance.cursorHeight, 14)) json.remove('cursorHeight');
  if (isJsonDefault(instance.cursorWidth, 2.0)) json.remove('cursorWidth');
  if (isJsonDefault(instance.cursorRadius, 2.0)) json.remove('cursorRadius');
  if (isJsonDefault(instance.maxLines, 1)) json.remove('maxLines');
  if (isJsonDefault(instance.obscuringCharacter, '•'))
    json.remove('obscuringCharacter');
  if (isJsonDefault(instance.expands, false)) json.remove('expands');
  if (isJsonDefault(instance.formatter, const NoneTextInputFormatterModel()))
    json.remove('formatter');
  if (isJsonDefault(instance.validator, const NoneTextInputValidatorModel()))
    json.remove('validator');
  if (isJsonDefault(
    instance.autovalidateMode,
    AutovalidateModeC.onUserInteraction,
  ))
    json.remove('autovalidateMode');
  if (isJsonDefault(instance.autofillHints, const <Object?>{}))
    json.remove('autofillHints');
  if (isJsonDefault(instance.textInputAction, TextInputActionC.none))
    json.remove('textInputAction');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextFieldNode _$TextFieldNodeFromJson(Map json) =>
    TextFieldNode(
        id: json['id'] as String,
        name: json['name'] as String,
        basicBoxLocal: NodeBox.fromJson(json['basicBoxLocal']),
        enabled: json['enabled'] as bool? ?? true,
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
        properties: TextFieldProperties.fromJson(json['properties'] as Map),
        initialText: json['initialText'] as String? ?? '',
      )
      ..variables =
          (json['variables'] as Map?)?.map(
            (k, e) => MapEntry(k as String, e as String),
          ) ??
          {}
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
      ..type = json['type'] as String;

Map<String, dynamic> _$TextFieldNodeToJson(TextFieldNode instance) =>
    <String, dynamic>{
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
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
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
      'enabled': instance.enabled,
      'type': instance.type,
      'properties': instance.properties.toJson(),
      'initialText': instance.initialText,
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

TextFieldProperties _$TextFieldPropertiesFromJson(
  Map json,
) => TextFieldProperties(
  autoCorrect: json['autoCorrect'] as bool? ?? true,
  autoFocus: json['autoFocus'] as bool? ?? false,
  enableInteractiveSelection:
      json['enableInteractiveSelection'] as bool? ?? true,
  enabled: json['enabled'] as bool? ?? true,
  obscureText: json['obscureText'] as bool? ?? false,
  readOnly: json['readOnly'] as bool? ?? false,
  showCursor: json['showCursor'] as bool? ?? true,
  keyboardType:
      $enumDecodeNullable(_$TextInputTypeEnumEnumMap, json['keyboardType']) ??
      TextInputTypeEnum.text,
  selectionHeightStyle:
      $enumDecodeNullable(
        _$BoxHeightStyleEnumEnumMap,
        json['selectionHeightStyle'],
        unknownValue: BoxHeightStyleEnum.tight,
      ) ??
      BoxHeightStyleEnum.tight,
  selectionWidthStyle:
      $enumDecodeNullable(
        _$BoxWidthStyleEnumEnumMap,
        json['selectionWidthStyle'],
        unknownValue: BoxWidthStyleEnum.tight,
      ) ??
      BoxWidthStyleEnum.tight,
  textAlign:
      $enumDecodeNullable(
        _$TextAlignHorizontalEnumEnumMap,
        json['textAlign'],
      ) ??
      TextAlignHorizontalEnum.left,
  textAlignVertical:
      $enumDecodeNullable(
        _$TextAlignVerticalEnumEnumMap,
        json['textAlignVertical'],
      ) ??
      TextAlignVerticalEnum.center,
  cursorColor: json['cursorColor'] == null
      ? ColorRGB.black
      : ColorRGB.fromJson(json['cursorColor']),
  cursorHeight: (json['cursorHeight'] as num?)?.toDouble() ?? 14,
  cursorWidth: (json['cursorWidth'] as num?)?.toDouble() ?? 2.0,
  cursorRadius: (json['cursorRadius'] as num?)?.toDouble() ?? 2.0,
  maxLength: (json['maxLength'] as num?)?.toInt(),
  maxLines: _readMaxLines(json, 'maxLines') == null
      ? 1
      : _maxLinesFromJson(_readMaxLines(json, 'maxLines')),
  minLines: (json['minLines'] as num?)?.toInt(),
  obscuringCharacter: json['obscuringCharacter'] as String? ?? '•',
  inputStyle: json['inputStyle'] == null
      ? null
      : TextProp.fromJson(json['inputStyle'] as Map),
  decoration: json['decoration'] == null
      ? null
      : InputDecorationModel.fromJson(json['decoration'] as Map),
  expands: json['expands'] as bool? ?? false,
  showDecimalKey: json['showDecimalKey'] as bool? ?? false,
  showSignKey: json['showSignKey'] as bool? ?? false,
  formatter: json['formatter'] == null
      ? const NoneTextInputFormatterModel()
      : TextInputFormatterModel.fromJson(
          Map<String, dynamic>.from(json['formatter'] as Map),
        ),
  validator: json['validator'] == null
      ? const NoneTextInputValidatorModel()
      : TextInputValidatorModel.fromJson(
          Map<String, dynamic>.from(json['validator'] as Map),
        ),
  autovalidateMode:
      $enumDecodeNullable(
        _$AutovalidateModeCEnumMap,
        json['autovalidateMode'],
      ) ??
      AutovalidateModeC.onUserInteraction,
  autofillHints:
      (json['autofillHints'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$TextInputAutofillHintsEnumMap, e))
          .toSet() ??
      const {},
  textInputAction:
      $enumDecodeNullable(_$TextInputActionCEnumMap, json['textInputAction']) ??
      TextInputActionC.none,
);

Map<String, dynamic> _$TextFieldPropertiesToJson(
  TextFieldProperties instance,
) => <String, dynamic>{
  'autoCorrect': instance.autoCorrect,
  'autoFocus': instance.autoFocus,
  'enableInteractiveSelection': instance.enableInteractiveSelection,
  'enabled': instance.enabled,
  'obscureText': instance.obscureText,
  'readOnly': instance.readOnly,
  'showCursor': instance.showCursor,
  'showDecimalKey': instance.showDecimalKey,
  'showSignKey': instance.showSignKey,
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
  'maxLength': ?instance.maxLength,
  'maxLines': instance.maxLines,
  'minLines': ?instance.minLines,
  'obscuringCharacter': instance.obscuringCharacter,
  'inputStyle': instance.inputStyle.toJson(),
  'decoration': instance.decoration.toJson(),
  'expands': instance.expands,
  'formatter': instance.formatter.toJson(),
  'validator': instance.validator.toJson(),
  'autovalidateMode': _$AutovalidateModeCEnumMap[instance.autovalidateMode]!,
  'autofillHints': instance.autofillHints
      .map((e) => _$TextInputAutofillHintsEnumMap[e]!)
      .toList(),
  'textInputAction': _$TextInputActionCEnumMap[instance.textInputAction]!,
};

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
  TextInputTypeEnum.webSearch: 'webSearch',
  TextInputTypeEnum.twitter: 'twitter',
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
  TextAlignHorizontalEnum.start: 'start',
  TextAlignHorizontalEnum.end: 'end',
};

const _$TextAlignVerticalEnumEnumMap = {
  TextAlignVerticalEnum.top: 'top',
  TextAlignVerticalEnum.center: 'center',
  TextAlignVerticalEnum.bottom: 'bottom',
};

const _$AutovalidateModeCEnumMap = {
  AutovalidateModeC.disabled: 'disabled',
  AutovalidateModeC.always: 'always',
  AutovalidateModeC.onUserInteraction: 'onUserInteraction',
  AutovalidateModeC.onUnfocus: 'onUnfocus',
  AutovalidateModeC.onUserInteractionIfError: 'onUserInteractionIfError',
};

const _$TextInputAutofillHintsEnumMap = {
  TextInputAutofillHints.addressCity: 'addressCity',
  TextInputAutofillHints.addressCityAndState: 'addressCityAndState',
  TextInputAutofillHints.addressState: 'addressState',
  TextInputAutofillHints.birthday: 'birthday',
  TextInputAutofillHints.birthdayDay: 'birthdayDay',
  TextInputAutofillHints.birthdayMonth: 'birthdayMonth',
  TextInputAutofillHints.birthdayYear: 'birthdayYear',
  TextInputAutofillHints.countryCode: 'countryCode',
  TextInputAutofillHints.countryName: 'countryName',
  TextInputAutofillHints.creditCardExpirationDate: 'creditCardExpirationDate',
  TextInputAutofillHints.creditCardExpirationDay: 'creditCardExpirationDay',
  TextInputAutofillHints.creditCardExpirationMonth: 'creditCardExpirationMonth',
  TextInputAutofillHints.creditCardExpirationYear: 'creditCardExpirationYear',
  TextInputAutofillHints.creditCardFamilyName: 'creditCardFamilyName',
  TextInputAutofillHints.creditCardGivenName: 'creditCardGivenName',
  TextInputAutofillHints.creditCardMiddleName: 'creditCardMiddleName',
  TextInputAutofillHints.creditCardName: 'creditCardName',
  TextInputAutofillHints.creditCardNumber: 'creditCardNumber',
  TextInputAutofillHints.creditCardSecurityCode: 'creditCardSecurityCode',
  TextInputAutofillHints.creditCardType: 'creditCardType',
  TextInputAutofillHints.email: 'email',
  TextInputAutofillHints.familyName: 'familyName',
  TextInputAutofillHints.fullStreetAddress: 'fullStreetAddress',
  TextInputAutofillHints.gender: 'gender',
  TextInputAutofillHints.givenName: 'givenName',
  TextInputAutofillHints.impp: 'impp',
  TextInputAutofillHints.jobTitle: 'jobTitle',
  TextInputAutofillHints.language: 'language',
  TextInputAutofillHints.location: 'location',
  TextInputAutofillHints.middleInitial: 'middleInitial',
  TextInputAutofillHints.middleName: 'middleName',
  TextInputAutofillHints.name: 'name',
  TextInputAutofillHints.namePrefix: 'namePrefix',
  TextInputAutofillHints.nameSuffix: 'nameSuffix',
  TextInputAutofillHints.newPassword: 'newPassword',
  TextInputAutofillHints.newUsername: 'newUsername',
  TextInputAutofillHints.nickname: 'nickname',
  TextInputAutofillHints.oneTimeCode: 'oneTimeCode',
  TextInputAutofillHints.organizationName: 'organizationName',
  TextInputAutofillHints.password: 'password',
  TextInputAutofillHints.photo: 'photo',
  TextInputAutofillHints.postalAddress: 'postalAddress',
  TextInputAutofillHints.postalAddressExtended: 'postalAddressExtended',
  TextInputAutofillHints.postalAddressExtendedPostalCode:
      'postalAddressExtendedPostalCode',
  TextInputAutofillHints.postalCode: 'postalCode',
  TextInputAutofillHints.streetAddressLevel1: 'streetAddressLevel1',
  TextInputAutofillHints.streetAddressLevel2: 'streetAddressLevel2',
  TextInputAutofillHints.streetAddressLevel3: 'streetAddressLevel3',
  TextInputAutofillHints.streetAddressLevel4: 'streetAddressLevel4',
  TextInputAutofillHints.streetAddressLine1: 'streetAddressLine1',
  TextInputAutofillHints.streetAddressLine2: 'streetAddressLine2',
  TextInputAutofillHints.streetAddressLine3: 'streetAddressLine3',
  TextInputAutofillHints.sublocality: 'sublocality',
  TextInputAutofillHints.telephoneNumber: 'telephoneNumber',
  TextInputAutofillHints.telephoneNumberAreaCode: 'telephoneNumberAreaCode',
  TextInputAutofillHints.telephoneNumberCountryCode:
      'telephoneNumberCountryCode',
  TextInputAutofillHints.telephoneNumberDevice: 'telephoneNumberDevice',
  TextInputAutofillHints.telephoneNumberExtension: 'telephoneNumberExtension',
  TextInputAutofillHints.telephoneNumberLocal: 'telephoneNumberLocal',
  TextInputAutofillHints.telephoneNumberLocalPrefix:
      'telephoneNumberLocalPrefix',
  TextInputAutofillHints.telephoneNumberLocalSuffix:
      'telephoneNumberLocalSuffix',
  TextInputAutofillHints.telephoneNumberNational: 'telephoneNumberNational',
  TextInputAutofillHints.transactionAmount: 'transactionAmount',
  TextInputAutofillHints.transactionCurrency: 'transactionCurrency',
  TextInputAutofillHints.url: 'url',
  TextInputAutofillHints.username: 'username',
};

const _$TextInputActionCEnumMap = {
  TextInputActionC.none: 'none',
  TextInputActionC.unspecified: 'unspecified',
  TextInputActionC.done: 'done',
  TextInputActionC.go: 'go',
  TextInputActionC.search: 'search',
  TextInputActionC.send: 'send',
  TextInputActionC.next: 'next',
  TextInputActionC.previous: 'previous',
  TextInputActionC.continueAction: 'continueAction',
  TextInputActionC.join: 'join',
  TextInputActionC.route: 'route',
  TextInputActionC.emergencyCall: 'emergencyCall',
  TextInputActionC.newline: 'newline',
};
