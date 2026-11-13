// One declaration per widget: its props, each with a Flutter name, a codec
// and Flutter's default. The declaration is the single place a prop exists:
// decoding, encoding, equality and the editor's panels all read it.
import 'package:meta/meta.dart';

import 'child_fits.dart';
import 'json.dart';
import 'value_fields.dart';
import 'values/border.dart';
import 'values/color.dart';
import 'values/geometry.dart';
import 'values/paint.dart';
import 'values/text.dart';

/// The shape of a prop's value, for tools: [PropType.name] is the Flutter
/// type (`double`, `Color`, `EdgeInsets`, `MainAxisAlignment`,
/// `List<Paint>`, `ButtonStyle`), so a properties panel picks the control a
/// Flutter developer expects, docs print it and codegen emits it.
enum PropKind {
  boolean,
  integer,
  number,
  string,

  /// One of [PropType.values].
  enumeration,

  /// A Flutter value type edited as a whole (`Color`, `EdgeInsets`,
  /// `BorderRadius`, `Alignment`, `Offset`, `BoxConstraints`, `IconData`).
  value,

  /// A list of [PropType.item].
  list,

  /// A model made of declared [PropType.fields] (`ButtonStyle`, `TextStyle`,
  /// `Paint`): its JSON is an object with those keys.
  object,

  /// Free-form JSON (data rows, opaque configuration).
  json,
}

/// What a prop holds (see [PropKind]). Pure data, read from a codec
/// ([PropCodec.type]); a prop is nullable when its default is null
/// ([PropDef.nullable]).
@immutable
final class PropType {
  const PropType.boolean()
    : kind = PropKind.boolean,
      name = 'bool',
      values = const [],
      item = null,
      _fields = null,
      _spec = null,
      min = null,
      max = null;
  const PropType.integer({this.min, this.max})
    : kind = PropKind.integer,
      name = 'int',
      values = const [],
      item = null,
      _fields = null,
      _spec = null;
  const PropType.number({this.min, this.max})
    : kind = PropKind.number,
      name = 'double',
      values = const [],
      item = null,
      _fields = null,
      _spec = null;
  const PropType.string()
    : kind = PropKind.string,
      name = 'String',
      values = const [],
      item = null,
      _fields = null,
      _spec = null,
      min = null,
      max = null;

  /// An enum: its Flutter name and its values' names.
  const PropType.enumeration(this.name, this.values)
    : kind = PropKind.enumeration,
      item = null,
      _fields = null,
      _spec = null,
      min = null,
      max = null;

  /// A Flutter value type with a JSON form of its own ([PropKind.value]).
  const PropType.value(this.name)
    : kind = PropKind.value,
      values = const [],
      item = null,
      _fields = null,
      _spec = null,
      min = null,
      max = null;

  /// A list; [name] is the item's Flutter type (the list's is [typeName]).
  const PropType.list(PropType this.item)
    : kind = PropKind.list,
      name = 'List',
      values = const [],
      _fields = null,
      _spec = null,
      min = null,
      max = null;

  /// A model of declared fields. [fields] is a function so a model can
  /// contain itself (a paint's image) and declarations can be cyclic.
  const PropType.object(this.name, List<PropDef<Object?>> Function() fields)
    : kind = PropKind.object,
      values = const [],
      item = null,
      _fields = fields,
      _spec = null,
      min = null,
      max = null;

  /// A model declared as a [WidgetSpec] of fields (a record).
  const PropType.record(this.name, WidgetSpec spec)
    : kind = PropKind.object,
      values = const [],
      item = null,
      _fields = null,
      _spec = spec,
      min = null,
      max = null;
  const PropType.json([this.name = 'Object'])
    : kind = PropKind.json,
      values = const [],
      item = null,
      _fields = null,
      _spec = null,
      min = null,
      max = null;

  final PropKind kind;

  /// The Flutter type name (`List` for lists: see [typeName]).
  final String name;

  /// The value names of an [PropKind.enumeration].
  final List<String> values;

  /// The item type of a [PropKind.list].
  final PropType? item;
  final List<PropDef<Object?>> Function()? _fields;
  final WidgetSpec? _spec;

  /// Bounds of a number (inclusive).
  final num? min, max;

  /// The fields of a [PropKind.object] (empty for other kinds).
  List<PropDef<Object?>> get fields => _fields?.call() ?? _spec?.props ?? const [];

  /// The full Flutter type name (`List<Paint>`).
  String get typeName => kind == PropKind.list ? 'List<${item!.typeName}>' : name;

  @override
  String toString() => 'PropType($typeName)';
}

/// Reads and writes one prop's JSON. Decoding returns null for values it
/// can't read (the prop then has its default).
abstract class PropCodec<T> {
  const PropCodec();
  T? decode(Object? json);
  Object? encode(T value);

  /// What the values are (for panels, docs, codegen).
  PropType get type;
}

final class DoubleCodec extends PropCodec<double> {
  const DoubleCodec({this.min, this.max, this.ratio = false});
  final double? min, max;

  /// A ratio (an aspect ratio): stored with [writeRatio]'s precision, not
  /// rounded to 4 decimals.
  final bool ratio;
  @override
  double? decode(Object? json) {
    var v = readDouble(json);
    if (v == null) return null;
    if (min != null && v < min!) v = min!;
    if (max != null && v > max!) v = max!;
    return v;
  }

  @override
  Object encode(double value) => ratio ? writeRatio(value) : writeDouble(value);

  @override
  PropType get type => PropType.number(min: min, max: max);
}

final class IntCodec extends PropCodec<int> {
  const IntCodec({this.min});
  final int? min;
  @override
  int? decode(Object? json) {
    final v = readInt(json);
    return v == null || (min != null && v < min!) ? (v == null ? null : min) : v;
  }

  @override
  Object encode(int value) => value;

  @override
  PropType get type => PropType.integer(min: min);
}

/// A double that may be absent (`itemExtent`, `mainAxisExtent`).
final class OptionalDoubleCodec extends PropCodec<double?> {
  const OptionalDoubleCodec({this.min, this.ratio = false});
  final double? min;

  /// A ratio: stored with [writeRatio]'s precision.
  final bool ratio;
  @override
  double? decode(Object? json) {
    final v = readDouble(json);
    if (v == null) return null;
    return min != null && v < min! ? min : v;
  }

  @override
  Object? encode(double? value) => value == null ? null : (ratio ? writeRatio(value) : writeDouble(value));

  @override
  PropType get type => PropType.number(min: min);
}

/// An int that may be absent (`maxLines`).
final class OptionalIntCodec extends PropCodec<int?> {
  const OptionalIntCodec();
  @override
  int? decode(Object? json) => readInt(json);
  @override
  Object? encode(int? value) => value;

  @override
  PropType get type => const PropType.integer();
}

final class BoolCodec extends PropCodec<bool> {
  const BoolCodec();
  @override
  bool? decode(Object? json) => readBool(json);
  @override
  Object encode(bool value) => value;

  @override
  PropType get type => const PropType.boolean();
}

final class StringCodec extends PropCodec<String> {
  const StringCodec();
  @override
  String? decode(Object? json) => json is String ? json : (json is num ? '$json' : null);
  @override
  Object encode(String value) => value;

  @override
  PropType get type => const PropType.string();
}

final class EnumCodec<T extends Enum> extends PropCodec<T> {
  const EnumCodec(this.values);
  final List<T> values;
  @override
  T? decode(Object? json) {
    for (final v in values) {
      if (v.name == json) return v;
    }
    return null;
  }

  @override
  Object encode(T value) => value.name;

  @override
  PropType get type => PropType.enumeration('$T', [for (final v in values) v.name]);
}

/// A value type with its own `fromJson` / `toJson`.
final class ValueCodec<T> extends PropCodec<T> {
  const ValueCodec(this._decode, this._encode, this.type);
  final T? Function(Object?) _decode;
  final Object? Function(T) _encode;
  @override
  final PropType type;
  @override
  T? decode(Object? json) => json == null ? null : _decode(json);
  @override
  Object? encode(T value) => _encode(value);
}

final class ListCodec<T> extends PropCodec<List<T>> {
  const ListCodec(this.item);
  final PropCodec<T> item;
  @override
  List<T>? decode(Object? json) => readList(json)?.map(item.decode).whereType<T>().toList();
  @override
  Object encode(List<T> value) => [for (final v in value) item.encode(v)];

  @override
  PropType get type => PropType.list(item.type);
}

Object? _valueOut(Object? v) => v == null ? null : (v as dynamic).toJson();
Object? _same(Object? v) => v;
Color? _colorIn(Object? j) => Color.fromJson(j);
EdgeInsets? _insetsIn(Object? j) => j == null ? null : EdgeInsets.fromJson(j);
BorderRadius? _radiusIn(Object? j) => j == null ? null : BorderRadius.fromJson(j);
Offset? _offsetIn(Object? j) => readList(j)?.length == 2 ? Offset.fromJson(j) : null;
BoxConstraints? _constraintsIn(Object? j) => readMap(j) == null ? null : BoxConstraints.fromJson(j);
TextRun? _runIn(Object? j) => TextRun.fromJson(j);
Json? _jsonIn(Object? j) => readMap(j);
Json? _glyphIn(Object? j) => _iconIn(j).let((m) => m == null || m.isEmpty ? null : m);
/// A bare string names a glyph: an image URL, else a Material icon (a
/// binding like `playing ? 'pause' : 'play_arrow'` swaps the glyph; a
/// suffix like `lock_open_rounded` picks the style).
Json? _iconNamed(String s) {
  final name = s.trim();
  if (name.isEmpty) return const {};
  if (name.startsWith('http://') || name.startsWith('https://') || name.startsWith('data:')) return {'image': name};
  return materialIconNamed(name);
}

Json? _iconIn(Object? j) => j is String ? _iconNamed(j) : readMap(j).let((m) => m == null || m['image'] != null || m['imageUrl'] is! String
    ? m
    : {for (final e in m.entries) if (e.key != 'imageUrl') e.key: e.value, 'image': m['imageUrl']});

/// The Material icon [name] names (`check_circle`, `lock_open_rounded`):
/// a suffix (`_outlined`, `_rounded`, `_sharp`) sets its style. Null when
/// [name] isn't an icon name.
Json? materialIconNamed(String name) {
  final key = name.trim().toLowerCase();
  if (!RegExp(r'^[a-z0-9_]+$').hasMatch(key)) return null;
  for (final (suffix, style) in const [('_outlined', 'outlined'), ('_rounded', 'rounded'), ('_sharp', 'sharp')]) {
    if (key.endsWith(suffix)) {
      return {'type': 'MATERIAL_ICON', 'name': key.substring(0, key.length - suffix.length), 'style': style};
    }
  }
  return {'type': 'MATERIAL_ICON', 'name': key, 'style': 'filled'};
}
List<Json>? _jsonListIn(Object? j) => readList(j)?.map(readMap).nonNulls.toList();
TextStyle? _styleIn(Object? j) => TextStyle.fromJson(j);
BorderSide? _sideIn(Object? j) => BorderSide.fromJson(j);
Paint? _paintIn(Object? j) => Paint.fromJson(j);
Effect? _effectIn(Object? j) => Effect.fromJson(j);

/// A string that may be absent (a font family that falls back).
final class OptionalStringCodec extends PropCodec<String?> {
  const OptionalStringCodec();
  @override
  String? decode(Object? json) => json is String ? json : null;
  @override
  Object? encode(String? value) => value;
  @override
  PropType get type => const PropType.string();
}

/// An enum value that may be absent (Flutter's nullable enum parameters).
final class OptionalEnumCodec<T extends Enum> extends PropCodec<T?> {
  const OptionalEnumCodec(this.values);
  final List<T> values;
  @override
  T? decode(Object? json) {
    for (final v in values) {
      if (v.name == json) return v;
    }
    return null;
  }

  @override
  Object? encode(T? value) => value?.name;
  @override
  PropType get type => PropType.enumeration('$T', [for (final v in values) v.name]);
}

/// A bool that may be absent (null: the widget's own default).
final class OptionalBoolCodec extends PropCodec<bool?> {
  const OptionalBoolCodec();
  @override
  bool? decode(Object? json) => readBool(json);
  @override
  Object? encode(bool? value) => value;
  @override
  PropType get type => const PropType.boolean();
}

/// The Flutter value types' [PropType]s.
abstract final class PropTypes {
  static const color = PropType.value('Color');
  static const edgeInsets = PropType.value('EdgeInsets');
  static const borderRadius = PropType.value('BorderRadius');
  static const alignment = PropType.value('Alignment');
  static const offset = PropType.value('Offset');
  static const boxConstraints = PropType.value('BoxConstraints');

  /// An icon glyph (the icon widget's `icon` prop JSON).
  static const icon = PropType.value('IconData');
  static const textStyle = PropType.object('TextStyle', textStyleFields);
  static const borderSide = PropType.object('BorderSide', borderSideFields);
  static const paint = PropType.object('Paint', paintFields);
  static const effect = PropType.object('Effect', effectFields);
  static const textRun = PropType.object('TextRun', textRunFields);
  static const json = PropType.json();
  static const jsonList = PropType.list(PropType.json());
}

typedef _Double = double;

/// Common codecs. Nullable variants (`optional*`) read a missing or
/// unreadable value as null.
abstract final class Codecs {
  static const double = DoubleCodec();
  static const positive = DoubleCodec(min: 0);
  static const optionalDouble = OptionalDoubleCodec();
  static const optionalPositive = OptionalDoubleCodec(min: 0);
  static const int = IntCodec();
  static const optionalInt = OptionalIntCodec();
  static const bool = BoolCodec();
  static const optionalBool = OptionalBoolCodec();
  static const string = StringCodec();
  static const optionalString = OptionalStringCodec();
  static const color = ValueCodec<Color>(_colorIn, _valueOut, PropTypes.color);
  static const optionalColor = ValueCodec<Color?>(_colorIn, _valueOut, PropTypes.color);
  static const insets = ValueCodec<EdgeInsets>(EdgeInsets.fromJson, _valueOut, PropTypes.edgeInsets);
  static const optionalInsets = ValueCodec<EdgeInsets?>(_insetsIn, _valueOut, PropTypes.edgeInsets);
  static const radius = ValueCodec<BorderRadius>(BorderRadius.fromJson, _valueOut, PropTypes.borderRadius);
  static const optionalRadius = ValueCodec<BorderRadius?>(_radiusIn, _valueOut, PropTypes.borderRadius);
  static const alignment = ValueCodec<Alignment>(Alignment.fromJson, _valueOut, PropTypes.alignment);
  static const optionalAlignment = ValueCodec<Alignment?>(Alignment.fromJson, _valueOut, PropTypes.alignment);
  static const offset = ValueCodec<Offset>(Offset.fromJson, _valueOut, PropTypes.offset);
  static const optionalOffset = ValueCodec<Offset?>(_offsetIn, _valueOut, PropTypes.offset);
  static const constraints = ValueCodec<BoxConstraints>(BoxConstraints.fromJson, _valueOut, PropTypes.boxConstraints);
  static const optionalConstraints = ValueCodec<BoxConstraints?>(_constraintsIn, _valueOut, PropTypes.boxConstraints);
  static const textStyle = ValueCodec<TextStyle>(_styleIn, _valueOut, PropTypes.textStyle);
  static const borderSide = ValueCodec<BorderSide>(_sideIn, _valueOut, PropTypes.borderSide);
  static const optionalBorderSide = ValueCodec<BorderSide?>(_sideIn, _valueOut, PropTypes.borderSide);
  static const paint = ValueCodec<Paint>(_paintIn, _valueOut, PropTypes.paint);
  static const paints = ListCodec<Paint>(paint);
  static const effects = ListCodec<Effect>(ValueCodec<Effect>(_effectIn, _valueOut, PropTypes.effect));
  static const textRuns = ListCodec<TextRun>(ValueCodec(_runIn, _valueOut, PropTypes.textRun));
  static const doubles = ListCodec<_Double>(double);
  static const strings = ListCodec<String>(string);

  /// An icon glyph (`IconData`, or an SVG / image): `{"source", "name",
  /// "codepoint", ...}` or `{"svg"|"image": url}`.
  /// An image icon's URL may also come as `imageUrl` (as JSON written by
  /// hand often names it); it's read as `image`. A plain string (often a
  /// bound value) is a Material icon name, or an image URL.
  static const icon = ValueCodec<Json>(_iconIn, _same, PropTypes.icon);
  static const optionalIcon = ValueCodec<Json?>(_glyphIn, _same, PropTypes.icon);

  /// A free-form JSON object.
  static const json = ValueCodec<Json>(_jsonIn, _same, PropTypes.json);

  /// Free-form JSON objects (data rows).
  static const jsonList = ValueCodec<List<Json>>(_jsonListIn, _same, PropTypes.jsonList);

  /// Any JSON value.
  static const any = ValueCodec<Object?>(_same, _same, PropTypes.json);
}

/// One prop of a widget.
@immutable
final class PropDef<T> {
  const PropDef(this.key, this.codec, this.defaultValue, {this.doc = ''});

  /// The JSON key: Flutter's parameter name.
  final String key;
  final PropCodec<T> codec;

  /// Flutter's default. Values equal to it aren't stored.
  final T defaultValue;
  final String doc;

  T? decode(Object? json) => codec.decode(json);
  Object? encode(T value) => codec.encode(value);

  /// What the prop holds.
  PropType get type => codec.type;

  /// Whether the prop may be unset (null: the widget's own default).
  bool get nullable => defaultValue == null;

  /// [value] as this prop's declared type: as is when it has it, else read
  /// by the codec (an `int` for a double prop is that double, a JSON value
  /// is decoded). A call site can infer a wider type than declared
  /// (`withProp(FlexProps.spacing, 31)` infers `num`), so a value is
  /// checked against the declaration, not the call. Throws an
  /// [ArgumentError] for a value the codec can't read.
  T? coerce(Object? value) {
    if (value is T) return value;
    final v = codec.decode(value);
    if (v == null && value != null) {
      throw ArgumentError.value(value, key, 'Not a value of $T');
    }
    return v;
  }

  @override
  String toString() => 'PropDef($key)';
}

/// How a widget takes children.
enum ChildModel {
  /// A leaf.
  none,

  /// An ordered list (`children`).
  list,

  /// Named slots only (`slots`).
  slots,
}

/// The declaration of one widget type.
@immutable
final class WidgetSpec {
  const WidgetSpec(
    this.type, {
    required this.props,
    this.children = ChildModel.none,
    this.slots = const [],
    this.decorated = false,
    this.childFields = const [],
    this.childFits,
    this.doc = '',
  });

  /// The node `type`.
  final String type;
  final List<PropDef<Object?>> props;
  final ChildModel children;

  /// Named slots this widget takes (`body`, `leading`...).
  final List<String> slots;

  /// Has a box decoration (fills, strokes, radius, effects).
  final bool decorated;

  /// What this widget reads from each child's layout to place it: Flutter's
  /// parent data (`Positioned` in a stack, `Flexible`/`Align` in a flex).
  /// The fields are `LayoutFields`; a child's panel shows them as its
  /// placement, chosen by its parent.
  final List<PropDef<Object?>> childFields;

  /// Which size fits a child may take (null: `defaultChildFits`); see
  /// `childFitOptions`.
  final ChildFitRule? childFits;
  final String doc;

  PropDef<Object?>? prop(String key) {
    for (final p in props) {
      if (p.key == key) return p;
    }
    return null;
  }
}

/// A widget's prop values: only the ones that differ from Flutter's defaults
/// are held. Keys a declaration doesn't know round-trip untouched, and read
/// through a [PropDef] they decode: a node decoded with a catalog that
/// doesn't declare its type (`Catalog.core` reading a `video`) still gives
/// its values to code that knows the type.
@immutable
final class Props {
  const Props._(this._values, this._unknown, [this._defs = const {}]);

  static const Props empty = Props._({}, {});

  final Map<String, Object?> _values;
  final Json _unknown;

  /// The declaration of each held value, so the props encode without the
  /// spec they were decoded or set with. Not part of their value.
  final Map<String, PropDef<Object?>> _defs;

  /// The value of [def] (its default when unset).
  T get<T>(PropDef<T> def) {
    final v = _values[def.key];
    if (v != null) return v as T;
    if (_unknown.isNotEmpty && _unknown.containsKey(def.key)) return def.decode(_unknown[def.key]) ?? def.defaultValue;
    return def.defaultValue;
  }

  /// Whether [def] holds a non-default value.
  bool has(PropDef<Object?> def) {
    if (_values.containsKey(def.key)) return true;
    if (!_unknown.containsKey(def.key)) return false;
    final v = def.decode(_unknown[def.key]);
    return v != null && !jsonEquality.equals(v, def.defaultValue);
  }

  /// These props with [def] set to [value], held as [def]'s declared type
  /// ([PropDef.coerce]).
  Props set<T>(PropDef<T> def, T value) {
    final typed = def.coerce(value);
    final next = {..._values};
    final defs = {..._defs};
    if (typed == null || jsonEquality.equals(typed, def.defaultValue)) {
      next.remove(def.key);
      defs.remove(def.key);
    } else {
      next[def.key] = typed;
      defs[def.key] = def;
    }
    final unknown = _unknown.containsKey(def.key) ? ({..._unknown}..remove(def.key)) : _unknown;
    return Props._(next, unknown, defs);
  }

  /// Keys no declaration knows (kept for round trips).
  Json get unknown => _unknown;

  bool get isEmpty => _values.isEmpty && _unknown.isEmpty;

  static Props fromJson(WidgetSpec? spec, Object? json) {
    final m = readMap(json);
    if (m == null || m.isEmpty) return empty;
    final values = <String, Object?>{};
    final unknown = <String, Object?>{};
    final defs = <String, PropDef<Object?>>{};
    for (final e in m.entries) {
      final def = spec?.prop(e.key);
      if (def == null) {
        unknown[e.key] = e.value;
        continue;
      }
      final v = def.decode(e.value);
      if (v != null && !jsonEquality.equals(v, def.defaultValue)) {
        values[e.key] = v;
        defs[e.key] = def;
      }
    }
    return Props._(values, unknown, defs);
  }

  Json toJson(WidgetSpec? spec) {
    final j = <String, Object?>{..._unknown};
    for (final e in _values.entries) {
      final def = spec?.prop(e.key) ?? _defs[e.key];
      j[e.key] = def == null ? e.value : def.encode(e.value);
    }
    return j;
  }

  @override
  bool operator ==(Object other) =>
      other is Props && jsonEquality.equals(other._values, _values) && jsonEquality.equals(other._unknown, _unknown);

  @override
  int get hashCode => Object.hash(jsonEquality.hash(_values), jsonEquality.hash(_unknown));

  @override
  String toString() => 'Props($_values${_unknown.isEmpty ? '' : ', unknown: $_unknown'})';
}
