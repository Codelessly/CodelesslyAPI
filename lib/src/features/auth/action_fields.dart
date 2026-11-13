// The auth library's action types as declared fields, for generated
// editors (see core/action_fields.dart).
import '../../core/props.dart';
import 'actions.dart';

/// [AuthAction].
abstract final class AuthFields {
  static const operation = PropDef<AuthOperation>('operation', EnumCodec(AuthOperation.values), AuthOperation.signIn);
  static const email = PropDef<String>('email', Codecs.string, '');
  static const password = PropDef<String>('password', Codecs.string, '');
  static const displayName = PropDef<String>('displayName', Codecs.string, '');
  static const photoUrl = PropDef<String>('photoUrl', Codecs.string, '');
  static const currentPassword = PropDef<String>('currentPassword', Codecs.string, '',
      doc: 'Re-authenticates first (change password, delete account).');
  static const errorVariable = PropDef<String>('errorVariable', Codecs.string, '', doc: 'Gets a failure\'s message.');
  static const List<PropDef<Object?>> all = [operation, email, password, displayName, photoUrl, currentPassword, errorVariable];
}
