// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Represents the type of text input to use for [TextFieldNode]. Corresponds to
/// the [TextInputType] enum in Flutter.
enum TextInputTypeEnum {
  /// Optimize for date and time information.
  ///
  /// On iOS, requests the default keyboard.
  ///
  /// On Android, requests a keyboard with ready access to the number keys,
  /// ":", and "-".
  dateTime,

  /// Optimize for email addresses.
  ///
  /// Requests a keyboard with ready access to the "@" and "." keys.
  emailAddress,

  /// Optimize for multiline textual information.
  ///
  /// Requests the default platform keyboard, but accepts newlines when the
  /// enter key is pressed. This is the input type used for all multiline text
  /// fields.
  multiline,
  // Optimized for a person's name.
  ///
  /// On iOS, requests the
  /// [UIKeyboardType.namePhonePad](https://developer.apple.com/documentation/uikit/uikeyboardtype/namephonepad)
  /// keyboard, a keyboard optimized for entering a person’s name or phone number.
  /// Does not support auto-capitalization.
  ///
  /// On Android, requests a keyboard optimized for
  /// [TYPE_TEXT_VARIATION_PERSON_NAME](https://developer.android.com/reference/android/text/InputType#TYPE_TEXT_VARIATION_PERSON_NAME).
  name,

  /// Prevent the OS from showing the on-screen virtual keyboard.
  none,

  /// Optimize for unsigned numerical information without a decimal point.
  ///
  /// Requests a default keyboard with ready access to the number keys.
  /// Additional options, such as decimal point and/or positive/negative
  /// signs, can be requested using [TextInputTypeEnum.numberWithOptions].
  number,

  /// Optimize for telephone numbers.
  ///
  /// Requests a keyboard with ready access to the number keys, "*", and "#".
  phone,

  /// Optimized for postal mailing addresses.
  ///
  /// On iOS, requests the default keyboard.
  ///
  /// On Android, requests a keyboard optimized for
  /// [TYPE_TEXT_VARIATION_POSTAL_ADDRESS](https://developer.android.com/reference/android/text/InputType#TYPE_TEXT_VARIATION_POSTAL_ADDRESS).
  streetAddress,

  /// Optimize for textual information.
  ///
  /// Requests the default platform keyboard.
  text,

  /// Optimize for URLs.
  ///
  /// Requests a keyboard with ready access to the "/" and "." keys.
  url,

  /// Optimize for passwords that are visible to the user.
  ///
  /// Requests a keyboard with ready access to both letters and numbers.
  visiblePassword;

  /// Displayable string representation of the enum value.
  String get prettify {
    switch (this) {
      case TextInputTypeEnum.dateTime:
        return 'Date-time';
      case TextInputTypeEnum.emailAddress:
        return 'Email address';
      case TextInputTypeEnum.multiline:
        return 'Multi line';
      case TextInputTypeEnum.name:
        return 'Name';
      case TextInputTypeEnum.none:
        return 'None';
      case TextInputTypeEnum.number:
        return 'Number';
      case TextInputTypeEnum.phone:
        return 'Phone';
      case TextInputTypeEnum.streetAddress:
        return 'Street address';
      case TextInputTypeEnum.text:
        return 'Text';
      case TextInputTypeEnum.url:
        return 'URL';
      case TextInputTypeEnum.visiblePassword:
        return 'Visible password';
    }
  }
}
