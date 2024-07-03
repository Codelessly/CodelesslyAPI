import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart' hide required;

import '../extensions.dart';
import '../mixins.dart';

part 'text_input_validator_model.g.dart';

/// Represents the type of validator.
enum TextInputValidatorType {
  /// Represents absence of any validation.
  none,

  /// Represents a regular expression based text input validator.
  regex,

  /// Represents a validator for URL input.
  url,
}

/// Represents a text input validator.
sealed class TextInputValidatorModel with EquatableMixin, SerializableMixin {
  /// The name of the validator. This is used to identify the validator.
  final String name;

  /// Whether the input is required. Defaults to `false`. If `true`, the input
  /// must not be empty.
  final bool required;

  /// The type of validator.
  @JsonKey(includeToJson: true, required: true)
  final TextInputValidatorType type;

  /// Creates a new [TextInputValidatorModel] instance.
  const TextInputValidatorModel({
    required this.name,
    this.required = false,
    required this.type,
  });

  /// Creates a [TextInputValidatorModel] instance from a JSON object.
  factory TextInputValidatorModel.fromJson(Map<String, dynamic> json) {
    final TextInputValidatorType type =
        TextInputValidatorType.values.byName(json['type']);
    return switch (type) {
      TextInputValidatorType.none => NoneTextInputValidatorModel.fromJson(json),
      TextInputValidatorType.regex =>
        RegexTextInputValidatorModel.fromJson(json),
      TextInputValidatorType.url => UrlTextInputValidatorModel.fromJson(json)
    };
  }

  /// Allows objects of this class and its subclasses to be used as a function.
  @internal
  String? call(String? input) => validate(input);

  /// Validates the input and returns an error message if the input is invalid.
  /// Returns `null` if the input is valid.
  /// This method should be overridden by the subclasses.
  String? validate(String? input);

  @override
  List<Object?> get props => [name, type, required];

  /// A complete list of built-in validators.
  static const List<TextInputValidatorModel> validators = [
    NoneTextInputValidatorModel(),
    ...RegexTextInputValidatorModel.validators,
    UrlTextInputValidatorModel(),
  ];
}

/// Represents absence of any validation.
// TODO: should this be removed and the validator field be nullable?
@JsonSerializable()
class NoneTextInputValidatorModel extends TextInputValidatorModel {
  /// Creates a new [NoneTextInputValidatorModel] instance.
  const NoneTextInputValidatorModel()
      : super(name: 'None', type: TextInputValidatorType.none);

  @override
  String? validate(String? input) => null;

  /// Creates a [TextInputValidatorModel] instance from a JSON object.
  factory NoneTextInputValidatorModel.fromJson(Map<String, dynamic> json) =>
      _$NoneTextInputValidatorModelFromJson(json);

  @override
  Map toJson() => _$NoneTextInputValidatorModelToJson(this);
}

/// Represents the type of validation to perform.
enum RegexValidationType {
  /// Allow the input if it matches the pattern.
  allow,

  /// Deny the input if it matches the pattern.
  deny,
}

/// Represents a regular expression based text input validator.
@JsonSerializable()
class RegexTextInputValidatorModel extends TextInputValidatorModel {
  /// The regular expression to match the text.
  final String pattern;

  /// The error message to show when the input is invalid. Override the default
  /// [validate] method to have different/multiple error messages on different
  /// conditions.
  final String errorMessage;

  /// Whether the pattern matching should be case sensitive.
  /// Defaults to `true`.
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

  /// The type of validation to perform. Default is [RegexValidationType.allow].
  final RegexValidationType validationType;

  /// Allow only digits in the text field.
  static const RegexTextInputValidatorModel digitsOnly =
      RegexTextInputValidatorModel(
    name: 'Digits Only',
    pattern: r'[0-9]',
    errorMessage: 'Only digits are allowed.',
  );

  /// Allow only alphabets in the text field.
  static const RegexTextInputValidatorModel alphabetsOnly =
      RegexTextInputValidatorModel(
    name: 'Alphabets Only',
    pattern: r'[a-zA-Z]',
    errorMessage: 'Only alphabets are allowed.',
  );

  /// Allow only alphabets and digits in the text field.
  static const RegexTextInputValidatorModel alphanumeric =
      RegexTextInputValidatorModel(
    name: 'Alphanumeric',
    pattern: r'[a-zA-Z0-9]',
    errorMessage: 'Only alphabets and digits are allowed.',
  );

  /// A validator for email addresses.
  static const RegexTextInputValidatorModel email =
      RegexTextInputValidatorModel(
    name: 'Email',
    pattern: r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
    errorMessage: 'Invalid email address.',
  );

  /// A validator for phone numbers.
  static const RegexTextInputValidatorModel phoneNumber =
      RegexTextInputValidatorModel(
    name: 'Phone Number',
    pattern:
        r'^\+?([0-9]{1,4})\)?[-. ]?([0-9]{1,4})[-. ]?([0-9]{1,4})[-. ]?([0-9]{1,4})$',
    errorMessage: 'Invalid phone number.',
  );

  /// A list of built-in regex validators.
  static const List<RegexTextInputValidatorModel> validators = [
    RegexTextInputValidatorModel.digitsOnly,
    RegexTextInputValidatorModel.alphabetsOnly,
    RegexTextInputValidatorModel.alphanumeric,
    RegexTextInputValidatorModel.email,
    RegexTextInputValidatorModel.phoneNumber,
  ];

  /// Creates a new [RegexTextInputValidatorModel] instance with the given pattern.
  const RegexTextInputValidatorModel({
    required super.name,
    required this.pattern,
    required this.errorMessage,
    this.caseSensitive = true,
    this.dotAll = false,
    this.multiLine = false,
    this.unicode = false,
    this.validationType = RegexValidationType.allow,
    super.required,
  }) : super(type: TextInputValidatorType.regex);

  @override
  String? validate(String? input) {
    if (input == null) {
      if (required) return 'This field is required.';
      return null;
    }
    final bool hasExactMatch = regex.hasExactMatch(input);
    final bool isValid = switch (validationType) {
      RegexValidationType.allow => hasExactMatch,
      RegexValidationType.deny => !hasExactMatch,
    };

    if (isValid) return null;
    return errorMessage;
  }

  /// Builds a [RegExp] instance from the [pattern] and other properties like
  /// [caseSensitive], [dotAll], [multiLine], and [unicode].
  RegExp get regex => RegExp(
        pattern,
        caseSensitive: caseSensitive,
        dotAll: dotAll,
        multiLine: multiLine,
        unicode: unicode,
      );

  /// Creates a copy of this instance with the given properties replaced.
  RegexTextInputValidatorModel copyWith({
    String? name,
    String? pattern,
    String? errorMessage,
    bool? caseSensitive,
    bool? dotAll,
    bool? multiLine,
    bool? unicode,
    RegexValidationType? validationType,
    bool? required,
  }) {
    return RegexTextInputValidatorModel(
      name: name ?? this.name,
      pattern: pattern ?? this.pattern,
      errorMessage: errorMessage ?? this.errorMessage,
      caseSensitive: caseSensitive ?? this.caseSensitive,
      dotAll: dotAll ?? this.dotAll,
      multiLine: multiLine ?? this.multiLine,
      unicode: unicode ?? this.unicode,
      validationType: validationType ?? this.validationType,
      required: required ?? this.required,
    );
  }

  /// Creates a [TextInputValidatorModel] instance from a JSON object.
  factory RegexTextInputValidatorModel.fromJson(Map json) =>
      _$RegexTextInputValidatorModelFromJson(json);

  @override
  Map toJson() => _$RegexTextInputValidatorModelToJson(this);

  @override
  List<Object?> get props => [
        ...super.props,
        pattern,
        errorMessage,
        caseSensitive,
        dotAll,
        multiLine,
        unicode,
        validationType,
      ];
}

/// A custom validator that takes a callback function.
@JsonSerializable()
class UrlTextInputValidatorModel extends TextInputValidatorModel {
  /// Custom error message to show when the input is invalid.
  final String? errorMessage;

  /// Creates a new [UrlTextInputValidatorModel] instance.
  const UrlTextInputValidatorModel({
    this.errorMessage,
    super.required,
  }) : super(
          name: 'URL',
          type: TextInputValidatorType.url,
        );

  @override
  String? validate(String? input) {
    if (input == null) {
      if (required) return 'This field is required.';
      return null;
    }
    if (Uri.tryParse(input)?.isAbsolute == true) {
      return null;
    }
    return errorMessage ?? 'Invalid URL.';
  }

  /// Creates a [TextInputValidatorModel] instance from a JSON object.
  factory UrlTextInputValidatorModel.fromJson(Map json) =>
      _$UrlTextInputValidatorModelFromJson(json);

  @override
  Map toJson() => _$UrlTextInputValidatorModelToJson(this);

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
