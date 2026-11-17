// A node's line in the notation, for printNotation (print.dart): the words
// for its type, text, props, layout, decoration and bindings.
import 'dart:convert';

import '../catalog.dart';
import '../json.dart';
import 'notation.dart';
import 'print_events.dart';
import 'print_media.dart';
import 'print_paint.dart';

/// What a line is printed with: the whole document (a node's parent, its
/// variables), the catalog its types come from and the options the print is
/// parsed back with.
final class PrintContext {
  const PrintContext({required this.document, required this.catalog, required this.options});

  final Json document;
  final Catalog catalog;
  final NotationOptions options;

  Json get nodes => readMap(document['nodes']) ?? const {};
}

const _words = {
  'text': 'Text',
  'column': 'Column',
  'row': 'Row',
  'textField': 'Input',
  'switch': 'Toggle',
  'dropdown': 'Select',
  'filledButton': 'Button',
  'outlinedButton': 'Button.outline',
  'textButton': 'Button.ghost',
  'slider': 'Slider',
  'checkbox': 'Checkbox',
  'icon': 'Icon',
  'divider': 'Divider',
};

/// The line of node [id] in the notation's words: its type, id, main string
/// and every field the words can say, then what its events, media rules and
/// paint say ([printEvents], [printMedia], [printPaint]). What the words leave
/// unsaid or say wrongly, [printNotation] finds by parsing the line back and
/// adds as the line's `{…}` tail, so a word written here never has to be
/// exact to be safe: it has to be right to be counted.
String printNodeLine(String id, Json n, PrintContext context) {
  final type = '${n['type']}';
  final props = readMap(n['props']) ?? const {};
  final layout = readMap(n['layout']) ?? const {};
  final decoration = readMap(n['decoration']) ?? const {};
  var word = _words[type] ?? type;
  // A text in one of the named looks is that variant.
  if (type == 'text' && props['style'] is Map) {
    for (final v in defaultTextVariants.entries) {
      if (v.key != 'body' && jsonEncode(v.value) == jsonEncode(props['style'])) word = 'Text.${v.key}';
    }
  }
  final b = StringBuffer(word)..write('#$id');
  // The main string, when it reads back as written: plain text with no
  // braces, quotes or dollars to mistake.
  final main = switch (type) {
    'text' => props['text'],
    'filledButton' || 'outlinedButton' || 'textButton' || 'checkbox' || 'switch' => props['label'],
    'icon' => props['icon'],
    'textField' => readMap(props['decoration'])?['labelText'],
    _ => null,
  };
  if (main is String && main.isNotEmpty && !RegExp(r'[{}$\\"]').hasMatch(main) && !main.contains('\n')) b.write(' ${jsonEncode(main)}');
  if ((type == 'row' || type == 'column') && props['spacing'] is num) b.write(' gap=${props['spacing']}');
  if (type == 'row' || type == 'column') {
    const main = {'center': 'center', 'end': 'end', 'spaceBetween': 'between'};
    if (main[props['mainAxisAlignment']] case final String w) b.write(' $w');
  }
  if (layout['padding'] is num) b.write(' pad=${layout['padding']}');
  final fills = decoration['fills'];
  if (fills is List && fills.length == 1 && fills.single is Map && (fills.single as Map).length == 1 && (fills.single as Map)['color'] is String) {
    b.write(' fill=${(fills.single as Map)['color']}');
  }
  final strokes = decoration['strokes'];
  if (strokes is List && strokes.length == 1 && strokes.single is Map && (strokes.single as Map).length == 1 && (strokes.single as Map)['color'] is String) {
    b.write(' border=${(strokes.single as Map)['color']}');
  }
  if (decoration['radius'] is num) b.write(' radius=${decoration['radius']}');
  if (layout['width'] is num) b.write(' w=${layout['width']}');
  if (layout['height'] is num) b.write(' h=${layout['height']}');
  for (final words in [printEvents(id, n, context), printMedia(id, n, context), printPaint(id, n, context)]) {
    for (final w in words) {
      b.write(' $w');
    }
  }
  return b.toString();
}

