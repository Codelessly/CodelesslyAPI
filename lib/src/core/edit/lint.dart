// What a finished agent-written UI gets wrong that no declaration catches,
// read from the document alone: a tappable box that shows nothing (a button
// without a label), text drawn in its background's colour. Warnings in the
// edit layer's diagnostic shape, so a host returns them in the same tool
// result as validation and the model fixes them on its retry. A renderer
// adds what only layout and fonts can tell ([EditCodes.missingGlyph],
// [EditCodes.noSize]).
import 'dart:math' as math;

import '../document.dart';
import '../json.dart';
import 'diagnostics.dart';

/// Lints [document] (or only the nodes [ids]): `empty_button` and
/// `low_contrast` warnings.
List<EditDiagnostic> uiLints(LayoutDocument document, {Iterable<String>? ids}) {
  final out = <EditDiagnostic>[];
  for (final id in ids ?? document.nodes.keys) {
    final n = document[id];
    if (n == null) continue;
    final json = n.toJson();
    final type = n.type;
    final at = editPointer('/nodes', id);
    // A tap target with nothing in it.
    if (_tappable(json) && n.childIds.isEmpty && const {'box', 'row', 'column', 'stack', 'wrap'}.contains(type)) {
      final label = '{"op": "set", "id": "${id}Label", "parent": "$id", "node": {"type": "text", "layout": {"width": {"hug": 120}, '
          '"height": {"hug": 20}}, "props": {"text": "...", "style": {"fontSize": 15, "fontWeight": 600, "color": "#FFFFFFFF"}}}}';
      out.add(EditDiagnostic.of(EditCodes.emptyButton, -1,
          '"$id" reacts to a tap but shows nothing: a $type with no children has no label. ${type == 'box' ? 'A box takes no children: set "$id" again as a row (same layout, decoration and actions, '
              '"props": {"mainAxisAlignment": "center", "crossAxisAlignment": "center"}), then add its label: ' : 'Add its label: '}'
          '$label. Or use a filledButton with "label".',
          path: at, nodeId: id));
    }
    // Text in the colour of what is behind it.
    if (type == 'text') {
      final bind = readMap(json['bind']) ?? const {};
      if (bind.keys.any((k) => k == 'props.style.color' || k == 'props.style' || k == 'props.text.color')) continue;
      final style = readMap(readMap(json['props'])?['style']);
      final color = _color(style?['color']);
      final bg = _background(document, id);
      if (bg == null) continue;
      final fg = color ?? 0xFF000000;
      final ratio = _contrast(fg, bg.$2);
      if (ratio < 1.6) {
        out.add(EditDiagnostic.of(EditCodes.lowContrast, -1,
            '${color == null ? '"$id" has no text colour: it draws in the default (near black)' : '"$id" is drawn in ${_hex(fg)}'} over '
            '${_hex(bg.$2)} (the fill of "${bg.$1}"): contrast ${ratio.toStringAsFixed(2)}:1, it is not readable. Set "props": {"style": '
            '{"color": "${_hex(_luminance(bg.$2) > 0.4 ? 0xFF111827 : 0xFFFFFFFF)}"}}.',
            path: editPointer(editPointer(editPointer(at, 'props'), 'style'), 'color'), nodeId: id));
      }
    }
  }
  return out;
}

bool _tappable(Json node) {
  for (final r in readList(node['actions']) ?? const []) {
    final t = readString(readMap(readMap(r)?['trigger'])?['type']);
    if (t == 'click' || t == 'tap' || t == 'press' || t == 'longPress' || t == 'doubleClick') return true;
  }
  return false;
}

/// The nearest ancestor (or [id] itself) with an opaque solid fill: its id
/// and colour.
(String, int)? _background(LayoutDocument document, String id) {
  String? x = id;
  final seen = <String>{};
  while (x != null && seen.add(x)) {
    final n = document[x];
    if (n == null) return null;
    final json = n.toJson();
    // A fill that a binding changes: unknown.
    if ((readMap(json['bind']) ?? const {}).keys.any((k) => k.startsWith('decoration.fills'))) return null;
    for (final f in (readList(readMap(json['decoration'])?['fills']) ?? const []).reversed) {
      final m = readMap(f);
      if (m == null) continue;
      if (m['type'] != null && m['type'] != 'solid') return null;
      final c = _color(m['color']);
      if (c != null && (c >>> 24) >= 0xC0) return (x, c);
    }
    x = document.parentOf(x);
  }
  return null;
}

int? _color(Object? v) {
  if (v is! String) return null;
  var h = v.trim();
  if (!h.startsWith('#')) return null;
  h = h.substring(1);
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return null;
  return int.tryParse(h, radix: 16);
}

String _hex(int c) => '#${c.toRadixString(16).padLeft(8, '0').toUpperCase()}';

double _luminance(int c) {
  double ch(int v) {
    final s = v / 255;
    return s <= 0.03928 ? s / 12.92 : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * ch((c >> 16) & 0xFF) + 0.7152 * ch((c >> 8) & 0xFF) + 0.0722 * ch(c & 0xFF);
}

double _contrast(int a, int b) {
  final la = _luminance(a), lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}
