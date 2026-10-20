// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_action.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$AuthActionOmitDefaults(
  AuthAction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.operation, AuthOperation.signIn))
    json.remove('operation');
  if (isJsonDefault(instance.email, '')) json.remove('email');
  if (isJsonDefault(instance.password, '')) json.remove('password');
  if (isJsonDefault(instance.displayName, '')) json.remove('displayName');
  if (isJsonDefault(instance.nonBlocking, false)) json.remove('nonBlocking');
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthAction _$AuthActionFromJson(Map json) => AuthAction(
  operation:
      $enumDecodeNullable(_$AuthOperationEnumMap, json['operation']) ??
      AuthOperation.signIn,
  email: json['email'] as String? ?? '',
  password: json['password'] as String? ?? '',
  displayName: json['displayName'] as String? ?? '',
  errorVariable: json['errorVariable'] == null
      ? null
      : VariableData.fromJson(
          Map<String, dynamic>.from(json['errorVariable'] as Map),
        ),
  nonBlocking: json['nonBlocking'] as bool? ?? false,
  enabled: json['enabled'] as bool? ?? true,
)..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$AuthActionToJson(AuthAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nonBlocking': instance.nonBlocking,
      'enabled': instance.enabled,
      'operation': _$AuthOperationEnumMap[instance.operation]!,
      'email': instance.email,
      'password': instance.password,
      'displayName': instance.displayName,
      'errorVariable': ?instance.errorVariable?.toJson(),
    };

const _$AuthOperationEnumMap = {
  AuthOperation.signIn: 'signIn',
  AuthOperation.signUp: 'signUp',
  AuthOperation.signOut: 'signOut',
  AuthOperation.updateProfile: 'updateProfile',
  AuthOperation.sendPasswordResetEmail: 'sendPasswordResetEmail',
};

const _$ActionTypeEnumMap = {
  ActionType.navigation: 'navigation',
  ActionType.showDialog: 'showDialog',
  ActionType.link: 'link',
  ActionType.submit: 'submit',
  ActionType.setValue: 'setValue',
  ActionType.setVariant: 'setVariant',
  ActionType.setVariable: 'setVariable',
  ActionType.callFunction: 'callFunction',
  ActionType.callApi: 'callApi',
  ActionType.setStorage: 'setStorage',
  ActionType.setCloudStorage: 'setCloudStorage',
  ActionType.loadFromCloudStorage: 'loadFromCloudStorage',
  ActionType.auth: 'auth',
  ActionType.conditional: 'conditional',
  ActionType.forEach: 'forEach',
  ActionType.cloudFiles: 'cloudFiles',
  ActionType.showToast: 'showToast',
  ActionType.confirm: 'confirm',
};
