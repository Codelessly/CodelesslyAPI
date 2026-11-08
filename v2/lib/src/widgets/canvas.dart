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

  static const spec = WidgetSpec('canvas',
      props: [scaleMode, blockBack, breakpoint, screen], children: ChildModel.slots, slots: ['body', 'appBar', 'floatingActionButton', 'bottomNavigationBar'],
      decorated: true, doc: 'Flutter `Scaffold`.');
}

/// Shows one of several variants of its content (by id, or by breakpoint).
abstract final class VarianceProps {
  /// `[{"id", "name", "children": [ids], "breakpoint"?, "overrides"?}]`;
  /// `breakpoint` is a project [Breakpoint.id] (DESIGN.md §5.3): a variance
  /// with any is responsive.
  static const variants = PropDef<List<Json>>('variants', Codecs.jsonList, []);
  static const current = PropDef<String>('current', Codecs.string, '');

  static const spec = WidgetSpec('variance',
      props: [variants, current],
      children: ChildModel.list,
      decorated: true,
      childFields: [LayoutFields.x, LayoutFields.y],
      doc: 'Variant switcher.');
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
  /// one, the variant of the breakpoint the width resolves to, else of the
  /// widest narrower breakpoint that has one, else the narrowest
  /// ([variantIdForBreakpoint]); any other, its current one.
  Json? variantForWidth(double width, Breakpoints breakpoints) {
    final target = variantIdForBreakpoint(breakpoints.forWidth(width).id, breakpoints);
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
