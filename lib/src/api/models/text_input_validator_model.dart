import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart' hide required;

import '../extensions.dart';
import '../mixins.dart';

part 'text_input_validator_model.g.dart';

/// Represents an action to perform when the user presses the action button on
/// the keyboard.
enum TextInputActionC {
  /// Logical meaning: There is no relevant input action for the current input
  /// source, e.g., [TextField].
  ///
  /// Android: Corresponds to Android's "IME_ACTION_NONE". The keyboard setup
  /// is decided by the OS. The keyboard will likely show a return key.
  ///
  /// iOS: iOS does not have a keyboard return type of "none." It is
  /// inappropriate to choose this [TextInputAction] when running on iOS.
  none,

  /// Logical meaning: Let the OS decide which action is most appropriate.
  ///
  /// Android: Corresponds to Android's "IME_ACTION_UNSPECIFIED". The OS chooses
  /// which keyboard action to display. The decision will likely be a done
  /// button or a return key.
  ///
  /// iOS: Corresponds to iOS's "UIReturnKeyDefault". The title displayed in
  /// the action button is "return".
  unspecified,

  /// Logical meaning: The user is done providing input to a group of inputs
  /// (like a form). Some kind of finalization behavior should now take place.
  ///
  /// Android: Corresponds to Android's "IME_ACTION_DONE". The OS displays a
  /// button that represents completion, e.g., a checkmark button.
  ///
  /// iOS: Corresponds to iOS's "UIReturnKeyDone". The title displayed in the
  /// action button is "Done".
  done,

  /// Logical meaning: The user has entered some text that represents a
  /// destination, e.g., a restaurant name. The "go" button is intended to take
  /// the user to a part of the app that corresponds to this destination.
  ///
  /// Android: Corresponds to Android's "IME_ACTION_GO". The OS displays a
  /// button that represents taking "the user to the target of the text they
  /// typed", e.g., a right-facing arrow button.
  ///
  /// iOS: Corresponds to iOS's "UIReturnKeyGo". The title displayed in the
  /// action button is "Go".
  go,

  /// Logical meaning: Execute a search query.
  ///
  /// Android: Corresponds to Android's "IME_ACTION_SEARCH". The OS displays a
  /// button that represents a search, e.g., a magnifying glass button.
  ///
  /// iOS: Corresponds to iOS's "UIReturnKeySearch". The title displayed in the
  /// action button is "Search".
  search,

  /// Logical meaning: Sends something that the user has composed, e.g., an
  /// email or a text message.
  ///
  /// Android: Corresponds to Android's "IME_ACTION_SEND". The OS displays a
  /// button that represents sending something, e.g., a paper plane button.
  ///
  /// iOS: Corresponds to iOS's "UIReturnKeySend". The title displayed in the
  /// action button is "Send".
  send,

  /// Logical meaning: The user is done with the current input source and wants
  /// to move to the next one.
  ///
  /// Moves the focus to the next focusable item in the same [FocusScope].
  ///
  /// Android: Corresponds to Android's "IME_ACTION_NEXT". The OS displays a
  /// button that represents moving forward, e.g., a right-facing arrow button.
  ///
  /// iOS: Corresponds to iOS's "UIReturnKeyNext". The title displayed in the
  /// action button is "Next".
  next,

  /// Logical meaning: The user wishes to return to the previous input source
  /// in the group, e.g., a form with multiple [TextField]s.
  ///
  /// Moves the focus to the previous focusable item in the same [FocusScope].
  ///
  /// Android: Corresponds to Android's "IME_ACTION_PREVIOUS". The OS displays a
  /// button that represents moving backward, e.g., a left-facing arrow button.
  ///
  /// iOS: iOS does not have a keyboard return type of "previous." It is
  /// inappropriate to choose this [TextInputAction] when running on iOS.
  previous,

  /// Logical meaning: In iOS apps, it is common for a "Back" button and
  /// "Continue" button to appear at the top of the screen. However, when the
  /// keyboard is open, these buttons are often hidden off-screen. Therefore,
  /// the purpose of the "Continue" return key on iOS is to make the "Continue"
  /// button available when the user is entering text.
  ///
  /// Historical context aside, [TextInputAction.continueAction] can be used any
  /// time that the term "Continue" seems most appropriate for the given action.
  ///
  /// Android: Android does not have an IME input type of "continue." It is
  /// inappropriate to choose this [TextInputAction] when running on Android.
  ///
  /// iOS: Corresponds to iOS's "UIReturnKeyContinue". The title displayed in the
  /// action button is "Continue". This action is only available on iOS 9.0+.
  ///
  /// The reason that this value has "Action" post-fixed to it is because
  /// "continue" is a reserved word in Dart, as well as many other languages.
  continueAction,

  /// Logical meaning: The user wants to join something, e.g., a wireless
  /// network.
  ///
  /// Android: Android does not have an IME input type of "join." It is
  /// inappropriate to choose this [TextInputAction] when running on Android.
  ///
  /// iOS: Corresponds to iOS's "UIReturnKeyJoin". The title displayed in the
  /// action button is "Join".
  join,

  /// Logical meaning: The user wants routing options, e.g., driving directions.
  ///
  /// Android: Android does not have an IME input type of "route." It is
  /// inappropriate to choose this [TextInputAction] when running on Android.
  ///
  /// iOS: Corresponds to iOS's "UIReturnKeyRoute". The title displayed in the
  /// action button is "Route".
  route,

  /// Logical meaning: Initiate a call to emergency services.
  ///
  /// Android: Android does not have an IME input type of "emergencyCall." It is
  /// inappropriate to choose this [TextInputAction] when running on Android.
  ///
  /// iOS: Corresponds to iOS's "UIReturnKeyEmergencyCall". The title displayed
  /// in the action button is "Emergency Call".
  emergencyCall,

  /// Logical meaning: Insert a newline character in the focused text input,
  /// e.g., [TextField].
  ///
  /// Android: Corresponds to Android's "IME_ACTION_NONE". The OS displays a
  /// button that represents a new line, e.g., a carriage return button.
  ///
  /// iOS: Corresponds to iOS's "UIReturnKeyDefault". The title displayed in the
  /// action button is "return".
  ///
  /// The term [TextInputAction.newline] exists in Flutter but not in Android
  /// or iOS. The reason for introducing this term is so that developers can
  /// achieve the common result of inserting new lines without needing to
  /// understand the various IME actions on Android and return keys on iOS.
  /// Thus, [TextInputAction.newline] is a convenience term that alleviates the
  /// need to understand the underlying platforms to achieve this common behavior.
  newline;

  /// Displayable string representation of the enum value.
  String get prettify {
    return switch (this) {
      TextInputActionC.none => 'None',
      TextInputActionC.unspecified => 'Unspecified',
      TextInputActionC.done => 'Done',
      TextInputActionC.go => 'Go',
      TextInputActionC.search => 'Search',
      TextInputActionC.send => 'Send',
      TextInputActionC.next => 'Next',
      TextInputActionC.previous => 'Previous',
      TextInputActionC.continueAction => 'Continue',
      TextInputActionC.join => 'Join',
      TextInputActionC.route => 'Route',
      TextInputActionC.emergencyCall => 'Emergency Call',
      TextInputActionC.newline => 'New-line',
    };
  }
}

/// Used to configure the auto validation of [FormField] and [Form] widgets.
enum AutovalidateModeC {
  /// No auto validation will occur.
  disabled('Disabled'),

  /// Used to auto-validate [Form] and [FormField] even without user interaction.
  always('Always'),

  /// Used to auto-validate [Form] and [FormField] only after each user
  /// interaction.
  onUserInteraction('On User Interaction');

  const AutovalidateModeC(this.label);

  /// The label to display in the UI.
  final String label;
}

/// Represents the type of validator.
enum TextInputValidatorType {
  /// Represents absence of any validation.
  none,

  /// Represents a required field validator.
  required,

  /// Represents a regular expression based text input validator.
  regex,

  /// Represents a validator for URL input.
  url,
}

/// Represents a callable validator. [call] method is used to validate
/// the input. This allows the validator to be used as a function.
abstract interface class CallableValidator {
  /// Allows objects of this class and its subclasses to be used as a function.
  String? call(String? input);

  /// Allows to convert a function to a [CallableValidator] instance.
  factory CallableValidator(String? Function(String? input) call) =>
      _CallableValidator(call);
}

/// Internal implementation of [CallableValidator] to allow creating
/// an instance of [CallableValidator] from a function.
class _CallableValidator implements CallableValidator {
  final String? Function(String? input) callback;

  _CallableValidator(this.callback);

  @override
  String? call(String? input) => callback(input);
}

/// Represents a text input validator.
sealed class TextInputValidatorModel
    with EquatableMixin, SerializableMixin
    implements CallableValidator {
  /// The name of the validator. This is used to identify the validator.
  final String name;

  /// The type of validator.
  @JsonKey(includeToJson: true, required: true)
  final TextInputValidatorType type;

  /// Creates a new [TextInputValidatorModel] instance.
  const TextInputValidatorModel({
    required this.name,
    required this.type,
  });

  /// Creates a [TextInputValidatorModel] instance from a JSON object.
  factory TextInputValidatorModel.fromJson(Map<String, dynamic> json) {
    final TextInputValidatorType type =
        TextInputValidatorType.values.byName(json['type']);
    return switch (type) {
      TextInputValidatorType.none => NoneTextInputValidatorModel.fromJson(json),
      TextInputValidatorType.required =>
        RequiredTextInputValidatorModel.fromJson(json),
      TextInputValidatorType.regex =>
        RegexTextInputValidatorModel.fromJson(json),
      TextInputValidatorType.url => UrlTextInputValidatorModel.fromJson(json)
    };
  }

  @internal
  @override
  String? call(String? input) => validate(input);

  /// Validates the input and returns an error message if the input is invalid.
  /// Returns `null` if the input is valid.
  /// This method should be overridden by the subclasses.
  String? validate(String? input);

  @override
  List<Object?> get props => [name, type];

  /// A complete list of built-in validators.
  static const List<TextInputValidatorModel> validators = [
    NoneTextInputValidatorModel(),
    RequiredTextInputValidatorModel(),
    ...RegexTextInputValidatorModel.defaultValidators,
    UrlTextInputValidatorModel(),
  ];

  /// A list of validator names.
  static List<String> validatorNames = [
    for (final validator in validators) validator.name,
  ];

  /// Returns a validator by its name.
  static TextInputValidatorModel byName(String name) => validators.byName(name);

  /// Returns a validator by its name, or `null` if no validator with the given
  /// name exists.
  static TextInputValidatorModel? byNameOrNull(String name) =>
      validators.byNameOrNull(name);
}

/// Represents absence of any validation.
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

/// Represents a configurable text input validator with common properties like
/// required and error message.
sealed class ConfigurableTextInputValidatorModel
    extends TextInputValidatorModel {
  /// Whether the input is required. Defaults to `false`. If `true`, the input
  /// must not be empty.
  final bool required;

  /// The error message to show when the input is invalid. Override the default
  /// [validate] method to have different/multiple error messages on different
  /// conditions.
  final String errorMessage;

  const ConfigurableTextInputValidatorModel({
    required super.name,
    required super.type,
    this.required = false,
    required this.errorMessage,
  });

  /// Creates a copy of this instance with the given properties replaced.
  ConfigurableTextInputValidatorModel copyWith({
    bool? required,
    String? errorMessage,
  });

  @override
  List<Object?> get props => [name, type, required, errorMessage];
}

/// Represents absence of any validation.
@JsonSerializable()
class RequiredTextInputValidatorModel
    extends ConfigurableTextInputValidatorModel {
  /// Creates a new [RequiredTextInputValidatorModel] instance.
  const RequiredTextInputValidatorModel({
    super.errorMessage = 'This field is required.',
  }) : super(
          name: 'Required',
          type: TextInputValidatorType.required,
          required: true,
        );

  @override
  String? validate(String? input) {
    if (input == null || input.isEmpty) return errorMessage;
    return null;
  }

  @override
  RequiredTextInputValidatorModel copyWith({
    bool? required,
    String? errorMessage,
  }) {
    return RequiredTextInputValidatorModel(
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Creates a [TextInputValidatorModel] instance from a JSON object.
  factory RequiredTextInputValidatorModel.fromJson(Map<String, dynamic> json) =>
      _$RequiredTextInputValidatorModelFromJson(json);

  @override
  Map toJson() => _$RequiredTextInputValidatorModelToJson(this);
}

/// Represents a regular expression based text input validator.
@JsonSerializable()
class RegexTextInputValidatorModel extends ConfigurableTextInputValidatorModel {
  /// The regular expression to match the text.
  final String pattern;

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

  /// Whether to allow or deny the pattern match.
  final bool allow;

  /// Whether this is a custom regex validator.
  bool get isCustom => name == 'Custom Regex';

  /// Allow only digits in the text field.
  static const RegexTextInputValidatorModel digitsOnly =
      RegexTextInputValidatorModel(
    name: 'Digits Only',
    pattern: r'^[0-9]+$',
    errorMessage: 'Only digits are allowed.',
  );

  /// Allow only alphabets in the text field.
  static const RegexTextInputValidatorModel alphabetsOnly =
      RegexTextInputValidatorModel(
    name: 'Alphabets Only',
    pattern: r'^[a-zA-Z]+$',
    errorMessage: 'Only alphabets are allowed.',
  );

  /// Allow only alphabets and digits in the text field.
  static const RegexTextInputValidatorModel alphaNumeric =
      RegexTextInputValidatorModel(
    name: 'Alphanumeric',
    pattern: r'^[a-zA-Z0-9]+$',
    errorMessage: 'Only alphabets and digits are allowed.',
  );

  /// A validator for email addresses.
  static const RegexTextInputValidatorModel email =
      RegexTextInputValidatorModel(
    name: 'Email',
    pattern: r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$',
    errorMessage: 'Invalid email address.',
  );

  /// A validator for custom regex patterns.
  static const RegexTextInputValidatorModel custom =
      RegexTextInputValidatorModel(
    name: 'Custom Regex',
    pattern: '',
    errorMessage: 'Invalid',
  );

  /// A list of built-in/default regex validators.
  static const List<RegexTextInputValidatorModel> defaultValidators = [
    RegexTextInputValidatorModel.digitsOnly,
    RegexTextInputValidatorModel.alphabetsOnly,
    RegexTextInputValidatorModel.alphaNumeric,
    RegexTextInputValidatorModel.email,
    RegexTextInputValidatorModel.custom,
  ];

  /// Creates a new [RegexTextInputValidatorModel] instance with the given pattern.
  const RegexTextInputValidatorModel({
    required super.name,
    required this.pattern,
    required super.errorMessage,
    this.caseSensitive = true,
    this.dotAll = false,
    this.multiLine = false,
    this.unicode = false,
    this.allow = true,
    super.required,
  }) : super(type: TextInputValidatorType.regex);

  @override
  String? validate(String? input) {
    if (input == null || input.isEmpty) {
      if (required) return 'This field is required.';
      return null;
    }
    try {
      final bool isValid =
          allow ? regex.hasExactMatch(input) : regex.hasMatch(input);

      if (isValid) return null;
      return errorMessage;
    } on FormatException catch (error, stacktrace) {
      print(error);
      print(stacktrace);
      return 'Invalid pattern!';
    }
  }

  /// Builds a [RegExp] instance from the [pattern] and other properties like
  /// [caseSensitive], [dotAll], [multiLine], and [unicode].
  RegExp get regex {
    // This makes it so if the default/built-in regex validator patterns are
    // ever changed, then it will use the new pattern instead of the old one
    // that was passed in the constructor and stored in the [pattern] field
    // in the database.
    final String effectivePattern =
        defaultValidators.byNameOrNull(name)?.pattern ?? pattern;
    return RegExp(
      effectivePattern,
      caseSensitive: caseSensitive,
      dotAll: dotAll,
      multiLine: multiLine,
      unicode: unicode,
    );
  }

  /// Creates a copy of this instance with the given properties replaced.
  @override
  RegexTextInputValidatorModel copyWith({
    String? pattern,
    String? errorMessage,
    bool? caseSensitive,
    bool? dotAll,
    bool? multiLine,
    bool? unicode,
    bool? allow,
    bool? required,
  }) {
    return RegexTextInputValidatorModel(
      name: name,
      pattern: pattern ?? this.pattern,
      errorMessage: errorMessage ?? this.errorMessage,
      caseSensitive: caseSensitive ?? this.caseSensitive,
      dotAll: dotAll ?? this.dotAll,
      multiLine: multiLine ?? this.multiLine,
      unicode: unicode ?? this.unicode,
      allow: allow ?? this.allow,
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
        caseSensitive,
        dotAll,
        multiLine,
        unicode,
        allow,
      ];
}

/// A custom validator that takes a callback function.
@JsonSerializable()
class UrlTextInputValidatorModel extends ConfigurableTextInputValidatorModel {
  /// Creates a new [UrlTextInputValidatorModel] instance.
  const UrlTextInputValidatorModel({
    super.errorMessage = 'Invalid URL',
    super.required,
  }) : super(name: 'URL', type: TextInputValidatorType.url);

  @override
  String? validate(String? input) {
    if (input == null || input.isEmpty) {
      if (required) return 'This field is required.';
      return null;
    }
    if (Uri.tryParse(input)?.isAbsolute == true) {
      return null;
    }
    return errorMessage;
  }

  /// Creates a copy of this instance with the given properties replaced.
  @override
  UrlTextInputValidatorModel copyWith({
    String? name,
    String? errorMessage,
    bool? required,
  }) {
    return UrlTextInputValidatorModel(
      errorMessage: errorMessage ?? this.errorMessage,
      required: required ?? this.required,
    );
  }

  /// Creates a [TextInputValidatorModel] instance from a JSON object.
  factory UrlTextInputValidatorModel.fromJson(Map json) =>
      _$UrlTextInputValidatorModelFromJson(json);

  @override
  Map toJson() => _$UrlTextInputValidatorModelToJson(this);
}
