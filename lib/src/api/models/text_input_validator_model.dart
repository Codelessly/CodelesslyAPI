import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../mixins.dart';

part 'text_input_validator_model.g.dart';

/// Text formatters that can be applied to the text field input to restrict the
/// input to a specific format.
@JsonSerializable()
class TextInputValidatorModel with EquatableMixin, SerializableMixin {
  /// The regular expression to match the text.
  final String pattern;

  /// The name of the formatter.
  final String name;

  /// The error message to show when the input is invalid.
  final String errorMessage;

  /// Allow only digits in the text field.
  static const TextInputValidatorModel none = TextInputValidatorModel(
    name: 'None',
    pattern: r'.*',
    errorMessage: '',
  );

  /// Allow only digits in the text field.
  static const TextInputValidatorModel digitsOnly = TextInputValidatorModel(
    name: 'Digits Only',
    pattern: r'[0-9]',
    errorMessage: 'Only digits are allowed.',
  );

  /// List of all available text field formatters.
  static const List<TextInputValidatorModel> values = [
    none,
    digitsOnly,
  ];

  /// Returns true if the formatter is [none].
  bool get isNone => this == none;

  /// Creates a new [TextInputValidatorModel] instance with the given pattern.
  const TextInputValidatorModel({
    required this.name,
    required this.pattern,
    required this.errorMessage,
  });

  /// Validates the input against the pattern. This can be used to use
  /// this class as a function.
  String? call(String? value) => validate(value);

  /// Validates the input against the pattern.
  String? validate(String? input) {
    // check if the input perfectly matches the pattern.
    if (RegExp(pattern).firstMatch(input ?? '')
        case RegExpMatch(start: var start, end: var end)) {
      if (start == 0 && end == (input?.length ?? 0)) {
        // A perfect match. This is valid.
        return null;
      }
    }
    return errorMessage;
  }

  /// copyWith
  TextInputValidatorModel copyWith({
    String? name,
    String? pattern,
    String? errorMessage,
  }) {
    return TextInputValidatorModel(
      name: name ?? this.name,
      pattern: pattern ?? this.pattern,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Creates a [TextInputValidatorModel] instance from a JSON object.
  factory TextInputValidatorModel.fromJson(Map json) =>
      _$TextInputValidatorModelFromJson(json);

  @override
  Map toJson() => _$TextInputValidatorModelToJson(this);

  @override
  List<Object?> get props => [name];
}
