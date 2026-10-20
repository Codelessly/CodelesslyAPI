import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'auth_action.g.dart';

/// What an [AuthAction] does to the app's signed-in user.
enum AuthOperation {
  /// Signs in with [AuthAction.email] and [AuthAction.password].
  signIn,

  /// Creates an account with [AuthAction.email] and [AuthAction.password],
  /// and sets its display name to [AuthAction.displayName] when given.
  signUp,

  /// Signs the user out.
  signOut,

  /// Sets the signed-in user's display name to [AuthAction.displayName].
  updateProfile,

  /// Sends a password reset email to [AuthAction.email].
  sendPasswordResetEmail,

  /// Sends the signed-in user an email to verify their address. Whether it
  /// is verified is `${auth.emailVerified}`.
  sendEmailVerification,

  /// Sets the signed-in user's password to [AuthAction.password].
  updatePassword,

  /// Deletes the signed-in user's account and signs them out.
  deleteAccount;

  /// A readable name for this operation.
  String get label => switch (this) {
    signIn => 'Sign In',
    signUp => 'Sign Up',
    signOut => 'Sign Out',
    updateProfile => 'Update Profile',
    sendPasswordResetEmail => 'Send Password Reset Email',
    sendEmailVerification => 'Send Verification Email',
    updatePassword => 'Change Password',
    deleteAccount => 'Delete Account',
  };
}

/// Signs app users in and out with email and password.
///
/// The signed-in user is available to layouts as the `auth` variable:
/// `${auth.uid}`, `${auth.email}`, `${auth.displayName}` and
/// `${auth.isSignedIn}`.
///
/// [email], [password] and [displayName] may contain variable paths, e.g.
/// `${email}`. When the operation fails, the action fails, which stops the
/// actions after it, and a readable message is written to [errorVariable]
/// when one is set. On success [errorVariable] is cleared.
@JsonSerializable()
class AuthAction extends ActionModel with Equatable, SerializableMixin {
  /// What to do.
  final AuthOperation operation;

  /// The email address, for [AuthOperation.signIn], [AuthOperation.signUp]
  /// and [AuthOperation.sendPasswordResetEmail].
  final String email;

  /// The password, for [AuthOperation.signIn] and [AuthOperation.signUp],
  /// or the new password for [AuthOperation.updatePassword].
  final String password;

  /// The display name, for [AuthOperation.signUp] and
  /// [AuthOperation.updateProfile].
  final String displayName;

  /// A text variable that receives the error message when the operation
  /// fails, and is cleared when it succeeds.
  final VariableData? errorVariable;

  /// Creates an [AuthAction].
  AuthAction({
    this.operation = AuthOperation.signIn,
    this.email = '',
    this.password = '',
    this.displayName = '',
    this.errorVariable,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.auth);

  /// Duplicates this action with the given values replaced.
  AuthAction copyWith({
    AuthOperation? operation,
    String? email,
    String? password,
    String? displayName,
    VariableData? errorVariable,
  }) => AuthAction(
    operation: operation ?? this.operation,
    email: email ?? this.email,
    password: password ?? this.password,
    displayName: displayName ?? this.displayName,
    errorVariable: errorVariable ?? this.errorVariable,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [
    operation,
    email,
    password,
    displayName,
    errorVariable,
  ];

  /// Creates an instance from a JSON object.
  factory AuthAction.fromJson(Map json) => _$AuthActionFromJson(json);

  @override
  Map toJson() => _$AuthActionOmitDefaults(this, _$AuthActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitAuthAction(this);
}
