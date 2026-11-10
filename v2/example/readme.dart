// The sample of the README, runnable: dart run example/readme.dart
// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:codelessly_api_v2/codelessly_api.dart';

void main() {
  final document = LayoutDocument.fromJson({
    'schema': 2,
    'id': 'hello',
    'roots': ['home'],
    'nodes': {
      'home': {
        'type': 'canvas',
        'name': 'Home',
        'slots': {'body': 'column'},
        'layout': {'width': 390, 'height': 844},
      },
      'column': {
        'type': 'column',
        'children': ['title'],
        'layout': {'width': {'fill': 390}, 'height': {'fill': 844}, 'padding': 24},
        'props': {'spacing': 12, 'crossAxisAlignment': 'start'},
      },
      'title': {
        'type': 'text',
        'props': {'text': 'Hello!', 'style': {'fontSize': 24, 'fontWeight': 700}},
      },
    },
  });

  // Typed access, with Flutter's names and defaults.
  final column = document['column']!;
  print(column.prop(FlexProps.spacing)); // 12.0
  print(column.prop(FlexProps.mainAxisAlignment)); // MainAxisAlignment.start (Flutter's default)

  // Immutable: an edit is a copy. Value equality tells what changed.
  final edited = document['title']!.withProp(TextProps.text, 'Hello, world!');
  print(edited == document['title']); // false

  // Sparse JSON out: defaults aren't written.
  print(jsonEncode(edited.toJson()));
}
