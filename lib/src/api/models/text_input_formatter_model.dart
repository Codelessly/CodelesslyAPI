import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../../codelessly_api.dart';

part 'text_input_formatter_model.g.dart';

/// Represents the type of formatter.
enum TextInputFormatterType {
  /// Equivalent to no formatter.
  none,

  /// A formatter that uses a regular expression to match the text.
  regex,
}

/// Text formatters that can be applied to the text field input to restrict the
/// input to a specific format.
sealed class TextInputFormatterModel with EquatableMixin, SerializableMixin {
  /// The name of the formatter.
  final String name;

  /// The type of formatter.
  @JsonKey(required: true, includeToJson: true)
  final TextInputFormatterType type;

  /// Creates a new [TextInputFormatterModel] instance.
  const TextInputFormatterModel({required this.name, required this.type});

  /// Creates a [TextInputFormatterModel] instance from a JSON object.
  factory TextInputFormatterModel.fromJson(Map<String, dynamic> json) {
    final TextInputFormatterType type =
        TextInputFormatterType.values.byName(json['type']);
    return switch (type) {
      TextInputFormatterType.none => NoneTextInputFormatterModel.fromJson(json),
      TextInputFormatterType.regex =>
        RegexTextInputFormatterModel.fromJson(json),
    };
  }

  /// A list of all available text field formatters.
  static const List<TextInputFormatterModel> formatters = [
    NoneTextInputFormatterModel(),
    ...RegexTextInputFormatterModel.formatters,
  ];

  /// A list of all available text field formatter names.
  static List<String> formatterNames = [
    for (final formatter in formatters) formatter.name,
  ];

  @override
  List<Object?> get props => [name, type];
}

/// A formatter than does not restrict the input in any way.
@JsonSerializable()
class NoneTextInputFormatterModel extends TextInputFormatterModel {
  /// Creates a new [NoneTextInputFormatterModel] instance.
  const NoneTextInputFormatterModel()
      : super(name: 'None', type: TextInputFormatterType.none);

  /// Creates a [TextInputFormatterModel] instance from a JSON object.
  factory NoneTextInputFormatterModel.fromJson(Map<String, dynamic> json) =>
      _$NoneTextInputFormatterModelFromJson(json);

  @override
  Map toJson() => _$NoneTextInputFormatterModelToJson(this);
}

/// Text formatters that can be applied to the text field input to restrict the
/// input to a specific format.
@JsonSerializable()
class RegexTextInputFormatterModel extends TextInputFormatterModel {
  /// The regular expression to match the text.
  final String pattern;

  /// Whether the regex pattern is case sensitive.
  final bool caseSensitive;

  /// Whether the `.` pattern should match all characters, including
  /// line terminators.
  /// Defaults to `false`.
  final bool dotAll;

  /// Whether the pattern should match across multiple lines.
  /// Defaults to `false`.
  final bool multiLine;

  /// Whether the pattern should match unicode characters.
  /// Defaults to `false`.
  final bool unicode;

  /// The string to replace the unmatched text with.
  final String replacementString;

  /// Whether to allow or deny the pattern match.
  final bool allow;

  /// Allow only digits in the text field.
  static const RegexTextInputFormatterModel none = RegexTextInputFormatterModel(
    name: 'None',
    pattern: r'.*',
  );

  /// Allow only digits in the text field.
  static const RegexTextInputFormatterModel digitsOnly =
      RegexTextInputFormatterModel(
    name: 'Digits Only',
    pattern: r'[0-9]',
  );

  /// Allow only alphabets in the text field.
  static const RegexTextInputFormatterModel alphabetsOnly =
      RegexTextInputFormatterModel(
          name: 'Alphabets Only', pattern: r'[a-zA-Z]');

  /// Allow only alpha-numeric characters in the text field.
  static const RegexTextInputFormatterModel alphaNumeric =
      RegexTextInputFormatterModel(
          name: 'Alpha-numeric', pattern: r'[a-zA-Z0-9]');

  /// Allow only phone number format in the text field.
  static const RegexTextInputFormatterModel noSpaces =
      RegexTextInputFormatterModel(name: 'No Spaces', pattern: r'[\S]');

  /// Allow only phone number format in the text field.
  static const RegexTextInputFormatterModel custom =
      RegexTextInputFormatterModel(name: 'Custom Regex', pattern: r'');

  /// Whether the formatter is a custom formatter.
  bool get isCustom => name == custom.name;

  /// List of all available text field formatters.
  static const List<RegexTextInputFormatterModel> formatters = [
    digitsOnly,
    alphabetsOnly,
    alphaNumeric,
    noSpaces,
    custom,
  ];

  /// Creates a new [RegexTextInputFormatterModel] instance with the given pattern.
  const RegexTextInputFormatterModel({
    required super.name,
    required this.pattern,
    this.allow = true,
    this.caseSensitive = true,
    this.dotAll = false,
    this.multiLine = false,
    this.unicode = false,
    this.replacementString = '',
  }) : super(type: TextInputFormatterType.regex);

  /// copyWith
  RegexTextInputFormatterModel copyWith({
    String? pattern,
    bool? caseSensitive,
    bool? dotAll,
    bool? multiLine,
    bool? unicode,
    bool? allow,
    String? replacementString,
  }) {
    return RegexTextInputFormatterModel(
      name: name,
      pattern: pattern ?? this.pattern,
      caseSensitive: caseSensitive ?? this.caseSensitive,
      dotAll: dotAll ?? this.dotAll,
      multiLine: multiLine ?? this.multiLine,
      unicode: unicode ?? this.unicode,
      allow: allow ?? this.allow,
      replacementString: replacementString ?? this.replacementString,
    );
  }

  /// Creates a [TextInputFormatterModel] instance from a JSON object.
  factory RegexTextInputFormatterModel.fromJson(Map json) =>
      _$RegexTextInputFormatterModelFromJson(json);

  @override
  Map toJson() => _$RegexTextInputFormatterModelToJson(this);

  @override
  List<Object?> get props => [
        ...super.props,
        pattern,
        caseSensitive,
        dotAll,
        multiLine,
        unicode,
        replacementString,
        allow,
      ];
}
