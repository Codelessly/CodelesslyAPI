import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('social and link sign-in, and photo updates, round-trip', () {
    for (final AuthOperation operation in AuthOperation.values) {
      final AuthAction action = AuthAction(
        operation: operation,
        email: r'${email}',
        photoUrl: r'${result.url}',
      );
      expect(ActionModel.fromJson(action.toJson()), action);
    }
    expect(AuthAction().toJson().containsKey('photoUrl'), isFalse);
  });

  test('operations that sign in', () {
    expect(AuthOperation.signInWithGoogle.signsIn, isTrue);
    expect(AuthOperation.completeSignInLink.signsIn, isTrue);
    expect(AuthOperation.sendSignInLink.signsIn, isFalse);
    expect(AuthOperation.updatePhoto.label, 'Update Profile Photo');
  });
}
