import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../mixins.dart';

part 'text_input_formatter_model.g.dart';

/// Text formatters that can be applied to the text field input to restrict the
/// input to a specific format.
@JsonSerializable()
class TextInputFormatterModel with EquatableMixin, SerializableMixin {
  /// The regular expression to match the text.
  final String pattern;

  /// The name of the formatter.
  final String name;

  /// Allow only digits in the text field.
  static const TextInputFormatterModel none = TextInputFormatterModel(
    name: 'None',
    pattern: r'.*',
  );

  /// Allow only digits in the text field.
  static const TextInputFormatterModel digitsOnly = TextInputFormatterModel(
    name: 'Digits Only',
    pattern: r'[0-9]',
  );

  /// Allow only alphabets in the text field.
  static const TextInputFormatterModel alphabetsOnly =
      TextInputFormatterModel(name: 'Alphabets Only', pattern: r'[a-zA-Z]');

  /// Allow only alpha-numeric characters in the text field.
  static const TextInputFormatterModel alphaNumeric =
      TextInputFormatterModel(name: 'Alpha-numeric', pattern: r'[a-zA-Z0-9]');

  /// Allow only phone number format in the text field.
  static const TextInputFormatterModel noSpaces =
      TextInputFormatterModel(name: 'No Spaces', pattern: r'^[^\s]*$');

  /// Allow only email format in the text field.
  static const TextInputFormatterModel email =
      TextInputFormatterModel(name: 'Email', pattern: '^(|\\S)+\$');

  /// Allow only phone number format in the text field.
  static const TextInputFormatterModel phoneNumber =
      TextInputFormatterModel(name: 'Phone Number', pattern: r'^+?[0-9]*$');

  /// List of all available text field formatters.
  static const List<TextInputFormatterModel> values = [
    none,
    digitsOnly,
    alphabetsOnly,
    alphaNumeric,
    noSpaces,
    email,
    phoneNumber,
  ];

  /// Returns true if the formatter is [none].
  bool get isNone => this == none;

  /// Creates a new [TextInputFormatterModel] instance with the given pattern.
  const TextInputFormatterModel({required this.name, required this.pattern});

  /// copyWith
  TextInputFormatterModel copyWith({
    String? name,
    String? pattern,
  }) {
    return TextInputFormatterModel(
      name: name ?? this.name,
      pattern: pattern ?? this.pattern,
    );
  }

  /// Creates a [TextInputFormatterModel] instance from a JSON object.
  factory TextInputFormatterModel.fromJson(Map json) =>
      _$TextInputFormatterModelFromJson(json);

  @override
  Map toJson() => _$TextInputFormatterModelToJson(this);

  @override
  List<Object?> get props => [name];
}
