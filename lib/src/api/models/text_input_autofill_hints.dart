/// A list of strings that helps the autofill service identify the type of this
/// text input.
///
/// Pulled from [AutofillHints] at [flutter/lib/src/services/autofill.dart].
enum TextInputAutofillHints {
  /// The input field expects an address locality (city/town).
  addressCity(
    'addressCity',
    'Address City',
    'The input field expects an address locality (city/town).',
    '''
This hint will be translated to the below values on different platforms:
   
* Android: [AUTOFILL_HINT_POSTAL_ADDRESS_LOCALITY](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_POSTAL_ADDRESS_LOCALITY).
* iOS: [addressCity](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a city name combined with a state name.
  addressCityAndState(
    'addressCityAndState',
    'Address City And State',
    'The input field expects a city name combined with a state name.',
    '''
This hint will be translated to the below values on different platforms:

* iOS: [addressCityAndState](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* Otherwise, the hint string will be used as-is.
''',
  ),

  /// The input field expects a region/state.
  addressState(
    'addressState',
    'Address State',
    'The input field expects a region/state.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_POSTAL_ADDRESS_REGION](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_POSTAL_ADDRESS_REGION).
* iOS: [addressState](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* Otherwise, the hint string will be used as-is.
''',
  ),

  /// The input field expects a person's full birth date.
  birthday(
    'birthday',
    'Birthday',
    "The input field expects a person's full birth date.",
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_BIRTH_DATE_FULL](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_BIRTH_DATE_FULL).
* web: ["bday"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
  ''',
  ),

  /// The input field expects a person's birth day(of the month).
  birthdayDay(
    'birthdayDay',
    'Birthday Day',
    "The input field expects a person's birth day(of the month).",
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_BIRTH_DATE_DAY](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_BIRTH_DATE_DAY).
* web: ["bday-day"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
  ''',
  ),

  /// The input field expects a person's birth month.
  birthdayMonth(
    'birthdayMonth',
    'Birthday Month',
    "The input field expects a person's birth month.",
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_BIRTH_DATE_MONTH](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_BIRTH_DATE_MONTH).
* web: ["bday-month"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
  ''',
  ),

  /// The input field expects a person's birth year.
  birthdayYear(
    'birthdayYear',
    'Birthday Year',
    "The input field expects a person's birth year.",
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_BIRTH_DATE_YEAR](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_BIRTH_DATE_YEAR).
* web: ["bday-year"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
  ''',
  ),

  /// The input field expects an
  /// [ISO 3166-1-alpha-2](https://www.iso.org/standard/63545.html) country code.
  countryCode(
    'countryCode',
    'Country Code',
    'The input field expects an ISO 3166-1-alpha-2 country code.',
    '''
This hint will be translated to the below values on different platforms:

* web: ["country"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
  ''',
  ),

  /// The input field expects a country name.
  countryName(
    'countryName',
    'Country Name',
    'The input field expects a country name.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_POSTAL_ADDRESS_COUNTRY](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_POSTAL_ADDRESS_COUNTRY).
* iOS: [countryName](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["country-name"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
  ''',
  ),

  /// The input field expects a credit card expiration date.
  creditCardExpirationDate(
    'creditCardExpirationDate',
    'Credit Card Expiration Date',
    'The input field expects a credit card expiration date.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_CREDIT_CARD_NUMBER](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_CREDIT_CARD_NUMBER).
* web: ["cc-exp"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
  ''',
  ),

  /// The input field expects a credit card expiration day.
  creditCardExpirationDay(
    'creditCardExpirationDay',
    'Credit Card Expiration Day',
    'The input field expects a credit card expiration day.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_CREDIT_CARD_EXPIRATION_DAY](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_CREDIT_CARD_EXPIRATION_DAY).
* Otherwise, the hint string will be used as-is.
''',
  ),

  /// The input field expects a credit card expiration month.
  creditCardExpirationMonth(
    'creditCardExpirationMonth',
    'Credit Card Expiration Month',
    'The input field expects a credit card expiration month.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_CREDIT_CARD_EXPIRATION_MONTH](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_CREDIT_CARD_EXPIRATION_MONTH).
* web: ["cc-exp-month"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
''',
  ),

  /// The input field expects a credit card expiration year.
  creditCardExpirationYear(
    'creditCardExpirationYear',
    'Credit Card Expiration Year',
    'The input field expects a credit card expiration year.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_CREDIT_CARD_EXPIRATION_YEAR](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_CREDIT_CARD_EXPIRATION_YEAR).
* web: ["cc-exp-year"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects the holder's last/family name as given on a credit
  /// card.
  creditCardFamilyName(
    'creditCardFamilyName',
    'Credit Card Family Name',
    "The input field expects the holder's last/family name as given on a credit card.",
    '''
This hint will be translated to the below values on different platforms:

* web: ["cc-family-name"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects the holder's first/given name as given on a credit
  /// card.
  creditCardGivenName(
    'creditCardGivenName',
    'Credit Card Given Name',
    "The input field expects the holder's first/given name as given on a credit card.",
    '''
This hint will be translated to the below values on different platforms:

* web: ["cc-given-name"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects the holder's middle name as given on a credit
  /// card.
  creditCardMiddleName(
    'creditCardMiddleName',
    'Credit Card Middle Name',
    "The input field expects the holder's middle name as given on a credit card.",
    '''
This hint will be translated to the below values on different platforms:

* web: ["cc-additional-name"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects the holder's full name as given on a credit card.
  creditCardName(
    'creditCardName',
    'Credit Card Name',
    "The input field expects the holder's full name as given on a credit card.",
    '''
This hint will be translated to the below values on different platforms:

* web: ["cc-name"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a credit card number.
  creditCardNumber(
    'creditCardNumber',
    'Credit Card Number',
    'The input field expects a credit card number.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_CREDIT_CARD_NUMBER](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_CREDIT_CARD_NUMBER).
* iOS: [creditCardNumber](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["cc-number"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a credit card security code.
  creditCardSecurityCode(
    'creditCardSecurityCode',
    'Credit Card Security Code',
    'The input field expects a credit card security code.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_CREDIT_CARD_SECURITY_CODE](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_CREDIT_CARD_SECURITY_CODE).
* web: ["cc-csc"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects the type of a credit card, for example "Visa".
  creditCardType(
    'creditCardType',
    'Credit Card Type',
    'The input field expects the type of a credit card, for example "Visa".',
    '''
This hint will be translated to the below values on different platforms:

* web: ["cc-type"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects an email address.
  email(
    'email',
    'Email',
    'The input field expects an email address.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_EMAIL_ADDRESS](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_EMAIL_ADDRESS).
* iOS: [emailAddress](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["email"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a person's last/family name.
  familyName(
    'familyName',
    'Family Name',
    "The input field expects a person's last/family name.",
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_PERSON_NAME_FAMILY](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_PERSON_NAME_FAMILY).
* iOS: [familyName](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["family-name"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a street address that fully identifies a location.
  fullStreetAddress(
    'fullStreetAddress',
    'Full Street Address',
    'The input field expects a street address that fully identifies a location.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_POSTAL_ADDRESS_STREET_ADDRESS](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_POSTAL_ADDRESS_STREET_ADDRESS).
* iOS: [fullStreetAddress](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["street-address"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a gender.
  gender(
    'gender',
    'Gender',
    'The input field expects a gender.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_GENDER](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_GENDER).
* web: ["sex"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a person's first/given name.
  givenName(
    'givenName',
    'Given Name',
    "The input field expects a person's first/given name.",
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_PERSON_NAME_GIVEN](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_PERSON_NAME_GIVEN).
* iOS: [givenName](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["given-name"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a URL representing an instant messaging protocol
  /// endpoint.
  impp(
    'impp',
    'IMPP Code',
    'The input field expects a URL representing an instant messaging protocol endpoint.',
    '''
This hint will be translated to the below values on different platforms:

* web: ["impp"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a job title.
  jobTitle(
    'jobTitle',
    'Job Title',
    'The input field expects a job title.',
    '''
This hint will be translated to the below values on different platforms:

* iOS: [jobTitle](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["organization-title"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects the preferred language of the user.
  language(
    'language',
    'Language',
    'The input field expects the preferred language of the user.',
    '''
This hint will be translated to the below values on different platforms:

* web: ["language"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a location, such as a point of interest, an
  /// address,or another way to identify a location.
  location(
    'location',
    'Location',
    'The input field expects a location, such as a point of interest, an address, or another way to identify a location.',
    '''
This hint will be translated to the below values on different platforms:

* iOS: [location](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a person's middle initial.
  middleInitial(
    'middleInitial',
    'Middle Initial',
    "The input field expects a person's middle initial.",
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_PERSON_NAME_MIDDLE_INITIAL](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_PERSON_NAME_MIDDLE_INITIAL).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a person's middle name.
  middleName(
    'middleName',
    'Middle Name',
    "The input field expects a person's middle name.",
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_PERSON_NAME_MIDDLE](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_PERSON_NAME_MIDDLE).
* iOS: [middleName](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["additional-name"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a person's full name.
  name(
    'name',
    'Name',
    "The input field expects a person's full name.",
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_PERSON_NAME](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_PERSON_NAME).
* iOS: [name](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["name"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a person's name prefix or title, such as "Dr.".
  namePrefix(
    'namePrefix',
    'Name Prefix',
    "The input field expects a person's name prefix or title, such as 'Dr.'.",
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_PERSON_NAME_PREFIX](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_PERSON_NAME_PREFIX).
* iOS: [namePrefix](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["honorific-prefix"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
''',
  ),

  /// The input field expects a person's name suffix, such as "Jr.".
  nameSuffix(
    'nameSuffix',
    'Name Suffix',
    "The input field expects a person's name suffix, such as 'Jr.'.",
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_PERSON_NAME_SUFFIX](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_PERSON_NAME_SUFFIX).
* iOS: [nameSuffix](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["honorific-suffix"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a newly created password for save/update.
  newPassword(
    'newPassword',
    'New Password',
    'The input field expects a newly created password for save/update.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_NEW_PASSWORD](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_NEW_PASSWORD).
* iOS: [newPassword](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["new-password"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a newly created username for save/update.
  newUsername(
    'newUsername',
    'New Username',
    'The input field expects a newly created username for save/update.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_NEW_USERNAME](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_NEW_USERNAME).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a nickname.
  nickname(
    'nickname',
    'Nickname',
    'The input field expects a nickname.',
    '''
This hint will be translated to the below values on different platforms:

* iOS: [nickname](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["nickname"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a SMS one-time code.
  oneTimeCode(
    'oneTimeCode',
    'One Time Code (OTP)',
    'The input field expects a SMS one-time code.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_SMS_OTP](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_SMS_OTP).
* iOS: [oneTimeCode](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["one-time-code"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects an organization name corresponding to the person,
  /// address, or contact information in the other fields associated with this
  /// field.
  organizationName(
    'organizationName',
    'Organization Name',
    'The input field expects an organization name corresponding to the person, address, or contact information in the other fields associated with this field.',
    '''
This hint will be translated to the below values on different platforms:

* iOS: [organizationName](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["organization"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a password.
  password(
    'password',
    'Password',
    'The input field expects a password.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_PASSWORD](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_PASSWORD).
* iOS: [password](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["current-password"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a photograph, icon, or other image corresponding
  /// to the company, person, address, or contact information in the other
  /// fields associated with this field.
  photo(
    'photo',
    'Photo',
    'The input field expects a photograph, icon, or other image corresponding to the company, person, address, or contact information in the other fields associated with this field.',
    '''
This hint will be translated to the below values on different platforms:

* web: ["photo"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a postal address.
  postalAddress(
    'postalAddress',
    'Postal Address',
    'The input field expects a postal address.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_POSTAL_ADDRESS](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_POSTAL_ADDRESS).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects an auxiliary address details.
  postalAddressExtended(
    'postalAddressExtended',
    'Postal Address Extended',
    'The input field expects an auxiliary address details.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_POSTAL_ADDRESS_EXTENDED_ADDRESS](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_POSTAL_ADDRESS_EXTENDED_ADDRESS).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects an extended ZIP/POSTAL code.
  postalAddressExtendedPostalCode(
    'postalAddressExtendedPostalCode',
    'Postal Address Extended Postal Code',
    'The input field expects an extended ZIP/POSTAL code.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_POSTAL_ADDRESS_EXTENDED_POSTAL_CODE](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_POSTAL_ADDRESS_EXTENDED_POSTAL_CODE).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a postal code.
  postalCode(
    'postalCode',
    'Postal Code',
    'The input field expects a postal code.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_POSTAL_CODE](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_POSTAL_CODE).
* iOS: [postalCode](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["postal-code"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The first administrative level in the address. This is typically the
  /// province in which the address is located. In the United States, this would
  /// be the state. In Switzerland, the canton. In the United Kingdom, the post
  /// town.
  streetAddressLevel1(
    'streetAddressLevel1',
    'Street Address Level 1',
    'The first administrative level in the address. This is typically the province in which the address is located. In the United States, this would be the state. In Switzerland, the canton. In the United Kingdom, the post town.',
    '''
This hint will be translated to the below values on different platforms:

* web: ["address-level1"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The second administrative level, in addresses with at least two of them.
  /// In countries with two administrative levels, this would typically be the
  /// city, town, village, or other locality in which the address is located.
  streetAddressLevel2(
    'streetAddressLevel2',
    'Street Address Level 2',
    'The second administrative level, in addresses with at least two of them. In countries with two administrative levels, this would typically be the city, town, village, or other locality in which the address is located.',
    '''
This hint will be translated to the below values on different platforms:

* web: ["address-level2"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The third administrative level, in addresses with at least three
  /// administrative levels.
  streetAddressLevel3(
    'streetAddressLevel3',
    'Street Address Level 3',
    'The third administrative level, in addresses with at least three administrative levels.',
    '''
This hint will be translated to the below values on different platforms:

* web: ["address-level3"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The finest-grained administrative level, in addresses which have four
  /// levels.
  streetAddressLevel4(
    'streetAddressLevel4',
    'Street Address Level 4',
    'The finest-grained administrative level, in addresses which have four levels.',
    '''
This hint will be translated to the below values on different platforms:

* web: ["address-level4"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects the first line of a street address.
  streetAddressLine1(
    'streetAddressLine1',
    'Street Address Line 1',
    'The input field expects the first line of a street address.',
    '''
This hint will be translated to the below values on different platforms:

* iOS: [streetAddressLine1](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["address-line1"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects the second line of a street address.
  streetAddressLine2(
    'streetAddressLine2',
    'Street Address Line 2',
    'The input field expects the second line of a street address.',
    '''
This hint will be translated to the below values on different platforms:

* iOS: [streetAddressLine2](https://developer.apple.com/documentation/uikit/uitextcontenttype).
  As of iOS 14.2 this hint does not trigger autofill.
* web: ["address-line2"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects the third line of a street address.
  streetAddressLine3(
    'streetAddressLine3',
    'Street Address Line 3',
    'The input field expects the third line of a street address.',
    '''
This hint will be translated to the below values on different platforms:

* web: ["address-line3"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a sublocality.
  sublocality(
    'sublocality',
    'Sublocality',
    'The input field expects a sublocality.',
    '''
This hint will be translated to the below values on different platforms:

* iOS: [sublocality](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a telephone number.
  telephoneNumber(
    'telephoneNumber',
    'Telephone Number',
    'The input field expects a telephone number.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_PHONE_NUMBER](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_PHONE_NUMBER).
* iOS: [telephoneNumber](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["tel"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a phone number's area code, with a country
  /// -internal prefix applied if applicable.
  telephoneNumberAreaCode(
    'telephoneNumberAreaCode',
    'Telephone Number Area Code',
    "The input field expects a phone number's area code, with a country-internal prefix applied if applicable.",
    '''
This hint will be translated to the below values on different platforms:

* web: ["tel-area-code"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a phone number's country code.
  telephoneNumberCountryCode(
    'telephoneNumberCountryCode',
    'Telephone Number Country Code',
    "The input field expects a phone number's country code.",
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_PHONE_COUNTRY_CODE](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_PHONE_COUNTRY_CODE).
* web: ["tel-country-code"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects the current device's phone number, usually for
  /// Sign Up / OTP flows.
  telephoneNumberDevice(
    'telephoneNumberDevice',
    'Telephone Number Device',
    "The input field expects the current device's phone number, usually for Sign Up / OTP flows.",
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_PHONE_NUMBER_DEVICE](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_PHONE_NUMBER_DEVICE).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a phone number's internal extension code.
  telephoneNumberExtension(
    'telephoneNumberExtension',
    'Telephone Number Extension',
    "The input field expects a phone number's internal extension code.",
    '''
This hint will be translated to the below values on different platforms:

* web: ["tel-extension"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a phone number without the country code and area
  /// code components.
  telephoneNumberLocal(
    'telephoneNumberLocal',
    'Telephone Number Local',
    'The input field expects a phone number without the country code and area code components.',
    '''
This hint will be translated to the below values on different platforms:

* web: ["tel-local"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects the first part of the component of the telephone
  /// number that follows the area code, when that component is split into two
  /// components.
  telephoneNumberLocalPrefix(
    'telephoneNumberLocalPrefix',
    'Telephone Number Local Prefix',
    'The input field expects the first part of the component of the telephone number that follows the area code, when that component is split into two components.',
    '''
This hint will be translated to the below values on different platforms:

* web: ["tel-local-prefix"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects the second part of the component of the telephone
  /// number that follows the area code, when that component is split into two
  /// components.
  telephoneNumberLocalSuffix(
    'telephoneNumberLocalSuffix',
    'Telephone Number Local Suffix',
    'The input field expects the second part of the component of the telephone number that follows the area code, when that component is split into two components.',
    '''
This hint will be translated to the below values on different platforms:

* web: ["tel-local-suffix"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a phone number without country code.
  telephoneNumberNational(
    'telephoneNumberNational',
    'Telephone Number National',
    'The input field expects a phone number without country code.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_PHONE_NATIONAL](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_PHONE_NATIONAL).
* web: ["tel-national"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The amount that the user would like for the transaction (e.g. when
  /// entering a bid or sale price).
  transactionAmount(
    'transactionAmount',
    'Transaction Amount',
    'The amount that the user would like for the transaction (e.g. when entering a bid or sale price).',
    '''
This hint will be translated to the below values on different platforms:

* web: ["transaction-amount"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The currency that the user would prefer the transaction to use, in [ISO
  /// 4217 currency code](https://www.iso.org/iso-4217-currency-codes.html).
  transactionCurrency(
    'transactionCurrency',
    'Transaction Currency',
    'The currency that the user would prefer the transaction to use, in ISO 4217 currency code.',
    '''
This hint will be translated to the below values on different platforms:

* web: ["transaction-currency"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a URL.
  url(
    'url',
    'URL',
    'The input field expects a URL.',
    '''
This hint will be translated to the below values on different platforms:

* iOS: [URL](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["url"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  ),

  /// The input field expects a username or an account name.
  username(
    'username',
    'Username',
    'The input field expects a username or an account name.',
    '''
This hint will be translated to the below values on different platforms:

* Android: [AUTOFILL_HINT_USERNAME](https://developer.android.com/reference/androidx/autofill/HintConstants#AUTOFILL_HINT_USERNAME).
* iOS: [username](https://developer.apple.com/documentation/uikit/uitextcontenttype).
* web: ["username"](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#autofilling-form-controls:-the-autocomplete-attribute).
* Otherwise, the hint string will be used as-is.
    ''',
  );

  /// The value code of the auto fill hint.
  final String code;

  /// The user-friendly name of the auto fill hint.
  final String title;

  /// The user-friendly name of the auto fill hint.
  final String description;

  /// The description of the auto fill hint.
  final String translation;

  const TextInputAutofillHints(
      this.code, this.title, this.description, this.translation);
}
