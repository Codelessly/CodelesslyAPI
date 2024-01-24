/// Enum representing different types of text field validators.
///
/// Each value represents a specific type of validation that
/// can be applied to a text field.
enum TextInputValidatorC {
  /// A validator that does not perform any validation.
  none('None'),

  /// A validator that verifies that the text field's value is not empty.
  required('Required'),

  /// A validator that verifies that the text field's value is a valid
  /// email address.
  email('Email'),

  /// A validator that verifies that the text field's value is a valid
  /// phone number.
  phoneNumber('Phone Number'),

  /// A validator that verifies that the text field's value is a valid
  /// URL.
  url('URL');

  /// The name of the validator.
  final String label;

  /// Creates a new instance of the [TextInputValidatorC] enum.
  const TextInputValidatorC(this.label);
}
