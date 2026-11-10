// A v1 editor style sheet (`style_sheets/{projectId}`: `textStyles` of
// `{id, label, value: TextProp}`, `paintStyles` of `{id, label, value:
// PaintModel}`, `defaultTextStyleID`, `defaultColorStyleID`) as a v2
// `StyleSheet` (API v2 `src/publish/style_sheet.dart`): text styles as v2
// text styles, paints as v2 paints. Other keys (privacy, name, timestamps)
// stay.
import 'package:codelessly_api/codelessly_api.dart';

import 'migrate.dart';

Json migrateStyleSheet(Map<String, Object?> v1, {MigrationReport? report}) {
  final rep = report ?? MigrationReport();
  const consumed = {'textStyles', 'paintStyles', 'defaultTextStyleID', 'defaultColorStyleID'};
  final text = <Json>[];
  for (final s in (v1['textStyles'] as List?) ?? const []) {
    if (s is! Map) continue;
    try {
      final prop = TextProp.fromJson(Map<String, dynamic>.from(s['value'] as Map));
      text.add({'id': '${s['id']}', 'name': '${s['label'] ?? ''}', 'style': V1Node.textStyle(prop)});
    } catch (error) {
      rep.undecodable['text style ${s['id']}'] = '$error';
    }
  }
  final colors = <Json>[];
  for (final s in (v1['paintStyles'] as List?) ?? const []) {
    if (s is! Map) continue;
    try {
      final paint = V1Node.paint(PaintModel.fromJson(Map<String, dynamic>.from(s['value'] as Map)));
      if (paint == null) throw StateError('no v2 paint');
      colors.add({'id': '${s['id']}', 'name': '${s['label'] ?? ''}', 'paint': paint});
    } catch (error) {
      rep.undecodable['color style ${s['id']}'] = '$error';
    }
  }
  return {
    for (final e in v1.entries)
      if (!consumed.contains(e.key)) e.key: e.value,
    'schema': 2,
    'textStyles': text,
    'colorStyles': colors,
    if (v1['defaultTextStyleID'] case final String id when id.isNotEmpty) 'defaultTextStyle': id,
    if (v1['defaultColorStyleID'] case final String id when id.isNotEmpty) 'defaultColorStyle': id,
  };
}
