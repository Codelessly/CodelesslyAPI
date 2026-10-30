import 'package:json_annotation/json_annotation.dart';
import '../../schema/flutter_prop.dart';

import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'text_field_node.g.dart';

/// A text field lets the user enter text, either with hardware keyboard or with
/// an onscreen keyboard.
/// Refer to [TextField](https://api.flutter.dev/flutter/material/TextField-class.html)
/// in Flutter for more details.
@FlutterNode('TextField', family: 'material', nodeType: 'textField')
@JsonSerializable()
class TextFieldNode extends SceneNode
    with ParentReactionMixin, CustomPropertiesMixin {
  @override
  final String type = 'textField';

  /// Holds configurable properties of the text field.
  @override
  covariant TextFieldProperties properties;

  /// Initial text value of the field.
  String initialText = '';

  /// Creates a text field from the given properties.
  TextFieldNode.fromProperties(this.properties)
    : super(
        id: 'textField',
        name: 'TextField',
        basicBoxLocal: NodeBox(0, 0, 250, 48),
      );

  @override
  bool get supportsPadding => true;

  /// Creates a [TextFieldNode] instance with the given data.
  TextFieldNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    bool autoCorrect = true,
    bool autoFocus = false,
    bool enableActiveSelection = true,
    bool enabled = true,
    bool obscureText = false,
    bool readOnly = false,
    bool showCursor = true,
    TextInputTypeEnum keyboardType = TextInputTypeEnum.text,
    BoxHeightStyleEnum selectionHeightStyle = BoxHeightStyleEnum.tight,
    BoxWidthStyleEnum selectionWidthStyle = BoxWidthStyleEnum.tight,
    TextAlignHorizontalEnum textAlign = TextAlignHorizontalEnum.left,
    TextAlignVerticalEnum textAlignVertical = TextAlignVerticalEnum.center,
    ColorRGB cursorColor = ColorRGB.black,
    double cursorHeight = 14,
    double cursorWidth = 2.0,
    double cursorRadius = 2.0,
    int? maxLength,
    int maxLines = 1,
    int? minLines,
    String obscuringCharacter = '•',
    super.visible,
    super.alignment,
    super.padding = const EdgeInsetsModel.symmetric(
      horizontal: 12,
      vertical: 16,
    ),
    super.margin,
    super.rotationDegrees,
    super.reactions,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.constraints,
    super.edgePins,
    super.aspectRatioLock,
    super.parentID,
    super.positioningMode,
    required this.properties,
    this.initialText = '',
  });

  @override
  List<TriggerType> get triggerTypes => [
    TriggerType.changed,
    // TriggerType.editingComplete,
    TriggerType.submitted,
  ];

  @override
  List<ReactionMixin> get reactiveChildren {
    return [
      if (properties.decoration.prefixIcon.icon.show)
        properties.decoration.prefixIcon,
      if (properties.decoration.suffixIcon.icon.show)
        properties.decoration.suffixIcon,
    ];
  }

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    StringValue(name: 'inputValue', value: ''),
    BoolValue(name: 'enabled', value: properties.enabled),
    BoolValue(name: 'obscureText', value: properties.obscureText),
    BoolValue(name: 'readOnly', value: properties.readOnly),
    BoolValue(name: 'showCursor', value: properties.showCursor),
    IntValue(name: 'maxLength', value: properties.maxLength ?? 8),
    BoolValue(name: 'isCollapsed', value: properties.decoration.isCollapsed),
    BoolValue(name: 'isDense', value: properties.decoration.isDense),
    StringValue(
      name: 'labelText',
      value: properties.decoration.labelText ?? '',
    ),
    StringValue(name: 'hintText', value: properties.decoration.hintText ?? ''),
    // The error message under the field. Bind it to a formula such as
    // `${= showErrors && length(note) < 10 ? "Too short" : ""}`: an empty
    // result means no error.
    StringValue(
      name: 'errorText',
      value: properties.decoration.errorText ?? '',
    ),
    // Shows the error borders without a message when true.
    const BoolValue(name: 'error', value: false),
  ];

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'properties': ObjectFieldAccess<TextFieldProperties>(
      'Properties',
      'Properties of the text field.',
      () => properties,
      (value) => properties = value,
    ),
  };

  /// Creates a [TextFieldNode] instance from a JSON object.
  factory TextFieldNode.fromJson(Map json) => _$TextFieldNodeFromJson(json);

  @override
  Map toJson() =>
      _$TextFieldNodeOmitDefaults(this, _$TextFieldNodeToJson(this));
}

/// Holds configurable properties of the text field.
@JsonSerializable()
class TextFieldProperties extends CustomProperties with FieldsHolder {
  /// Whether to enable automatically correct the input text.
  bool autoCorrect;

  /// Whether to focus on text field automatically.
  bool autoFocus;

  /// Whether to enable text selection via mouse drag.
  bool enableInteractiveSelection;

  /// Whether the field is enabled.
  @FlutterProp('enabled', type: 'boolean', group: 'Input', control: 'switch', field: 'properties.enabled')
  bool enabled;

  /// Whether to obscure the input text. Used for password fields.
  @FlutterProp('obscureText', type: 'boolean', group: 'Input', control: 'switch', field: 'properties.obscureText')
  bool obscureText;

  /// Which letters the on-screen keyboard capitalizes by default: none,
  /// the first of each word (names), of each sentence, or every letter.
  @JsonKey(defaultValue: TextCapitalizationC.none)
  TextCapitalizationC textCapitalization;

  /// Whether leaving the field (tapping elsewhere) runs its `submitted`
  /// actions, as well as Enter / the keyboard's done key. Off, only Enter
  /// submits: a form whose submit validates and moves on shouldn't do so
  /// because the user tapped another control.
  @FlutterProp(
    'submitOnUnfocus',
    type: 'boolean',
    group: 'Input',
    control: 'switch',
    field: 'properties.submitOnUnfocus',
  )
  @JsonKey(defaultValue: true)
  bool submitOnUnfocus;

  /// Whether the field is read-only.
  @FlutterProp('readOnly', type: 'boolean', group: 'Input', control: 'switch', field: 'properties.readOnly')
  bool readOnly;

  /// Whether to show the cursor in the field.
  @FlutterProp('showCursor', type: 'boolean', group: 'Appearance', control: 'switch', field: 'properties.showCursor')
  bool showCursor;

  /// Whether to show the decimal key in the soft input keyboard.
  bool showDecimalKey;

  /// Whether to show the sign key in the soft input keyboard.
  bool showSignKey;

  /// The type of keyboard that pops up when inputting text in the field.
  /// For example, if the field should only accept numbers, the keyboard type
  /// should be [TextInputTypeEnum.number].
  TextInputTypeEnum keyboardType;

  /// Defines how the selection highlighter box covers space vertically.
  @JsonKey(unknownEnumValue: BoxHeightStyleEnum.tight)
  BoxHeightStyleEnum selectionHeightStyle;

  /// Defines how the selection highlighter box covers space horizontally.
  @JsonKey(unknownEnumValue: BoxWidthStyleEnum.tight)
  BoxWidthStyleEnum selectionWidthStyle;

  /// Defines how input text is aligned horizontally in the field.
  TextAlignHorizontalEnum textAlign;

  /// Defines how input text is aligned vertically in the field.
  TextAlignVerticalEnum textAlignVertical;

  /// Color of the field cursor.
  ColorRGB cursorColor;

  /// Height of the field cursor.
  @FlutterProp('cursorHeight', type: 'number', group: 'Appearance', control: 'number', field: 'properties.cursorHeight')
  double cursorHeight;

  /// Width of the field cursor.
  @FlutterProp('cursorWidth', type: 'number', group: 'Appearance', control: 'number', field: 'properties.cursorWidth')
  double cursorWidth;

  /// Radius of the field cursor.
  double cursorRadius;

  /// Maximum characters that can be inputted in the field.
  int? maxLength;

  /// Maximum lines of text that appear at a time before the field becomes
  /// scrollable. Null means unlimited: the field grows with its content.
  ///
  /// Stored JSON leaves the key out for the default of 1 and writes an
  /// explicit `null` for unlimited, so both survive a round trip. Designs
  /// saved before null was written have no key and keep reading as 1.
  @JsonKey(
    includeIfNull: true,
    readValue: _readMaxLines,
    fromJson: _maxLinesFromJson,
  )
  int? maxLines;

  /// Maximum lines of text that appear at a time.
  int? minLines;

  /// Defines the character that is used to obscure the text in the field.
  /// Defaults to '•'.
  @FlutterProp('obscuringCharacter', type: 'string', group: 'Input', control: 'text', field: 'properties.obscuringCharacter')
  String obscuringCharacter;

  /// Text style applied to the input text.
  TextProp inputStyle;

  /// Text field decoration.
  InputDecorationModel decoration;

  /// Whether the field expands vertically.
  @FlutterProp('expands', type: 'boolean', group: 'Layout', control: 'switch', field: 'properties.expands')
  bool expands;

  /// Formatter to apply to the text field input.
  TextInputFormatterModel formatter;

  /// Validator to apply to the text field input.
  TextInputValidatorModel validator;

  /// Represents when to autovalidate the field. Defaults to
  /// [AutovalidateModeC.onUserInteraction].
  AutovalidateModeC autovalidateMode;

  /// A list of autofill hints that the field should provide to underlying
  /// device's autofill service.
  Set<TextInputAutofillHints> autofillHints;

  /// The action the keyboard should take when the user presses the action
  /// button on the keyboard.
  TextInputActionC textInputAction;

  /// Creates a [TextFieldProperties] instance with the given data.
  TextFieldProperties({
    this.autoCorrect = true,
    this.autoFocus = false,
    this.enableInteractiveSelection = true,
    this.enabled = true,
    this.obscureText = false,
    this.textCapitalization = TextCapitalizationC.none,
    this.submitOnUnfocus = true,
    this.readOnly = false,
    this.showCursor = true,
    this.keyboardType = TextInputTypeEnum.text,
    this.selectionHeightStyle = BoxHeightStyleEnum.tight,
    this.selectionWidthStyle = BoxWidthStyleEnum.tight,
    this.textAlign = TextAlignHorizontalEnum.left,
    this.textAlignVertical = TextAlignVerticalEnum.center,
    this.cursorColor = ColorRGB.black,
    this.cursorHeight = 14,
    this.cursorWidth = 2.0,
    this.cursorRadius = 2.0,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.obscuringCharacter = '•',
    TextProp? inputStyle,
    InputDecorationModel? decoration,
    this.expands = false,
    this.showDecimalKey = false,
    this.showSignKey = false,
    this.formatter = const NoneTextInputFormatterModel(),
    this.validator = const NoneTextInputValidatorModel(),
    this.autovalidateMode = AutovalidateModeC.onUserInteraction,
    this.autofillHints = const {},
    this.textInputAction = TextInputActionC.none,
  }) : inputStyle =
           inputStyle ??
           TextProp.general(fontSize: 14, fills: [PaintModel.blackPaint]),
       decoration = decoration ?? InputDecorationModel();

  /// Duplicates this [TextFieldProperties] instance with the given data
  /// overrides.
  TextFieldProperties copyWith({
    bool? autoCorrect,
    bool? autoFocus,
    bool? enableInteractiveSelection,
    bool? enabled,
    bool? obscureText,
    TextCapitalizationC? textCapitalization,
    bool? submitOnUnfocus,
    bool? readOnly,
    bool? showCursor,
    TextInputTypeEnum? keyboardType,
    BoxHeightStyleEnum? selectionHeightStyle,
    BoxWidthStyleEnum? selectionWidthStyle,
    TextAlignHorizontalEnum? textAlign,
    TextAlignVerticalEnum? textAlignVertical,
    ColorRGB? cursorColor,
    double? cursorHeight,
    double? cursorWidth,
    double? cursorRadius,
    int? maxLength,
    int? maxLines,
    int? minLines,
    String? obscuringCharacter,
    TextProp? inputStyle,
    InputDecorationModel? decoration,
    bool? expands,
    bool? showDecimalKey,
    bool? showSignKey,
    TextInputFormatterModel? formatter,
    TextInputValidatorModel? validator,
    Set<TextInputAutofillHints>? autofillHints,
    AutovalidateModeC? autovalidateMode,
    TextInputActionC? textInputAction,
  }) {
    return TextFieldProperties(
      autoCorrect: autoCorrect ?? this.autoCorrect,
      autoFocus: autoFocus ?? this.autoFocus,
      enableInteractiveSelection:
          enableInteractiveSelection ?? this.enableInteractiveSelection,
      enabled: enabled ?? this.enabled,
      obscureText: obscureText ?? this.obscureText,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      submitOnUnfocus: submitOnUnfocus ?? this.submitOnUnfocus,
      readOnly: readOnly ?? this.readOnly,
      showCursor: showCursor ?? this.showCursor,
      keyboardType: keyboardType ?? this.keyboardType,
      selectionHeightStyle: selectionHeightStyle ?? this.selectionHeightStyle,
      selectionWidthStyle: selectionWidthStyle ?? this.selectionWidthStyle,
      textAlign: textAlign ?? this.textAlign,
      textAlignVertical: textAlignVertical ?? this.textAlignVertical,
      cursorColor: cursorColor ?? this.cursorColor,
      cursorHeight: cursorHeight ?? this.cursorHeight,
      cursorWidth: cursorWidth ?? this.cursorWidth,
      cursorRadius: cursorRadius ?? this.cursorRadius,
      maxLength: maxLength ?? this.maxLength,
      maxLines: maxLines ?? this.maxLines,
      minLines: minLines ?? this.minLines,
      obscuringCharacter: obscuringCharacter ?? this.obscuringCharacter,
      inputStyle: inputStyle ?? this.inputStyle,
      decoration: decoration ?? this.decoration,
      expands: expands ?? this.expands,
      showDecimalKey: showDecimalKey ?? this.showDecimalKey,
      showSignKey: showSignKey ?? this.showSignKey,
      formatter: formatter ?? this.formatter,
      validator: validator ?? this.validator,
      autofillHints: autofillHints ?? this.autofillHints,
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      textInputAction: textInputAction ?? this.textInputAction,
    );
  }

  /// Creates a [TextFieldProperties] instance from a JSON object.
  factory TextFieldProperties.fromJson(Map json) =>
      _$TextFieldPropertiesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TextFieldPropertiesOmitDefaults(
    this,
    _$TextFieldPropertiesToJson(this),
  );

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'autoCorrect': BoolFieldAccess(
      'Auto Correct',
      'Whether to enable automatically correct the input text.',
      () => autoCorrect,
      (value) => autoCorrect = value,
    ),
    'autoFocus': BoolFieldAccess(
      'Auto Focus',
      'Whether to focus on text field automatically.',
      () => autoFocus,
      (value) => autoFocus = value,
    ),
    'enableInteractiveSelection': BoolFieldAccess(
      'Enable Interactive Selection',
      'Whether to enable text selection via mouse drag.',
      () => enableInteractiveSelection,
      (value) => enableInteractiveSelection = value,
    ),
    'enabled': BoolFieldAccess(
      'Enabled',
      'Whether the field is enabled.',
      () => enabled,
      (value) => enabled = value,
    ),
    'obscureText': BoolFieldAccess(
      'Obscure Text',
      'Whether to obscure the input text. Used for password fields.',
      () => obscureText,
      (value) => obscureText = value,
    ),
    'readOnly': BoolFieldAccess(
      'Read Only',
      'Whether the field is read-only.',
      () => readOnly,
      (value) => readOnly = value,
    ),
    'showCursor': BoolFieldAccess(
      'Show Cursor',
      'Whether to show the cursor in the field.',
      () => showCursor,
      (value) => showCursor = value,
    ),
    'showDecimalKey': BoolFieldAccess(
      'Show Decimal Key',
      'Whether to show the decimal key in the soft input keyboard.',
      () => showDecimalKey,
      (value) => showDecimalKey = value,
    ),
    'showSignKey': BoolFieldAccess(
      'Show Sign Key',
      'Whether to show the sign key in the soft input keyboard.',
      () => showSignKey,
      (value) => showSignKey = value,
    ),
    'keyboardType': EnumFieldAccess<TextInputTypeEnum>(
      'Keyboard Type',
      'The type of keyboard that pops up when inputting text in the field. For example, if the field should only accept numbers, the keyboard type should be [TextInputTypeEnum.number].',
      () => keyboardType,
      (value) => keyboardType = value,
      defaultValue: () => TextInputTypeEnum.text,
      options: () => TextInputTypeEnum.values,
    ),
    'selectionHeightStyle': EnumFieldAccess<BoxHeightStyleEnum>(
      'Selection Height Style',
      'Defines how the selection highlighter box covers space vertically.',
      () => selectionHeightStyle,
      (value) => selectionHeightStyle = value,
      defaultValue: () => BoxHeightStyleEnum.tight,
      options: () => BoxHeightStyleEnum.values,
    ),
    'selectionWidthStyle': EnumFieldAccess<BoxWidthStyleEnum>(
      'Selection Width Style',
      'Defines how the selection highlighter box covers space horizontally.',
      () => selectionWidthStyle,
      (value) => selectionWidthStyle = value,
      defaultValue: () => BoxWidthStyleEnum.tight,
      options: () => BoxWidthStyleEnum.values,
    ),
    'textAlign': EnumFieldAccess<TextAlignHorizontalEnum>(
      'Text Align',
      'Defines how input text is aligned horizontally in the field.',
      () => textAlign,
      (value) => textAlign = value,
      defaultValue: () => TextAlignHorizontalEnum.left,
      options: () => TextAlignHorizontalEnum.values,
      requiresLayout: true,
    ),
    'textAlignVertical': EnumFieldAccess<TextAlignVerticalEnum>(
      'Text Align Vertical',
      'Defines how input text is aligned vertically in the field.',
      () => textAlignVertical,
      (value) => textAlignVertical = value,
      defaultValue: () => TextAlignVerticalEnum.center,
      options: () => TextAlignVerticalEnum.values,
      requiresLayout: true,
    ),
    'cursorColor': ColorFieldAccess<ColorRGB>(
      'Cursor Color',
      'Color of the field cursor.',
      () => cursorColor,
      (value) => cursorColor = value,
    ),
    'cursorHeight': NumFieldAccess<double>(
      'Cursor Height',
      'Height of the field cursor.',
      () => cursorHeight,
      (value) => cursorHeight = value,
      requiresLayout: true,
    ),
    'cursorWidth': NumFieldAccess<double>(
      'Cursor Width',
      'Width of the field cursor.',
      () => cursorWidth,
      (value) => cursorWidth = value,
    ),
    'cursorRadius': NumFieldAccess<double>(
      'Cursor Radius',
      'Radius of the field cursor.',
      () => cursorRadius,
      (value) => cursorRadius = value,
    ),
    'maxLength': NumFieldAccess<int?>(
      'Max Length',
      'Maximum characters that can be inputted in the field.',
      () => maxLength,
      (value) => maxLength = value,
    ),
    'maxLines': NumFieldAccess<int?>(
      'Max Lines',
      'Maximum lines of text that appear at a time before the field becomes scrollable.',
      () => maxLines,
      (value) => maxLines = value,
      requiresLayout: true,
    ),
    'minLines': NumFieldAccess<int?>(
      'Min Lines',
      'Maximum lines of text that appear at a time.',
      () => minLines,
      (value) => minLines = value,
      requiresLayout: true,
    ),
    'obscuringCharacter': StringFieldAccess(
      'Obscuring Character',
      'Defines the character that is used to obscure the text in the field. Defaults to \'•\'.',
      () => obscuringCharacter,
      (value) => obscuringCharacter = value,
    ),
    'inputStyle': TextStyleFieldAccess<TextProp>(
      'Input Style',
      'Text style applied to the input text.',
      () => inputStyle,
      (value) => inputStyle = value,
      requiresLayout: true,
    ),
    'expands': BoolFieldAccess(
      'Expands',
      'Whether the field expands vertically.',
      () => expands,
      (value) => expands = value,
      requiresLayout: true,
    ),
    'autovalidateMode': EnumFieldAccess<AutovalidateModeC>(
      'Autovalidate Mode',
      'Represents when to autovalidate the field. Defaults to [AutovalidateModeC.onUserInteraction].',
      () => autovalidateMode,
      (value) => autovalidateMode = value,
      defaultValue: () => AutovalidateModeC.onUserInteraction,
      options: () => AutovalidateModeC.values,
    ),
    'textInputAction': EnumFieldAccess<TextInputActionC>(
      'Text Input Action',
      'The action the keyboard should take when the user presses the action button on the keyboard.',
      () => textInputAction,
      (value) => textInputAction = value,
      defaultValue: () => TextInputActionC.none,
      options: () => TextInputActionC.values,
    ),
  };

  @override
  List<Object?> get props => [
    textCapitalization,
    submitOnUnfocus,
    autoCorrect,
    autoFocus,
    enableInteractiveSelection,
    enabled,
    obscureText,
    readOnly,
    showCursor,
    keyboardType,
    selectionHeightStyle,
    selectionWidthStyle,
    textAlign,
    textAlignVertical,
    cursorColor,
    cursorHeight,
    cursorWidth,
    cursorRadius,
    maxLength,
    maxLines,
    minLines,
    obscuringCharacter,
    inputStyle,
    decoration,
    expands,
    showDecimalKey,
    showSignKey,
    formatter,
    validator,
    autofillHints,
    autovalidateMode,
    textInputAction,
  ];
}

/// Reads `maxLines`: a missing key is the default of 1, while an explicit
/// `null` means unlimited lines.
///
/// An explicit null is passed on as [_unlimitedLines] because the generated
/// reader replaces a null result with the constructor default of 1.
Object? _readMaxLines(Map json, String key) =>
    json.containsKey(key) ? (json[key] ?? _unlimitedLines) : 1;

/// Converts what [_readMaxLines] returned into the field value.
int? _maxLinesFromJson(Object? value) => value is num ? value.toInt() : null;

/// Marks an explicit `null` (unlimited lines) between [_readMaxLines] and
/// [_maxLinesFromJson].
const String _unlimitedLines = 'unlimited';

/// Which letters the keyboard capitalizes by default; mirrors Flutter's
/// `TextCapitalization`.
enum TextCapitalizationC {
  /// No automatic capitalization.
  none,

  /// The first letter of each word: names.
  words,

  /// The first letter of each sentence.
  sentences,

  /// Every letter.
  characters,
}
