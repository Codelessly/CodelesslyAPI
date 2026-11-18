// What the notation says of a document that is not a node (docs/design/22
// section 4.5, the document family): a component parameter's type in words,
// and a variable's, both ways. Read by the parser (notation.dart) and the
// printer's walk (print.dart).
import 'dart:convert';

import '../json.dart';

/// The JSON of a component parameter's (or an event payload's) type word:
/// Flutter's names (`String`, `bool`, `double`, `int`, `List<String>`,
/// `ValueNotifier<double>` for a variable parameter), or an enum's values
/// joined by `|` (`small|medium|large`). Null for no such word.
///
/// A type no name says (`int` held as a number, a record's fields, a
/// `dynamic` item) is its JSON: `param count:{"kind":"number","flutter":"int"}=0`.
Json? notationTypeJson(String word) {
  if (word.startsWith('{')) {
    try {
      final j = jsonDecode(word);
      return j is Map ? j.cast<String, Object?>() : null;
    } on FormatException {
      return null;
    }
  }
  // A bare `List` (round 10, R20: `param items:List=[]`) is a list of anything.
  if (word == 'List' || word == 'List<Object?>') return notationTypeJson('List<dynamic>');
  final list = RegExp(r'^List<(.+)>$').firstMatch(word);
  if (list != null) {
    final item = notationTypeJson(list[1]!);
    return item == null ? null : {'kind': 'list', 'flutter': word, 'item': item};
  }
  final variable = RegExp(r'^ValueNotifier<(.+)>$').firstMatch(word);
  if (variable != null) {
    final of = notationTypeJson(variable[1]!);
    return of == null ? null : {'kind': 'variable', 'of': of};
  }
  if (word.contains('|')) {
    final values = word.split('|');
    return values.length < 2 || values.any((v) => !_enumValue.hasMatch(v)) ? null : {'kind': 'enumeration', 'flutter': 'String', 'values': values};
  }
  return switch (word) {
    'String' => {'kind': 'string', 'flutter': 'String'},
    'bool' => {'kind': 'boolean', 'flutter': 'bool'},
    'double' => {'kind': 'number', 'flutter': 'double'},
    'int' => {'kind': 'integer', 'flutter': 'int'},
    // A record or anything (`List<Map>` of records, a `Map` of options):
    // free-form JSON, as Flutter's `dynamic` and `Map<String, dynamic>`.
    'dynamic' || 'Object' || 'Object?' || 'Map' || 'Map<String, dynamic>' || 'Map<String,dynamic>' || 'Map<String, Object?>' => {'kind': 'json', 'flutter': word},
    _ => null,
  };
}

final _enumValue = RegExp(r'^[A-Za-z0-9_.\-]+$');

/// The word for [type] ([notationTypeJson] of it gives it back exactly):
/// Flutter's name, else its JSON. Null for no type.
String? notationTypeWord(Json? type) {
  if (type == null) return null;
  return _typeName(type) ?? jsonEncode(type);
}

String? _typeName(Json type) {
  final word = switch (type['kind']) {
    'string' => 'String',
    'boolean' => 'bool',
    'number' => 'double',
    'integer' => 'int',
    'list' => switch (_typeName(readMap(type['item']) ?? const {})) { final String w => 'List<$w>', _ => null },
    'variable' => switch (_typeName(readMap(type['of']) ?? const {})) { final String w => 'ValueNotifier<$w>', _ => null },
    'enumeration' => readStrings(type['values']).join('|'),
    'json' => readString(type['flutter']) ?? 'dynamic',
    _ => null,
  };
  if (word == null) return null;
  final json = notationTypeJson(word);
  return json != null && jsonEncode(json) == jsonEncode(type) ? word : null;
}

/// The type word of a parameter whose default is [value] and whose type
/// is not written: what the value is (`"a"` String, `true` bool, a number
/// double, a list of strings, or an empty one, `List<String>`, of numbers
/// `List<double>`); String with no default.
String notationTypeOf(Object? value) => switch (value) {
      bool _ => 'bool',
      num _ => 'double',
      final List l when l.every((e) => e is String) => 'List<String>',
      final List l when l.every((e) => e is num) => 'List<double>',
      // A list of records (or of mixed values), a record: JSON.
      List _ => 'List<dynamic>',
      Map _ => 'Map',
      _ => 'String',
    };

/// The type a variable written with [value] and no type has
/// (`VariableType.of`'s names): what `state name=value` declares.
String notationVariableTypeOf(Object? value) => switch (value) {
      bool _ => 'boolean',
      int _ => 'integer',
      num _ => 'decimal',
      List _ => 'list',
      Map _ => 'map',
      _ => 'text',
    };
