import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('every node type can be deserialized', () {
    // Node classes declare `final String type = '...'`. Loading indicator
    // properties use the same pattern for their own 'material'/'cupertino'
    // discriminator.
    const propertyTypes = {'material', 'cupertino'};
    final pattern = RegExp(r"^  final String type = '(\w+)';", multiLine: true);
    final types = {
      for (final file in Directory('lib/src/api/nodes').listSync())
        if (file is File && !file.path.endsWith('.g.dart'))
          for (final match in pattern.allMatches(file.readAsStringSync()))
            match.group(1)!,
    }.difference(propertyTypes);

    expect(types, isNotEmpty);
    expect(
      types.where((type) => !NodeJsonConverter.isNodeRegistered(type)),
      isEmpty,
    );
  });
}
