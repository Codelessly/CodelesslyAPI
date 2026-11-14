// What a finished agent-written UI gets wrong that no declaration catches,
// read from the document alone: a tappable box that shows nothing (a button
// without a label), text drawn in its background's color. Warnings in the
// edit layer's diagnostic shape, so a host returns them in the same tool
// result as validation and the model fixes them on its retry. A renderer
// adds what only layout and fonts can tell ([EditCodes.missingGlyph],
// [EditCodes.noSize]).
import 'dart:math' as math;

import '../document.dart';
import '../json.dart';
import 'diagnostics.dart';

/// Whether the font a text is drawn with ([family]: its `fontFamily`, null
/// for the default) has a glyph for [codepoint].
typedef GlyphCoverage = bool Function(String? family, int codepoint);

/// Icon names for symbols models write as text.
const Map<int, String> symbolIcons = {
  0x2192: 'arrow_forward', 0x2190: 'arrow_back', 0x2191: 'arrow_upward', 0x2193: 'arrow_downward', 0x2194: 'swap_horiz', //
  0x21C4: 'swap_horiz', 0x2713: 'check', 0x2714: 'check', 0x2715: 'close', 0x2717: 'close', 0x2605: 'star', 0x2606: 'star_border',
  0x2708: 'flight', 0x2600: 'wb_sunny', 0x2601: 'cloud', 0x2602: 'umbrella', 0x26A0: 'warning', 0x2139: 'info',
};

/// Lints [document] (or only the nodes [ids]): `empty_button`,
/// `dead_control` and `low_contrast` warnings, and with [hasGlyph],
/// `missing_glyph`.
List<EditDiagnostic> uiLints(LayoutDocument document, {Iterable<String>? ids, GlyphCoverage? hasGlyph}) {
  final out = <EditDiagnostic>[];
  for (final id in ids ?? document.nodes.keys) {
    final n = document[id];
    if (n == null) continue;
    final json = n.toJson();
    final type = n.type;
    final at = editPointer('/nodes', id);
    // Characters the font cannot draw.
    if (hasGlyph != null && type == 'text') {
      final props = readMap(json['props']);
      final text = readString(props?['text']) ?? '';
      final family = readString(readMap(props?['style'])?['fontFamily']);
      final missing = <int>{
        for (final r in text.runes)
          if (r > 0x7E && r != 0xA0 && !(r >= 0x2000 && r <= 0x200F) && !hasGlyph(family, r)) r,
      };
      if (missing.isNotEmpty) {
        final chars = missing.map((r) => '"${String.fromCharCode(r)}" (U+${r.toRadixString(16).toUpperCase().padLeft(4, '0')})').join(', ');
        final icons = {for (final r in missing) if (symbolIcons[r] case final String i) String.fromCharCode(r): i};
        out.add(EditDiagnostic.of(EditCodes.missingGlyph, -1,
            '"$id" has characters the font cannot draw: $chars; they show as empty boxes. Use an icon node instead '
            '(a row of text, icon, text)${icons.isEmpty ? '' : ': ${[for (final e in icons.entries) '${e.key} is {"type": "icon", "props": {"icon": "${e.value}"}}'].join('; ')}'}, '
            'or write it in words.',
            path: editPointer(editPointer(at, 'props'), 'text'), nodeId: id));
      }
    }
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
    // A button that does nothing: no reaction, not disabled (a mock-up's
    // Start and Pause, plan_progress@claude-haiku-5-5).
    // A component counts when it is a button by name and fires a press (a
    // list row or chip may be shown only, with no reaction).
    final pressEvent = type.endsWith('Button') ? n.spec?.events.where((e) => e.key == 'onPressed').firstOrNull?.key : null;
    if ((_buttons.contains(type) || pressEvent != null) &&
        (readList(json['actions']) ?? const []).isEmpty &&
        readMap(json['props'])?['enabled'] != false &&
        !(readMap(json['bind'])?.containsKey('props.enabled') ?? false) &&
        !_insideTappable(document, id)) {
      final trigger = pressEvent == null ? '{"type": "click"}' : '{"type": "event", "event": "$pressEvent"}';
      out.add(EditDiagnostic.of(EditCodes.deadControl, -1,
          '"$id" ($type) does nothing when pressed: it has no reaction. Give it what it does: "actions": [{"trigger": $trigger, '
          '"actions": [{"type": "setVariable", ...}]}] (a variable the UI reads: a step, a running flag), or "enabled": false '
          'while it should not be pressed.',
          path: editPointer(at, 'actions'), nodeId: id));
    }
    // Text in the color of what is behind it.
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
            '${color == null ? '"$id" has no text color: it draws in the default (near black)' : '"$id" is drawn in ${_hex(fg)}'} over '
            '${_hex(bg.$2)} (the fill of "${bg.$1}"): contrast ${ratio.toStringAsFixed(2)}:1, it is not readable. Set "props": {"style": '
            '{"color": "${_hex(_luminance(bg.$2) > 0.4 ? 0xFF111827 : 0xFFFFFFFF)}"}}.',
            path: editPointer(editPointer(editPointer(at, 'props'), 'style'), 'color'), nodeId: id));
      }
    }
  }
  return out;
}

/// The core's buttons: a press is what they are for.
const _buttons = {'filledButton', 'textButton', 'outlinedButton', 'elevatedButton', 'iconButton', 'filledTonalButton'};

/// Whether an ancestor of [id] reacts to a tap (the button is its label).
bool _insideTappable(LayoutDocument document, String id) {
  for (var p = document.parentOf(id); p != null; p = document.parentOf(p)) {
    final n = document[p];
    if (n != null && _tappable(n.toJson())) return true;
  }
  return false;
}

bool _tappable(Json node) {
  for (final r in readList(node['actions']) ?? const []) {
    final t = readString(readMap(readMap(r)?['trigger'])?['type']);
    if (t == 'click' || t == 'tap' || t == 'press' || t == 'longPress' || t == 'doubleClick') return true;
  }
  return false;
}

/// The nearest ancestor (or [id] itself) with an opaque solid fill: its id
/// and color.
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

/// The codepoints a TrueType or OpenType font file maps (its `cmap` table,
/// formats 4 and 12): what [GlyphCoverage] needs for a font a host loads.
/// Empty when the file cannot be read.
Set<int> fontCodepoints(List<int> bytes) {
  final out = <int>{};
  int u16(int o) => o + 1 < bytes.length ? (bytes[o] << 8) | bytes[o + 1] : 0;
  int u32(int o) => (u16(o) << 16) | u16(o + 2);
  try {
    final tables = u16(4);
    var cmap = -1;
    for (var i = 0; i < tables; i++) {
      final rec = 12 + i * 16;
      if (String.fromCharCodes(bytes.sublist(rec, rec + 4)) == 'cmap') cmap = u32(rec + 8);
    }
    if (cmap < 0) return out;
    final count = u16(cmap + 2);
    for (var i = 0; i < count; i++) {
      final platform = u16(cmap + 4 + i * 8), encoding = u16(cmap + 6 + i * 8);
      if (!(platform == 0 || (platform == 3 && (encoding == 1 || encoding == 10)))) continue;
      final sub = cmap + u32(cmap + 8 + i * 8);
      final format = u16(sub);
      if (format == 4) {
        final segs = u16(sub + 6) ~/ 2;
        final ends = sub + 14, starts = ends + segs * 2 + 2, deltas = starts + segs * 2, offsets = deltas + segs * 2;
        for (var s = 0; s < segs; s++) {
          final end = u16(ends + s * 2), start = u16(starts + s * 2), delta = u16(deltas + s * 2), ro = u16(offsets + s * 2);
          for (var c = start; c <= end && c != 0xFFFF; c++) {
            final glyph = ro == 0 ? (c + delta) & 0xFFFF : u16(offsets + s * 2 + ro + (c - start) * 2);
            if (glyph != 0) out.add(c);
          }
        }
      } else if (format == 12) {
        final groups = u32(sub + 12);
        for (var g = 0; g < groups; g++) {
          final start = u32(sub + 16 + g * 12), end = u32(sub + 20 + g * 12);
          if (end - start > 0x20000) continue;
          for (var c = start; c <= end; c++) {
            out.add(c);
          }
        }
      }
    }
  } catch (_) {
    return out;
  }
  return out;
}
