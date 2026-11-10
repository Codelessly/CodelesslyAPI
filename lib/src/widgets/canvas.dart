import '../json.dart';
import '../node.dart';
import '../props.dart';
import '../publish/breakpoints.dart';
import '../value_fields.dart';

/// How a screen fits the device.
enum ScaleMode { responsive, autoScale }


/// A screen (`Scaffold`): its `body` slot is the page content.
abstract final class CanvasProps {
  static const scaleMode = PropDef<ScaleMode>('scaleMode', EnumCodec(ScaleMode.values), ScaleMode.responsive);

  /// While true, going back (the system or browser back button, a back
  /// gesture) keeps the user on this screen and runs its `backPressed`
  /// reactions instead. Usually bound (`${= dirty}`). A navigate pop from
  /// the screen's own actions is never blocked.
  static const blockBack = PropDef<bool>('blockBack', Codecs.bool, false);

  /// The project breakpoint ([Breakpoint.id]) this canvas is the design for
  /// (DESIGN.md §5.3); empty: none.
  static const breakpoint = PropDef<String>('breakpoint', Codecs.string, '', doc: 'The breakpoint it is the design for.');

  /// The screen this canvas is one breakpoint of: canvases with the same
  /// value are one screen (one canvas per breakpoint). Empty: a screen of
  /// its own.
  static const screen = PropDef<String>('screen', Codecs.string, '', doc: 'The screen it is a breakpoint of.');

  /// Where this canvas starts showing in its screen when not at its
  /// breakpoint's min width (a 10.x layout group's lower bound).
  static const breakpointMinWidth =
      PropDef<double?>('breakpointMinWidth', Codecs.optionalPositive, null, doc: 'Its own switch point.');
  static const spec = WidgetSpec('canvas',
      props: [scaleMode, blockBack, breakpoint, screen, breakpointMinWidth], children: ChildModel.slots, slots: ['body', 'appBar', 'floatingActionButton', 'bottomNavigationBar'],
      decorated: true, doc: 'Flutter `Scaffold`.');
}

/// Shows one of several variants of its content (by id, or by breakpoint).
abstract final class VarianceProps {
  /// `[{"id", "name", "children": [ids], "breakpoint"?, "overrides"?}]`;
  /// `breakpoint` is a project [Breakpoint.id] (DESIGN.md §5.3): a variance
  /// with any is responsive.
  static const variants = PropDef<List<Json>>('variants', Codecs.jsonList, []);
  static const current = PropDef<String>('current', Codecs.string, '');

  /// A responsive variance's own switch points: breakpoint id → the width
  /// it shows that breakpoint's variant from, when not the project's.
  static const minWidths = PropDef<Map<String, double>>('minWidths', BreakpointWidthsCodec(), {},
      doc: 'Its own switch points, by breakpoint.');
  static const spec = WidgetSpec('variance',
      props: [variants, current, minWidths],
      children: ChildModel.list,
      decorated: true,
      childFields: [LayoutFields.x, LayoutFields.y],
      doc: 'Variant switcher.');
}

/// Breakpoint id → width (a variance's own switch points).
final class BreakpointWidthsCodec extends PropCodec<Map<String, double>> {
  const BreakpointWidthsCodec();
  @override
  Map<String, double>? decode(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return {
      for (final e in m.entries)
        if (readDouble(e.value) case final double w when w >= 0) e.key: w,
    };
  }

  @override
  Object encode(Map<String, double> value) => {for (final e in value.entries) e.key: writeDouble(e.value)};

  @override
  PropType get type => const PropType.json('Map<String, double>');
}

/// A variance node's responsive layout (DESIGN.md §5.3).
extension VarianceBreakpoints on Node {
  /// Its variants (`{"id", "name", "children", "breakpoint"?}`).
  List<Json> get varianceVariants => prop(VarianceProps.variants);

  /// Whether it maps variants to breakpoints (and shows the one for the
  /// screen's width).
  bool get isResponsive =>
      type == VarianceProps.spec.type && varianceVariants.any((v) => v['breakpoint'] is String && (v['breakpoint'] as String).isNotEmpty);

  /// The breakpoint id variant [v] is the layout for, if any.
  static String? breakpointOfVariant(Json v) =>
      v['breakpoint'] is String && (v['breakpoint'] as String).isNotEmpty ? v['breakpoint'] as String : null;

  /// The breakpoint this responsive variance shows at [width] of
  /// [breakpoints], by its own switch points ([VarianceProps.minWidths]).
  Breakpoint breakpointForWidth(double width, Breakpoints breakpoints) =>
      breakpoints.forWidth(width, prop(VarianceProps.minWidths));

  /// The variant shown: [VarianceProps.current]'s, else the first.
  Json? get currentVarianceVariant {
    final vs = varianceVariants;
    final current = prop(VarianceProps.current);
    for (final v in vs) {
      if (v['id'] == current) return v;
    }
    return vs.isEmpty ? null : vs.first;
  }

  /// The variant this variance shows on a screen [width] wide: a responsive
  /// one, the variant of the breakpoint the width resolves to by its own
  /// switch points ([breakpointForWidth]), else of the widest narrower
  /// breakpoint that has one, else the narrowest ([variantIdForBreakpoint]);
  /// any other, its current one.
  Json? variantForWidth(double width, Breakpoints breakpoints) {
    final target = variantIdForBreakpoint(breakpointForWidth(width, breakpoints).id, breakpoints);
    if (target != null) {
      for (final v in varianceVariants) {
        if (v['id'] == target) return v;
      }
    }
    return currentVarianceVariant;
  }

  /// The id of the variant for breakpoint [breakpointId]: a variant shows
  /// from its breakpoint up to the next variant's (min-width semantics, as
  /// a screen's canvases), so its own, else the widest narrower one's
  /// ([Breakpoints.governing]); below every variant, the narrowest. Null
  /// when no variant names a breakpoint of [breakpoints].
  String? variantIdForBreakpoint(String breakpointId, Breakpoints breakpoints) {
    final byBreakpoint = <String, String>{};
    for (final v in varianceVariants) {
      final b = breakpointOfVariant(v);
      if (b != null && v['id'] is String) byBreakpoint.putIfAbsent(b, () => v['id'] as String);
    }
    final governing = breakpoints.governing(breakpointId, byBreakpoint.keys);
    return governing == null ? null : byBreakpoint[governing];
  }
}
