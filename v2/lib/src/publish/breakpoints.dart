// A project's breakpoints: the screen size classes its screens, responsive
// layouts, `${screen}` and per-breakpoint values speak of (DESIGN.md §5.3).
import 'package:meta/meta.dart';

import '../document.dart';
import '../json.dart';
import '../props.dart';

/// One screen size class of a project: from [minWidth] (inclusive) up to the
/// next breakpoint's.
@immutable
final class Breakpoint {
  const Breakpoint({required this.id, this.name = '', this.minWidth = 0, this.width = 0, this.height = 0});

  /// Stable: screens' canvases and responsive variants refer to it by this.
  final String id;

  /// Shown in the editor and in `${screen.breakpointName}`.
  final String name;

  /// The narrowest width it covers, inclusive.
  final double minWidth;

  /// The design size a canvas for it takes (0: [minWidth], or 390 wide for a
  /// first breakpoint at 0; see [designWidth]).
  final double width, height;

  /// The name shown: [name], else [id].
  String get label => name.trim().isEmpty ? id : name.trim();

  /// [label] as a formula key: lower camel case, letters and digits only
  /// ("Large desktop" → `largeDesktop`).
  String get key => breakpointKey(label);

  /// The width a canvas designed for it takes.
  double get designWidth => width > 0 ? width : (minWidth > 0 ? minWidth : 390);

  /// The height a canvas designed for it takes.
  double get designHeight => height > 0 ? height : 900;

  static const idDef = PropDef<String>('id', Codecs.string, '', doc: 'Stable id.');
  static const nameDef = PropDef<String>('name', Codecs.string, '', doc: 'Name.');
  static const minWidthDef = PropDef<double>('minWidth', Codecs.positive, 0, doc: 'From this width (inclusive).');
  static const widthDef = PropDef<double>('width', Codecs.positive, 0, doc: 'Design width of its canvases.');
  static const heightDef = PropDef<double>('height', Codecs.positive, 0, doc: 'Design height of its canvases.');

  /// The field declarations (a generated panel edits a breakpoint by them).
  static const spec = WidgetSpec('Breakpoint', props: [idDef, nameDef, minWidthDef, widthDef, heightDef]);

  static Breakpoint? fromJson(Object? json) {
    final m = readMap(json);
    final id = readString(m?['id'])?.trim();
    if (m == null || id == null || id.isEmpty) return null;
    double pos(Object? v) => (readDouble(v) ?? 0).clamp(0, double.infinity).toDouble();
    return Breakpoint(
      id: id,
      name: readString(m['name']) ?? '',
      minWidth: pos(m['minWidth']),
      width: pos(m['width']),
      height: pos(m['height']),
    );
  }

  Json toJson() {
    final j = <String, Object?>{'id': id};
    if (name.isNotEmpty) j['name'] = name;
    put(j, 'minWidth', writeDouble(minWidth), 0);
    put(j, 'width', writeDouble(width), 0);
    put(j, 'height', writeDouble(height), 0);
    return j;
  }

  Breakpoint copyWith({String? id, String? name, double? minWidth, double? width, double? height}) => Breakpoint(
        id: id ?? this.id,
        name: name ?? this.name,
        minWidth: minWidth ?? this.minWidth,
        width: width ?? this.width,
        height: height ?? this.height,
      );

  @override
  bool operator ==(Object other) =>
      other is Breakpoint &&
      other.id == id &&
      other.name == name &&
      other.minWidth == minWidth &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(id, name, minWidth, width, height);

  @override
  String toString() => 'Breakpoint($id "$name" ≥$minWidth)';
}

/// [label] as a formula key: lower camel case of its letters and digits
/// ("Large desktop" → `largeDesktop`, "XL" → `xl`). Empty for none.
String breakpointKey(String label) {
  final words = label.split(RegExp(r'[^A-Za-z0-9]+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return '';
  final out = StringBuffer();
  for (var i = 0; i < words.length; i++) {
    final w = words[i];
    if (i == 0) {
      // "XL" → "xl"; "iPad" stays "iPad"; "Mobile" → "mobile".
      out.write(w == w.toUpperCase() ? w.toLowerCase() : w[0].toLowerCase() + w.substring(1));
    } else {
      out.write(w[0].toUpperCase() + w.substring(1));
    }
  }
  return out.toString();
}

/// A project's breakpoints, narrowest first (DESIGN.md §5.3).
///
/// Always ordered by [Breakpoint.minWidth] with unique min widths and ids,
/// the first starting at 0 (it covers everything below the second): the
/// constructor normalizes whatever it's given. Never empty: no breakpoints
/// are [defaults].
@immutable
final class Breakpoints {
  Breakpoints._(this.list);

  /// [items] normalized: entries with an id another took are dropped, then
  /// sorted by min width (one per min width, the first given kept), the
  /// first starting at 0. Empty gives [defaults].
  factory Breakpoints(Iterable<Breakpoint> items) {
    final ids = <String>{};
    final unique = [
      for (final b in items)
        if (ids.add(b.id)) b,
    ];
    if (unique.isEmpty) return defaults;
    final sorted = [...unique];
    // A stable sort by min width (insertion sort keeps given order on ties).
    for (var i = 1; i < sorted.length; i++) {
      final b = sorted[i];
      var j = i - 1;
      while (j >= 0 && sorted[j].minWidth > b.minWidth) {
        sorted[j + 1] = sorted[j];
        j--;
      }
      sorted[j + 1] = b;
    }
    final out = <Breakpoint>[];
    for (final b in sorted) {
      if (out.isNotEmpty && out.last.minWidth == b.minWidth) continue;
      out.add(b);
    }
    if (out.first.minWidth != 0) out[0] = out.first.copyWith(minWidth: 0);
    return Breakpoints._(List.unmodifiable(out));
  }

  /// What a new project gets (and a project without any): mobile, tablet
  /// and desktop, as editable data.
  static final Breakpoints defaults = Breakpoints._(const [
    Breakpoint(id: 'mobile', name: 'Mobile', minWidth: 0, width: 390, height: 844),
    Breakpoint(id: 'tablet', name: 'Tablet', minWidth: 600, width: 834, height: 1112),
    Breakpoint(id: 'desktop', name: 'Desktop', minWidth: 1024, width: 1440, height: 900),
  ]);

  /// Narrowest first.
  final List<Breakpoint> list;

  int get length => list.length;
  Breakpoint get first => list.first;
  Breakpoint get last => list.last;
  Iterable<String> get ids => list.map((b) => b.id);

  /// Whether this is [defaults] (stored as nothing).
  bool get isDefault => jsonEquality.equals(toJson(), defaults.toJson());

  /// The breakpoint with [id].
  Breakpoint? byId(String? id) {
    if (id == null) return null;
    for (final b in list) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// The breakpoint [key] names: an id, else a name (or its [Breakpoint.key]),
  /// compared without case.
  Breakpoint? find(String? key) {
    if (key == null || key.isEmpty) return null;
    final byIdHit = byId(key);
    if (byIdHit != null) return byIdHit;
    final k = key.toLowerCase();
    for (final b in list) {
      if (b.id.toLowerCase() == k || b.name.toLowerCase() == k || b.key.toLowerCase() == k) return b;
    }
    return null;
  }

  /// The position of [id] (narrowest 0), or -1.
  int indexOf(String? id) => list.indexWhere((b) => b.id == id);

  /// The breakpoint [width] falls in: the last one, in order, whose min
  /// width is at or below it, else the first.
  Breakpoint forWidth(double width) {
    var best = list.first;
    for (var i = 1; i < list.length; i++) {
      final b = list[i];
      if (width >= b.minWidth) best = b;
    }
    return best;
  }

  /// The breakpoint whose min width is exactly [width], if any.
  Breakpoint? at(double width) {
    for (final b in list) {
      if (b.minWidth == width) return b;
    }
    return null;
  }

  /// Of [candidates] (breakpoint ids: what a responsive variance's variants
  /// or a per-breakpoint value name), the one that governs breakpoint [id]:
  /// [id] itself, else the widest one narrower than it, else the narrowest
  /// (each covers from its breakpoint up to the next candidate's: min-width
  /// semantics, as a screen's canvases). On the default three it is v1's
  /// rule (the nearest, the narrower on a tie), and a breakpoint no
  /// candidate names changes nothing. Ids not in the set are ignored; null
  /// when none is in it (or [id] isn't).
  String? governing(String id, Iterable<String> candidates) {
    final want = indexOf(id);
    if (want < 0) return null;
    String? below, above;
    var belowIndex = -1, aboveIndex = 1 << 30;
    for (final c in candidates) {
      final i = indexOf(c);
      if (i < 0) continue;
      if (i <= want && i > belowIndex) {
        below = c;
        belowIndex = i;
      } else if (i > want && i < aboveIndex) {
        above = c;
        aboveIndex = i;
      }
    }
    return below ?? above;
  }

  /// A new id for a breakpoint of this set.
  String newId([String base = 'bp']) {
    var i = length + 1;
    while (byId('$base$i') != null) {
      i++;
    }
    return '$base$i';
  }

  /// The set with [b] added (a min width another has moves it up by one).
  Breakpoints add(Breakpoint b) {
    var w = b.minWidth;
    while (list.any((x) => x.minWidth == w)) {
      w += 1;
    }
    return Breakpoints([...list.where((x) => x.id != b.id), b.copyWith(minWidth: w)]);
  }

  /// The set with breakpoint [id] replaced by [f] of it.
  Breakpoints update(String id, Breakpoint Function(Breakpoint b) f) =>
      Breakpoints([for (final b in list) b.id == id ? f(b) : b]);

  /// The set without [id] (the last one stays).
  Breakpoints remove(String id) => length < 2 ? this : Breakpoints([for (final b in list) if (b.id != id) b]);

  /// The set with [id] moved [by] places (−1: narrower), keeping the
  /// ranges where they are: it swaps ranges (min widths) with the
  /// breakpoints it passes.
  Breakpoints move(String id, int by) {
    final from = indexOf(id);
    if (from < 0) return this;
    final to = (from + by).clamp(0, length - 1);
    if (to == from) return this;
    final ordered = [...list]..removeAt(from);
    ordered.insert(to, list[from]);
    final widths = [for (final b in list) b.minWidth];
    return Breakpoints([for (var i = 0; i < ordered.length; i++) ordered[i].copyWith(minWidth: widths[i])]);
  }

  /// Decodes a list of breakpoints; nothing usable gives [defaults].
  static Breakpoints fromJson(Object? json) {
    final items = [...?readList(json)?.map(Breakpoint.fromJson).nonNulls];
    return items.isEmpty ? defaults : Breakpoints(items);
  }

  List<Json> toJson() => [for (final b in list) b.toJson()];

  /// The breakpoints' field declarations, as a list prop (for panels).
  static const codec = ListCodec<Breakpoint>(ValueCodec(Breakpoint.fromJson, _out, PropType.record('Breakpoint', Breakpoint.spec)));

  @override
  bool operator ==(Object other) => other is Breakpoints && jsonEquality.equals(other.list, list);

  @override
  int get hashCode => Object.hashAll(list);

  @override
  String toString() => 'Breakpoints($list)';
}

Object? _out(Breakpoint b) => b.toJson();

/// A page document's copy of its project's breakpoints, until the v2 editor
/// keeps per-project data (as it keeps project scripts in the document).
extension LayoutDocumentBreakpoints on LayoutDocument {
  /// The document key.
  static const String key = 'breakpoints';

  /// The project's breakpoints as this document has them ([Breakpoints.defaults]
  /// when it has none).
  Breakpoints get breakpoints => Breakpoints.fromJson(extra[key]);

  /// This document with [value] as its breakpoints (the defaults are stored
  /// as nothing).
  LayoutDocument withBreakpoints(Breakpoints value) => copyWith(extra: {
        for (final e in extra.entries)
          if (e.key != key) e.key: e.value,
        if (!value.isDefault) key: value.toJson(),
      });
}
