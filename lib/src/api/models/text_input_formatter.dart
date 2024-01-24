/// An enum that represents the different types of text input formatters
/// that can be applied to a text field.
enum TextInputFormatterC {
  /// A formatter that prevents the text field from accepting slashes / in
  /// its value.
  noSlashes('No slashes'),

  /// A formatter that prevents the text field from accepting spaces in
  /// its value.
  noSpaces('No spaces'),

  /// A formatter that prevents the text field from accepting special
  /// characters in its value.
  noSpecialCharacters('No special characters'),

  /// A formatter that only allows the text field to accept letters in
  /// its value.
  lettersOnly('Letters only'),

  /// A formatter that only allows the text field to accept numbers in
  /// its value.
  numericOnly('Numbers only'),

  /// A formatter that only allows the text field to accept alphanumeric
  /// characters in its value.
  alphaNumericOnly('Letters & numbers only'),

  /// A formatter that only allows the text field to accept numbers and
  /// symbols in its value. (ex: phone numbers).
  numbersAndSymbolsOnly('Numbers & symbols only'),

  /// A formatter that does not apply any formatting to the text field.
  none('None');

  /// The name of the formatter.
  final String label;

  /// Creates a new instance of the [TextInputFormatterC] enum.
  const TextInputFormatterC(this.label);
}
