// A renderer-only program: it imports the core of the model and nothing
// else, so it compiles no feature library (test/library_boundaries_test.dart
// checks the import closure). A document's feature types decode whole and
// round-trip; code that wants them passes a bigger catalog.
import 'package:codelessly_api/core.dart';

void main() {
  final doc = LayoutDocument.fromJson({
    'roots': ['c'],
    'nodes': {
      'c': {'type': 'canvas', 'children': ['t', 'v'], 'layout': {}},
      't': {'type': 'text', 'layout': {}, 'props': {'text': 'Hello'}},
      'v': {'type': 'video', 'layout': {}, 'props': {'url': 'https://example.com/a.mp4'}},
    },
  }, catalog: Catalog.core);
  print(doc['t']!.prop(TextProps.text)); // Hello
  print(doc['v']!.spec); // null: video is the media library's
  print(doc.toJson()['nodes']);
}
