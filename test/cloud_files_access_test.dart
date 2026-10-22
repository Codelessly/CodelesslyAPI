import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('new uploads are private; saved actions without access stay public', () {
    expect(CloudFilesAction().access, CloudFileAccess.private);
    expect(CloudFilesAction().toJson()['access'], 'private');
    final Map legacy = CloudFilesAction().toJson()..remove('access');
    expect(CloudFilesAction.fromJson(legacy).access, CloudFileAccess.public);
    final CloudFilesAction public = CloudFilesAction(
      access: CloudFileAccess.public,
    );
    expect(public.toJson().containsKey('access'), isFalse);
    expect(
      CloudFilesAction.fromJson(public.toJson()).access,
      CloudFileAccess.public,
    );
  });
}
