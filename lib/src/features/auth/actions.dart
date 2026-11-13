// The auth library's action types: sign-in. One immutable
// class per type, decoded through its ActionSpec ([authActionSpecs]); the
// SDK's auth feature runs them.

import 'action_fields.dart';
import '../../core/actions.dart';
import '../../core/catalog.dart';
import '../../core/json.dart';

/// The fields every action has.
typedef _Common = ActionCommon;

// Reading an action's fields: the core's rules (core/actions.dart).
String _s(Json m, String k, [String def = '']) => switch (m[k]) {
  final String s => s,
  final num n => '$n',
  final bool b => '$b',
  _ => def,
};
T _e<T extends Enum>(List<T> values, Json m, String k, T def) => readEnum(values, m[k], def);

/// What an [AuthAction] does.
enum AuthOperation {
  signIn,
  signUp,
  signOut,
  updateProfile,
  sendPasswordResetEmail,
  sendEmailVerification,
  updatePassword, //
  deleteAccount,
  signInWithGoogle,
  signInWithApple,
  sendSignInLink,
  completeSignInLink,
  updatePhoto,

  /// Starts a guest session: an anonymous account that has a uid (so it can
  /// keep `users/{uid}` data) but no email. `${auth.isGuest}` is true and
  /// `${auth.isSignedIn}` false. A [signUp] while a guest turns the guest
  /// into a real account with the same uid, so its data carries over;
  /// [signOut] ends the session and [deleteAccount] deletes it.
  signInAnonymously,
}

/// Signs app users in, up and out, and manages their account. A failure's
/// message goes in [errorVariable] (and stops the chain).
final class AuthAction extends ActionDef {
  const AuthAction({
    this.operation = AuthOperation.signIn,
    this.email = '',
    this.password = '',
    this.displayName = '',
    this.photoUrl = '',
    this.currentPassword = '',
    this.errorVariable = '',
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'auth';
  @override
  String get type => typeName;

  final AuthOperation operation;
  final String email, password, displayName, photoUrl;

  /// For [AuthOperation.updatePassword] and [AuthOperation.deleteAccount]:
  /// the signed-in user's current password, which re-authenticates them
  /// first (Firebase asks for a recent sign-in before these). Empty: no
  /// re-authentication.
  final String currentPassword;
  final String errorVariable;

  static AuthAction _fromJson(Json m, _Common c) => AuthAction(
    operation: _e(AuthOperation.values, m, 'operation', AuthOperation.signIn),
    email: _s(m, 'email'),
    password: _s(m, 'password'),
    displayName: _s(m, 'displayName'),
    photoUrl: _s(m, 'photoUrl'),
    currentPassword: _s(m, 'currentPassword'),
    errorVariable: _s(m, 'errorVariable'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get fieldsJson => {
    'operation': operation.name,
    if (email.isNotEmpty) 'email': email,
    if (password.isNotEmpty) 'password': password,
    if (displayName.isNotEmpty) 'displayName': displayName,
    if (photoUrl.isNotEmpty) 'photoUrl': photoUrl,
    if (currentPassword.isNotEmpty) 'currentPassword': currentPassword,
    if (errorVariable.isNotEmpty) 'errorVariable': errorVariable,
  };
}

/// The auth library's action type ([AuthAction]).
const List<ActionSpec> authActionSpecs = [
  ActionSpec(AuthAction.typeName, label: 'Auth', fields: AuthFields.all, decode: AuthAction._fromJson, requires: ['auth']),
];
