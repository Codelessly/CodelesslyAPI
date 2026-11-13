// Actions: what a reaction does, one step of its chain. Pure data, one
// immutable class per action type; the SDK runs each with a typed handler
// (DESIGN.md §5.2).
//
// Text fields of an action are expressions (`${count}`, `${= a + b}`,
// `Hello ${name}`), evaluated when the action runs. `${result}` is what the
// previous action of the chain gave (an API's response, a document id, a
// for-each's item), or the trigger's event.
import 'dart:convert';
import 'package:meta/meta.dart';

import 'action_fields.dart';
import 'behaviors.dart' show AnimationCurve, Behaviors, DragDirection, Spring;
import 'catalog.dart';
import 'conditions.dart';
import 'props.dart' show PropDef, Props;
import 'json.dart';
import 'breakpoints.dart' show Breakpoint, Breakpoints;
import 'route_transition.dart';
import 'values/color.dart';
import 'values/paint.dart' show listEquals;

/// One action. Every action can be turned off ([enabled]), run without
/// being awaited ([nonBlocking]: the chain goes on at once and its failure
/// doesn't stop it) and run only while a predicate holds ([when]). JSON:
/// `{"type": type, ...its fields, "enabled": false, "nonBlocking": true,
/// "when": {...}}`.
///
/// Each action type is declared by an [ActionSpec] in a [Catalog]; decoding
/// looks the type up there. The core types are the sealed [CoreAction]
/// family; each feature library has its own sealed family ([DataAction],
/// [MediaAction], [EngageAction]) or class ([AuthAction], [PaywallAction]); a
/// type declared without a Dart class is a [DeclaredAction], and a type the
/// catalog doesn't declare an [UnknownAction].
@immutable
abstract base class ActionDef {
  const ActionDef({this.enabled = true, this.nonBlocking = false, this.when});

  /// False skips the action.
  final bool enabled;

  /// The chain doesn't wait for it, and its failure doesn't stop the chain.
  final bool nonBlocking;

  /// Runs only when it holds; null: always.
  final Predicate? when;

  /// The JSON `type`.
  String get type;

  /// Its own fields, as JSON (sparse): what [toJson] writes besides `type`
  /// and the common fields. An action class outside this library overrides
  /// this.
  @protected
  Json get fieldsJson => _fields;

  Json get _fields => const {};

  /// The actions it runs itself (branches, follow-ups), in order.
  List<ActionDef> get nested => const [];

  /// This action, then every action nested in it, depth first.
  Iterable<ActionDef> get selfAndNested sync* {
    yield this;
    for (final a in nested) {
      yield* a.selfAndNested;
    }
  }

  Json toJson() => {
    'type': type,
    ...fieldsJson,
    if (!enabled) 'enabled': false,
    if (nonBlocking) 'nonBlocking': true,
    if (when != null) 'when': when!.toJson(),
  };

  /// Decodes an action with [catalog] (default: [Catalog.current]); null
  /// for anything that isn't a JSON object with a type. A type the catalog
  /// doesn't declare is an [UnknownAction].
  static ActionDef? fromJson(Object? json, {Catalog? catalog}) {
    final m = readMap(json);
    final type = readString(m?['type']);
    if (m == null || type == null || type.isEmpty) return null;
    final c = catalog ?? Catalog.current;
    final spec = c.action(type);
    if (spec == null) {
      // A legacy type of a declared one (playAnimation, animateVariable:
      // animate; controlDrag: controlTrack, controlDismissible,
      // controlTransform) reads as it; it is never written.
      final legacy = _legacyDecoders[type];
      if (legacy != null && c.action(_legacyNeeds[type]!) != null) {
        return Catalog.run(c, () => legacy(m, ActionCommon(m, catalog: c)));
      }
      return UnknownAction(type, m);
    }
    return Catalog.run(c, () {
      final common = ActionCommon(m, catalog: c);
      return spec.decode?.call(m, common) ?? DeclaredAction(spec, m, common);
    });
  }

  static List<ActionDef> listFromJson(Object? json, {Catalog? catalog}) =>
      catalog == null || identical(catalog, Catalog.current)
          ? [...?readList(json)?.map(fromJson).nonNulls]
          : Catalog.run(catalog, () => listFromJson(json));

  /// Every action type [Catalog.current] declares, by its JSON `type`.
  static Iterable<String> get types => Catalog.current.actions.map((s) => s.type);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActionDef && other.runtimeType == runtimeType && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());

  @override
  String toString() => '$runtimeType(${toJson()})';
}

/// The core action types: navigation, modals, values and variables, flow,
/// feedback, focus, scroll, animation, scripts, pagination. Exhaustive
/// within itself.
sealed class CoreAction extends ActionDef {
  const CoreAction({super.enabled, super.nonBlocking, super.when});
}

/// The fields every action has.
typedef _Common = ActionCommon;

typedef _Decoder = ActionDef Function(Json m, _Common c);

/// Legacy action types the decoder reads as a current one (never written).
final Map<String, _Decoder> _legacyDecoders = {
  'playAnimation': AnimateAction._fromPlayAnimation,
  'animateVariable': AnimateAction._fromAnimateVariable,
  'controlDrag': _fromControlDrag,
};

/// The type a legacy type needs declared to be read.
const Map<String, String> _legacyNeeds = {
  'playAnimation': AnimateAction.typeName,
  'animateVariable': AnimateAction.typeName,
  'controlDrag': ControlTrackAction.typeName,
};

// --- reading helpers -------------------------------------------------------------

String _s(Json m, String k, [String def = '']) => switch (m[k]) {
  final String s => s,
  final num n => '$n',
  final bool b => '$b',
  _ => def,
};
String? _sOrNull(Json m, String k) => m[k] == null ? null : _s(m, k);
int _i(Json m, String k, int def) => readInt(m[k]) ?? def;
double _d(Json m, String k, double def) => readDouble(m[k]) ?? def;
double? _dOrNull(Json m, String k) => readDouble(m[k]);
bool _b(Json m, String k, bool def) => readBool(m[k]) ?? def;
T _e<T extends Enum>(List<T> values, Json m, String k, T def) => readEnum(values, m[k], def);
List<ActionDef> _list(Json m, String k) => ActionDef.listFromJson(m[k]);
Json _map(Json m, String k) => readMap(m[k]) ?? const {};
List<Json> _actionsJson(List<ActionDef> l) => [for (final a in l) a.toJson()];
AnimationCurve _curve(Json m, String k, AnimationCurve def) => AnimationCurve.parse(m[k]) ?? def;

// --- navigation ----------------------------------------------------------------

/// How a [NavigateAction] moves.
enum NavigationMode {
  /// Pushes the destination over the current screen.
  push,

  /// Goes back (pops the current screen, or closes the open modal); with a
  /// destination, goes there when there's nothing to go back to.
  pop,

  /// Replaces the current screen.
  replace,

  /// Clears the history: the destination becomes the only screen (over
  /// [NavigateAction.base], when set).
  reset,
}

/// A page transition.
enum PageTransition { platform, none, fade, fadeUp, slideUp, slideLeft, scale }

/// Goes to another screen. JSON: `{"type": "navigate", "mode": "push",
/// "to": "canvas-b", "params": {"id": "${item.id}"}}`. The destination
/// reads [params] as `${route.<name>}`.
final class NavigateAction extends CoreAction {
  const NavigateAction({
    this.mode = NavigationMode.push,
    this.to = '',
    this.params = const {},
    this.base = '',
    this.baseParams = const {},
    this.transition = PageTransition.platform,
    this.transitionMs,
    this.reverseTransitionMs,
    this.routeTransition,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'navigate';
  @override
  String get type => typeName;

  final NavigationMode mode;

  /// The destination: a screen (canvas) or layout id. Empty with [mode]
  /// pop: just go back.
  final String to;

  /// Values the destination reads as `${route.<name>}`; text values are
  /// expressions.
  final Json params;

  /// [NavigationMode.reset]: a screen to put under the destination, so
  /// going back from it lands there.
  final String base;
  final Json baseParams;
  final PageTransition transition;
  final int? transitionMs, reverseTransitionMs;

  /// A custom transition for both screens (3D, reveals, a barrier, a drag
  /// that dismisses); when set it replaces [transition], [transitionMs] and
  /// [reverseTransitionMs]. Null plays [transition].
  final RouteTransition? routeTransition;

  static NavigateAction _fromJson(Json m, _Common c) => NavigateAction(
    mode: _e(NavigationMode.values, m, 'mode', NavigationMode.push),
    to: _s(m, 'to'),
    params: _map(m, 'params'),
    base: _s(m, 'base'),
    baseParams: _map(m, 'baseParams'),
    transition: _e(PageTransition.values, m, 'transition', PageTransition.platform),
    transitionMs: readInt(m['transitionMs']),
    reverseTransitionMs: readInt(m['reverseTransitionMs']),
    routeTransition: RouteTransition.fromJson(m['routeTransition']),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    if (mode != NavigationMode.push) 'mode': mode.name,
    if (to.isNotEmpty) 'to': to,
    if (params.isNotEmpty) 'params': params,
    if (base.isNotEmpty) 'base': base,
    if (baseParams.isNotEmpty) 'baseParams': baseParams,
    if (transition != PageTransition.platform) 'transition': transition.name,
    'transitionMs': ?transitionMs,
    'reverseTransitionMs': ?reverseTransitionMs,
    'routeTransition': ?routeTransition?.toJson(),
  };
}

/// How a modal shows.
enum ModalPresentation {
  /// A centered dialog.
  dialog,

  /// A sheet from the bottom.
  bottomSheet,

  /// A bottom sheet on narrow screens, a dialog on wide ones.
  adaptive,

  /// A sheet from the side.
  sideSheet,

  /// The whole screen.
  fullScreen,

  /// A popover next to the node that opened it (or the pointer).
  popover,

  /// A banner along the top edge of the screen (the bottom edge when
  /// [OpenModalAction.alignment]'s y is above 0), with no barrier: the app
  /// behind stays usable. It slides in, a swipe dismisses it when
  /// [OpenModalAction.barrierDismissible], and its screen closes it with a
  /// [CloseModalAction] (after a `delay`, for one that goes by itself). A
  /// runtime that doesn't know it shows a dialog.
  banner,
}

/// Where a popover sits relative to its anchor.
enum PopoverPlacement {
  belowStart,
  belowCenter,
  belowEnd,
  aboveStart,
  aboveCenter,
  aboveEnd, //
  rightStart,
  rightCenter,
  rightEnd,
  leftStart,
  leftCenter,
  leftEnd,
  center,
  bottomSheet,
  adaptive,
  anchored,
}

/// What a popover is anchored to: nothing, the node that opened it, the
/// pointer, or a named node ([OpenModalAction.anchorNode]; in a list, the
/// copy built for [OpenModalAction.anchorItem]), so a modal opened from a
/// keyboard shortcut or a screen's `load` can sit by a node too.
enum ModalAnchor { none, trigger, pointer, node }

/// Shows a screen (canvas) as a modal: a dialog, a sheet, a popover. The
/// [CloseModalAction] that closes it gives the chain that opened it its
/// `${result}`. JSON: `{"type": "openModal", "to": "canvas-d",
/// "presentation": "bottomSheet"}`.
final class OpenModalAction extends CoreAction {
  const OpenModalAction({
    this.to = '',
    this.params = const {},
    this.presentation = ModalPresentation.dialog,
    this.barrierDismissible = true,
    this.barrierColor,
    this.barrierBlur = 0,
    this.showCloseButton = false,
    this.showDragHandle = false,
    this.alignment = const [0, 0],
    this.anchor = ModalAnchor.none,
    this.placement = PopoverPlacement.belowStart,
    this.anchorGap = 4,
    this.anchorOffset = 0,
    this.anchorReserve = 0,
    this.anchorNode = '',
    this.anchorItem = '',
    this.insets = const [0, 0, 0, 0],
    this.sheetWidth,
    this.sheetRadius,
    this.sheetBelow = '',
    this.maxHeightFactor = 1,
    this.fullHeight = false,
    this.cover = false,
    this.enterScale = 1,
    this.routeTransition,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'openModal';
  @override
  String get type => typeName;

  final String to;
  final Json params;
  final ModalPresentation presentation;
  final bool barrierDismissible;

  /// Null: the default scrim (`#8A000000`).
  final Color? barrierColor;
  final double barrierBlur;
  final bool showCloseButton, showDragHandle;

  /// A dialog's alignment in the screen, `[x, y]` (-1 to 1).
  final List<double> alignment;
  final ModalAnchor anchor;
  final PopoverPlacement placement;
  final double anchorGap, anchorOffset;

  /// Room a popover keeps below its top: when its top plus this would pass
  /// the screen's bottom margin, it moves up so this much fits (a menu that
  /// may grow keeps its place). 0: placed by its own height.
  final double anchorReserve;

  /// With [ModalAnchor.node]: the node the popover sits by (its id; an
  /// expression may name it).
  final String anchorNode;

  /// With [ModalAnchor.node], for a node a list repeats: the item whose copy
  /// it sits by (its `id` or `key`, or its index), as `ScrollToAction.item`.
  /// Empty: the node's only (or first) copy.
  final String anchorItem;

  /// Space kept around a dialog: left, top, right, bottom.
  final List<double> insets;
  final double? sheetWidth;

  /// A bottom sheet's top corner radius: the sheet clips the screen to it,
  /// so a screen with a solid canvas fill gets rounded top corners. Null:
  /// the platform's default sheet.
  final double? sheetRadius;

  /// [ModalPresentation.adaptive]: a bottom sheet on screens whose
  /// breakpoint is narrower than this one (a project [Breakpoint.id],
  /// DESIGN.md §5.3), a dialog from it up. Empty (or a breakpoint the
  /// project no longer has): the project's second breakpoint, i.e. a sheet
  /// on the narrowest breakpoint only (a dialog everywhere when the project
  /// has one breakpoint). See [sheetBelowWidthIn].
  final String sheetBelow;

  /// The screen width below which [ModalPresentation.adaptive] is a bottom
  /// sheet, by the project's [breakpoints]: [sheetBelow]'s min width.
  double sheetBelowWidthIn(Breakpoints breakpoints) =>
      breakpoints.byId(sheetBelow)?.minWidth ?? (breakpoints.length > 1 ? breakpoints.list[1].minWidth : 0);
  final double maxHeightFactor;
  final bool fullHeight;

  /// A dialog that covers the screen (inside [insets]): its screen fills it
  /// and is laid out at that size, so its breakpoint and responsive layouts
  /// follow the device, as a screen navigated to does. Not a page route:
  /// the screen behind stays visible through a transparent design.
  final bool cover;
  final double enterScale;

  /// A custom transition for the modal: its entrance, what the screen
  /// behind does, its barrier color (over [barrierColor]) and a drag that
  /// dismisses it. Null opens it the way [presentation] says.
  final RouteTransition? routeTransition;

  static OpenModalAction _fromJson(Json m, _Common c) => OpenModalAction(
    to: _s(m, 'to'),
    params: _map(m, 'params'),
    presentation: _e(ModalPresentation.values, m, 'presentation', ModalPresentation.dialog),
    barrierDismissible: _b(m, 'barrierDismissible', true),
    barrierColor: Color.fromJson(m['barrierColor']),
    barrierBlur: _d(m, 'barrierBlur', 0),
    showCloseButton: _b(m, 'showCloseButton', false),
    showDragHandle: _b(m, 'showDragHandle', false),
    alignment: _doubles(m['alignment'], 2) ?? const [0, 0],
    anchor: _e(ModalAnchor.values, m, 'anchor', ModalAnchor.none),
    placement: _e(PopoverPlacement.values, m, 'placement', PopoverPlacement.belowStart),
    anchorGap: _d(m, 'anchorGap', 4),
    anchorOffset: _d(m, 'anchorOffset', 0),
    anchorReserve: _d(m, 'anchorReserve', 0),
    anchorNode: _s(m, 'anchorNode'),
    anchorItem: _s(m, 'anchorItem'),
    insets: _doubles(m['insets'], 4) ?? const [0, 0, 0, 0],
    sheetWidth: _dOrNull(m, 'sheetWidth'),
    sheetRadius: _dOrNull(m, 'sheetRadius'),
    sheetBelow: _s(m, 'sheetBelow'),
    maxHeightFactor: _d(m, 'maxHeightFactor', 1),
    fullHeight: _b(m, 'fullHeight', false),
    cover: _b(m, 'cover', false),
    enterScale: _d(m, 'enterScale', 1),
    routeTransition: RouteTransition.fromJson(m['routeTransition']),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    if (to.isNotEmpty) 'to': to,
    if (params.isNotEmpty) 'params': params,
    if (presentation != ModalPresentation.dialog) 'presentation': presentation.name,
    if (!barrierDismissible) 'barrierDismissible': false,
    'barrierColor': ?barrierColor?.toJson(),
    if (barrierBlur != 0) 'barrierBlur': writeDouble(barrierBlur),
    if (showCloseButton) 'showCloseButton': true,
    if (showDragHandle) 'showDragHandle': true,
    if (alignment.any((v) => v != 0)) 'alignment': [for (final v in alignment) writeDouble(v)],
    if (anchor != ModalAnchor.none) 'anchor': anchor.name,
    if (placement != PopoverPlacement.belowStart) 'placement': placement.name,
    if (anchorGap != 4) 'anchorGap': writeDouble(anchorGap),
    if (anchorOffset != 0) 'anchorOffset': writeDouble(anchorOffset),
    if (anchorReserve != 0) 'anchorReserve': writeDouble(anchorReserve),
    if (anchorNode.isNotEmpty) 'anchorNode': anchorNode,
    if (anchorItem.isNotEmpty) 'anchorItem': anchorItem,
    if (insets.any((v) => v != 0)) 'insets': [for (final v in insets) writeDouble(v)],
    if (sheetWidth case final double w) 'sheetWidth': writeDouble(w),
    if (sheetRadius case final double r) 'sheetRadius': writeDouble(r),
    if (sheetBelow.isNotEmpty) 'sheetBelow': sheetBelow,
    if (maxHeightFactor != 1) 'maxHeightFactor': writeDouble(maxHeightFactor),
    if (fullHeight) 'fullHeight': true,
    if (cover) 'cover': true,
    if (enterScale != 1) 'enterScale': writeDouble(enterScale),
    'routeTransition': ?routeTransition?.toJson(),
  };
}

List<double>? _doubles(Object? json, int length) {
  final l = readList(json);
  if (l == null || l.length != length) return null;
  final out = [for (final v in l) readDouble(v)];
  return out.contains(null) ? null : out.cast<double>();
}

/// Closes the modal it runs in, giving the chain that opened it [result]
/// (its text values are expressions) as `${result}`.
final class CloseModalAction extends CoreAction {
  const CloseModalAction({this.result, super.enabled, super.nonBlocking, super.when});

  static const typeName = 'closeModal';
  @override
  String get type => typeName;

  /// What the opening chain reads as `${result}`: any JSON value (a menu's
  /// choice, a picked date, a map); its strings are expressions. Null
  /// closes with no result.
  final Object? result;

  static CloseModalAction _fromJson(Json m, _Common c) =>
      CloseModalAction(result: m['result'], enabled: c.enabled, nonBlocking: c.nonBlocking, when: c.when);

  @override
  Json get _fields => {'result': ?result};
}

/// Runs again the action chain whose failure the screen's `actionError`
/// reaction is handling (a toast's Retry after an offline save or a failed
/// load): the same node's reactions to the same trigger, with the same event
/// and list item. Nothing happens outside an `actionError` reaction or when
/// that failure can't be retried (`${error.retryable}` is false).
final class RetryFailedAction extends CoreAction {
  const RetryFailedAction({super.enabled, super.nonBlocking, super.when});

  static const typeName = 'retryFailed';
  @override
  String get type => typeName;

  static RetryFailedAction _fromJson(Json m, _Common c) =>
      RetryFailedAction(enabled: c.enabled, nonBlocking: c.nonBlocking, when: c.when);

  @override
  Json get _fields => const {};
}

/// Opens a URL (a web page, `mailto:`, `tel:`, an app link).
final class OpenLinkAction extends CoreAction {
  const OpenLinkAction({this.url = '', super.enabled, super.nonBlocking, super.when});

  static const typeName = 'openLink';
  @override
  String get type => typeName;

  final String url;

  static OpenLinkAction _fromJson(Json m, _Common c) =>
      OpenLinkAction(url: _s(m, 'url'), enabled: c.enabled, nonBlocking: c.nonBlocking, when: c.when);

  @override
  Json get _fields => {'url': url};
}

// --- values -----------------------------------------------------------------------

/// How a [NodeValue] sets its property.
enum NodeValueMode {
  /// To [NodeValue.value].
  set,

  /// A boolean property to its opposite.
  toggle,

  /// To the trigger's value (an input's new value).
  sync,
}

/// One property a [SetValueAction] sets: a binding path of the node
/// (DESIGN.md §5.1) and its value (a string is an expression).
@immutable
final class NodeValue {
  const NodeValue(this.path, {this.value, this.mode = NodeValueMode.set});

  final String path;
  final Object? value;
  final NodeValueMode mode;

  static NodeValue? fromJson(Object? json) {
    final m = readMap(json);
    final path = readString(m?['path']);
    if (m == null || path == null || path.isEmpty) return null;
    return NodeValue(path, value: m['value'], mode: readEnum(NodeValueMode.values, m['mode'], NodeValueMode.set));
  }

  Json toJson() => {
    'path': path,
    if (mode == NodeValueMode.set) 'value': value,
    if (mode != NodeValueMode.set) 'mode': mode.name,
  };

  @override
  bool operator ==(Object other) =>
      other is NodeValue && other.path == path && other.mode == mode && jsonEquality.equals(other.value, value);

  @override
  int get hashCode => Object.hash(path, mode, jsonEquality.hash(value));
}

/// Sets properties of node [node] at runtime (until the screen goes). A
/// property bound to a variable sets the variable instead.
final class SetValueAction extends CoreAction {
  const SetValueAction({this.node = '', this.values = const [], super.enabled, super.nonBlocking, super.when});

  static const typeName = 'setValue';
  @override
  String get type => typeName;

  final String node;
  final List<NodeValue> values;

  static SetValueAction _fromJson(Json m, _Common c) => SetValueAction(
    node: _s(m, 'node'),
    values: [...?readList(m['values'])?.map(NodeValue.fromJson).nonNulls],
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'node': node,
    'values': [for (final v in values) v.toJson()],
  };
}

/// Shows variant [variant] of variance node [node].
final class SetVariantAction extends CoreAction {
  const SetVariantAction({this.node = '', this.variant = '', super.enabled, super.nonBlocking, super.when});

  static const typeName = 'setVariant';
  @override
  String get type => typeName;

  final String node;

  /// The variant's id (an expression).
  final String variant;

  static SetVariantAction _fromJson(Json m, _Common c) => SetVariantAction(
    node: _s(m, 'node'),
    variant: _s(m, 'variant'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {'node': node, 'variant': variant};
}

/// How a write changes a value.
enum WriteOp {
  /// Replaces the value with [ValueWrite.value].
  set,

  /// Flips a boolean.
  toggle,

  /// A number: adds; a list: appends (each item of a list value); a map:
  /// merges in a map value.
  add,

  /// A number: subtracts.
  subtract,

  /// A list: inserts the value at [ValueWrite.index].
  insert,

  /// A list: inserts each item of a list value at [ValueWrite.index].
  insertAll,

  /// A list: removes the item at [ValueWrite.index].
  removeAt,

  /// A list: removes the items equal to the value; a map: removes key
  /// [ValueWrite.mapKey].
  remove,

  /// A list: sets the item at [ValueWrite.index] (appends at the length);
  /// a map: sets key [ValueWrite.mapKey].
  update,
}

/// How a value is changed: [op] with [value] (an expression), at [index]
/// in a list or [mapKey] in a map (expressions too). Stored flat in its
/// action's JSON: `"op": "insert", "value": "${item}", "index": "0"`.
@immutable
final class ValueWrite {
  const ValueWrite({this.op = WriteOp.set, this.value = '', this.index = '', this.mapKey = ''});

  final WriteOp op;
  final String value;
  final String index;
  final String mapKey;

  static ValueWrite fromJson(Json m) => ValueWrite(
    op: _e(WriteOp.values, m, 'op', WriteOp.set),
    value: _s(m, 'value'),
    index: _s(m, 'index'),
    mapKey: _s(m, 'mapKey'),
  );

  Json toJson() => {
    if (op != WriteOp.set) 'op': op.name,
    if (op != WriteOp.toggle && op != WriteOp.removeAt) 'value': value,
    if (index.isNotEmpty) 'index': index,
    if (mapKey.isNotEmpty) 'mapKey': mapKey,
  };

  @override
  bool operator ==(Object other) =>
      other is ValueWrite && other.op == op && other.value == value && other.index == index && other.mapKey == mapKey;

  @override
  int get hashCode => Object.hash(op, value, index, mapKey);
}

/// Changes variable [variable] (of the screen, or the app): [write]. JSON:
/// `{"type": "setVariable", "variable": "count", "op": "add", "value": "1"}`.
/// A computed variable can't be set. A number can glide to its new value
/// ([animateMs], [curve]): the variable changes every frame (what's bound
/// to it moves with it), and the chain goes on when it arrives.
final class SetVariableAction extends CoreAction {
  const SetVariableAction({
    this.variable = '',
    this.write = const ValueWrite(),
    this.animateMs = '',
    this.curve = AnimationCurve.linear,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'setVariable';
  @override
  String get type => typeName;

  /// The variable's name; a path into it (`draft.title`, `rows[2].done`)
  /// sets that part.
  final String variable;
  final ValueWrite write;

  /// A number: milliseconds to glide to the new value (a number or an
  /// expression); empty or 0 sets it at once.
  final String animateMs;

  /// The easing of an [animateMs] glide.
  final AnimationCurve curve;

  /// Reads one; a legacy glide (`animateMs` on a `set`, `add` or `subtract`
  /// of a variable by a value it can read as a formula) as the
  /// `animate` it is: `animateTo` the new value over that time on [curve].
  static ActionDef _fromJson(Json m, _Common c) => AnimateAction._fromGlide(m, c) ?? _fromSet(m, c);

  static SetVariableAction _fromSet(Json m, _Common c) => SetVariableAction(
    variable: _s(m, 'variable'),
    write: ValueWrite.fromJson(m),
    animateMs: _s(m, 'animateMs').trim() == '0' ? '' : _s(m, 'animateMs'),
    curve: _curve(m, 'curve', AnimationCurve.linear),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'variable': variable,
    ...write.toJson(),
    if (animateMs.isNotEmpty) 'animateMs': animateMs,
    if (curve != AnimationCurve.linear) 'curve': curve.name,
  };
}

/// Calls a function the app registered by [name] with [params] (text
/// values are expressions). Its result is the chain's `${result}`: what the
/// app's code answered (a permission granted, a share completed), which
/// the next actions branch on. A function the app didn't register fails the
/// chain, unless the action is [optional].
final class CallFunctionAction extends CoreAction {
  const CallFunctionAction({
    this.name = '',
    this.params = const {},
    this.optional = false,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'callFunction';
  @override
  String get type => typeName;

  final String name;
  final Json params;

  /// A function the app didn't register is skipped: `${result}` is null and
  /// the chain goes on (an app that hasn't wired a native feature yet).
  final bool optional;

  static CallFunctionAction _fromJson(Json m, _Common c) => CallFunctionAction(
    name: _s(m, 'name'),
    params: _map(m, 'params'),
    optional: _b(m, 'optional', false),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {'name': name, if (params.isNotEmpty) 'params': params, if (optional) 'optional': true};
}

// --- flow ---------------------------------------------------------------------------

/// Runs [then] when [condition] holds, else [orElse]. JSON: `{"type": "if",
/// "condition": {...}, "then": [...], "else": [...]}`.
final class IfAction extends CoreAction {
  const IfAction({
    this.condition,
    this.then = const [],
    this.orElse = const [],
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'if';
  @override
  String get type => typeName;

  /// Null never holds.
  final Predicate? condition;
  final List<ActionDef> then, orElse;

  @override
  List<ActionDef> get nested => [...then, ...orElse];

  static IfAction _fromJson(Json m, _Common c) => IfAction(
    condition: Predicate.fromJson(m['condition']),
    then: _list(m, 'then'),
    orElse: _list(m, 'else'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    if (condition != null) 'condition': condition!.toJson(),
    if (then.isNotEmpty) 'then': _actionsJson(then),
    if (orElse.isNotEmpty) 'else': _actionsJson(orElse),
  };
}

/// Runs [actions] once per item of list [items] (a path or expression).
/// Every action of a turn reads the item and its index as `${loop.item}`
/// and `${loop.index}`; `${result.item}` and `${result.index}` hold them
/// too, until an action of the turn gives a result of its own.
final class ForEachAction extends CoreAction {
  const ForEachAction({this.items = '', this.actions = const [], super.enabled, super.nonBlocking, super.when});

  static const typeName = 'forEach';
  @override
  String get type => typeName;

  final String items;
  final List<ActionDef> actions;

  @override
  List<ActionDef> get nested => actions;

  static ForEachAction _fromJson(Json m, _Common c) => ForEachAction(
    items: _s(m, 'items'),
    actions: _list(m, 'actions'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {'items': items, if (actions.isNotEmpty) 'actions': _actionsJson(actions)};
}

/// Waits [ms] milliseconds, or [duration] (a formula giving them) when that
/// gives a number.
final class DelayAction extends CoreAction {
  const DelayAction({this.ms = 500, this.duration = '', super.enabled, super.nonBlocking, super.when});

  static const typeName = 'delay';
  @override
  String get type => typeName;

  final int ms;
  final String duration;

  static DelayAction _fromJson(Json m, _Common c) => DelayAction(
    ms: _i(m, 'ms', 500),
    duration: _s(m, 'duration'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {'ms': ms, if (duration.isNotEmpty) 'duration': duration};
}

// --- feedback -----------------------------------------------------------------------

/// A toast's look.
enum ToastStyle { neutral, info, success, warning, error }

/// Where a toast shows.
enum ToastPosition { bottom, top }

/// Shows a short message (a snackbar). Its button ([actionLabel]) runs
/// [actions] on the chain that showed it. Cosmetics beyond the fields
/// below (colors, radius, shadows, text styles, offsets per breakpoint)
/// are in [style], JSON.
final class ShowToastAction extends CoreAction {
  const ShowToastAction({
    this.message = '',
    this.title = '',
    this.durationMs = 2600,
    this.toastStyle = ToastStyle.neutral,
    this.position = ToastPosition.bottom,
    this.actionLabel = '',
    this.actions = const [],
    this.showClose = false,
    this.icon,
    this.style = const {},
    this.variables = const {},
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'showToast';
  @override
  String get type => typeName;

  /// Expressions.
  final String message, title;
  final int durationMs;
  final ToastStyle toastStyle;
  final ToastPosition position;
  final String actionLabel;
  final List<ActionDef> actions;
  final bool showClose;

  /// The icon (an icon glyph's JSON, as icon nodes hold it).
  final Json? icon;
  final Json style;

  /// Style values bound to expressions, by style key.
  final Map<String, String> variables;

  @override
  List<ActionDef> get nested => actions;

  static ShowToastAction _fromJson(Json m, _Common c) => ShowToastAction(
    message: _s(m, 'message'),
    title: _s(m, 'title'),
    durationMs: _i(m, 'durationMs', 2600),
    toastStyle: _e(ToastStyle.values, m, 'style', ToastStyle.neutral),
    position: _e(ToastPosition.values, m, 'position', ToastPosition.bottom),
    actionLabel: _s(m, 'actionLabel'),
    actions: _list(m, 'actions'),
    showClose: _b(m, 'showClose', false),
    icon: readMap(m['icon']),
    style: _map(m, 'look'),
    variables: _strings(m['variables']),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'message': message,
    if (title.isNotEmpty) 'title': title,
    if (durationMs != 2600) 'durationMs': durationMs,
    if (toastStyle != ToastStyle.neutral) 'style': toastStyle.name,
    if (position != ToastPosition.bottom) 'position': position.name,
    if (actionLabel.isNotEmpty) 'actionLabel': actionLabel,
    if (actions.isNotEmpty) 'actions': _actionsJson(actions),
    if (showClose) 'showClose': true,
    'icon': ?icon,
    if (style.isNotEmpty) 'look': style,
    if (variables.isNotEmpty) 'variables': variables,
  };
}

Map<String, String> _strings(Object? json) => {
  for (final e in (readMap(json) ?? const {}).entries)
    if (e.value is String) e.key: e.value as String,
};

/// Asks the user to confirm; runs [actions] when they do, [cancelActions]
/// when they don't. With [dialog] (a screen id), that screen is the dialog
/// and what its close modal action returns is `${result}`.
final class ConfirmAction extends CoreAction {
  const ConfirmAction({
    this.title = '',
    this.message = '',
    this.caption = '',
    this.confirmLabel = 'OK',
    this.cancelLabel = 'Cancel',
    this.destructive = false,
    this.actions = const [],
    this.cancelActions = const [],
    this.dialog = '',
    this.params = const {},
    this.presentation = ModalPresentation.dialog,
    this.placement = PopoverPlacement.belowStart,
    this.barrierDismissible = true,
    this.style = const {},
    this.variables = const {},
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'confirm';
  @override
  String get type => typeName;

  /// Expressions.
  final String title, message, caption;
  final String confirmLabel, cancelLabel;
  final bool destructive;
  final List<ActionDef> actions, cancelActions;
  final String dialog;
  final Json params;
  final ModalPresentation presentation;
  final PopoverPlacement placement;
  final bool barrierDismissible;

  /// Cosmetics (colors, radius, border, shadows, text styles, sizes),
  /// JSON.
  final Json style;
  final Map<String, String> variables;

  @override
  List<ActionDef> get nested => [...actions, ...cancelActions];

  static ConfirmAction _fromJson(Json m, _Common c) => ConfirmAction(
    title: _s(m, 'title'),
    message: _s(m, 'message'),
    caption: _s(m, 'caption'),
    confirmLabel: _s(m, 'confirmLabel', 'OK'),
    cancelLabel: _s(m, 'cancelLabel', 'Cancel'),
    destructive: _b(m, 'destructive', false),
    actions: _list(m, 'actions'),
    cancelActions: _list(m, 'cancelActions'),
    dialog: _s(m, 'dialog'),
    params: _map(m, 'params'),
    presentation: _e(ModalPresentation.values, m, 'presentation', ModalPresentation.dialog),
    placement: _e(PopoverPlacement.values, m, 'placement', PopoverPlacement.belowStart),
    barrierDismissible: _b(m, 'barrierDismissible', true),
    style: _map(m, 'look'),
    variables: _strings(m['variables']),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'title': title,
    if (message.isNotEmpty) 'message': message,
    if (caption.isNotEmpty) 'caption': caption,
    if (confirmLabel != 'OK') 'confirmLabel': confirmLabel,
    if (cancelLabel != 'Cancel') 'cancelLabel': cancelLabel,
    if (destructive) 'destructive': true,
    if (actions.isNotEmpty) 'actions': _actionsJson(actions),
    if (cancelActions.isNotEmpty) 'cancelActions': _actionsJson(cancelActions),
    if (dialog.isNotEmpty) 'dialog': dialog,
    if (params.isNotEmpty) 'params': params,
    if (presentation != ModalPresentation.dialog) 'presentation': presentation.name,
    if (placement != PopoverPlacement.belowStart) 'placement': placement.name,
    if (!barrierDismissible) 'barrierDismissible': false,
    if (style.isNotEmpty) 'look': style,
    if (variables.isNotEmpty) 'variables': variables,
  };
}

/// Copies [text] (an expression) to the clipboard.
final class CopyToClipboardAction extends CoreAction {
  const CopyToClipboardAction({this.text = '', super.enabled, super.nonBlocking, super.when});

  static const typeName = 'copyToClipboard';
  @override
  String get type => typeName;

  final String text;

  static CopyToClipboardAction _fromJson(Json m, _Common c) =>
      CopyToClipboardAction(text: _s(m, 'text'), enabled: c.enabled, nonBlocking: c.nonBlocking, when: c.when);

  @override
  Json get _fields => {'text': text};
}

// --- nodes --------------------------------------------------------------------------

/// What an [EditTextAction] does to its text field.
enum EditTextOperation { wrap, toggleList, insert, replaceWord, setText, clear, focus }

/// Edits text field [node]'s text at its cursor: wraps the selection in
/// [before] / [after], toggles a (numbered) list, inserts or sets [text],
/// replaces the word being typed, clears it or focuses it.
final class EditTextAction extends CoreAction {
  const EditTextAction({
    this.node = '',
    this.operation = EditTextOperation.insert,
    this.text = '',
    this.before = '',
    this.after,
    this.numbered = false,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'editText';
  @override
  String get type => typeName;

  final String node;
  final EditTextOperation operation;
  final String text, before;

  /// Null: the same as [before].
  final String? after;
  final bool numbered;

  static EditTextAction _fromJson(Json m, _Common c) => EditTextAction(
    node: _s(m, 'node'),
    operation: _e(EditTextOperation.values, m, 'operation', EditTextOperation.insert),
    text: _s(m, 'text'),
    before: _s(m, 'before'),
    after: _sOrNull(m, 'after'),
    numbered: _b(m, 'numbered', false),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'node': node,
    'operation': operation.name,
    if (text.isNotEmpty) 'text': text,
    if (before.isNotEmpty) 'before': before,
    'after': ?after,
    if (numbered) 'numbered': true,
  };
}

/// Focuses text field [node] (selecting its text with [selectAll]), or
/// takes the focus away ([unfocus]; from every field when [node] is empty).
final class FocusAction extends CoreAction {
  const FocusAction({
    this.node = '',
    this.unfocus = false,
    this.selectAll = false,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'focus';
  @override
  String get type => typeName;

  final String node;
  final bool unfocus, selectAll;

  static FocusAction _fromJson(Json m, _Common c) => FocusAction(
    node: _s(m, 'node'),
    unfocus: _b(m, 'unfocus', false),
    selectAll: _b(m, 'selectAll', false),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {'node': node, if (unfocus) 'unfocus': true, if (selectAll) 'selectAll': true};
}

/// What a [ControlTrackAction] does to a [Track]: [step] turns it by
/// [ControlTrackAction.steps] of its step, as if dragged there (crossing
/// each step, then settling: a dial's nudge buttons); [animateTo] moves it
/// to [ControlTrackAction.value] (`Slider.onChanged(value)`), reporting
/// `changed`, `dragEnd` and `changeEnd`.
enum TrackCommand { step, animateTo }

/// Turns the [Track] of node [node] (several ids: comma-separated, the
/// first on screen takes it). The legacy `controlDrag` `step` reads as it.
final class ControlTrackAction extends CoreAction {
  const ControlTrackAction({
    this.node = '',
    this.command = TrackCommand.step,
    this.steps = '1',
    this.value = '',
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'controlTrack';
  @override
  String get type => typeName;

  final String node;
  final TrackCommand command;

  /// [TrackCommand.step]: how many steps, negative toward the track's start
  /// (a number or an expression).
  final String steps;

  /// [TrackCommand.animateTo]: the value (a number or an expression).
  final String value;

  static ControlTrackAction _fromJson(Json m, _Common c) => ControlTrackAction(
    node: _s(m, 'node'),
    command: _e(TrackCommand.values, m, 'command', TrackCommand.step),
    steps: _s(m, 'steps', '1'),
    value: _s(m, 'value'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'node': node,
    if (command != TrackCommand.step) 'command': command.name,
    if (steps != '1') 'steps': steps,
    if (value.isNotEmpty) 'value': value,
  };
}

/// What a [ControlDismissibleAction] does to a [DismissibleBehavior] (or a
/// [Pan]): [dismiss] flies it off toward the direction as if swiped (and
/// fires that swipe: removing the item); [returnFrom] brings it back from
/// off-screen on that side (re-inserting it; a card built in the next
/// frame, an undo's, starts there); [reset] springs it back to rest.
/// [shake] wiggles it once (deprecated: the `shake` animation preset).
enum DismissCommand { dismiss, returnFrom, reset, shake }

/// Dismisses, brings back or resets node [node] (several ids:
/// comma-separated). The legacy `controlDrag` `fling`, `returnFrom` and
/// `shake` read as it.
final class ControlDismissibleAction extends CoreAction {
  const ControlDismissibleAction({
    this.node = '',
    this.command = DismissCommand.dismiss,
    this.direction = DragDirection.right,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'controlDismissible';
  @override
  String get type => typeName;

  final String node;
  final DismissCommand command;
  final DragDirection direction;

  static ControlDismissibleAction _fromJson(Json m, _Common c) => ControlDismissibleAction(
    node: _s(m, 'node'),
    command: _e(DismissCommand.values, m, 'command', DismissCommand.dismiss),
    direction: _e(DragDirection.values, m, 'direction', DragDirection.right),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'node': node,
    if (command != DismissCommand.dismiss) 'command': command.name,
    if (direction != DragDirection.right) 'direction': direction.name,
  };
}

/// What a [ControlTransformAction] does to a [TransformGesture] (a map, a
/// photo; `transformationController.value = ...`): [reset] springs it to its
/// rest pose (on a node without one, its dismissible or pan: the legacy
/// `controlDrag` `reset`, whose target JSON can't tell); [scaleBy] scales it
/// by [ControlTransformAction.value] (a factor: `1.5` in, `0.67` out) about
/// the middle of what its viewport shows; [animateTo] springs it to the pose
/// [ControlTransformAction.value] gives (`{x, y, scale, rotation}`, keys left
/// out kept: "fit to route").
enum TransformCommand { reset, scaleBy, animateTo }

/// Resets, zooms or poses the transform gesture of node [node]. The legacy
/// `controlDrag` `reset`, `zoom` and `pose` read as it.
final class ControlTransformAction extends CoreAction {
  const ControlTransformAction({
    this.node = '',
    this.command = TransformCommand.reset,
    this.value = '',
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'controlTransform';
  @override
  String get type => typeName;

  final String node;
  final TransformCommand command;

  /// [TransformCommand.scaleBy]: the factor; [TransformCommand.animateTo]:
  /// the pose (a map, its JSON text, or an expression giving one).
  final String value;

  static ControlTransformAction _fromJson(Json m, _Common c) => ControlTransformAction(
    node: _s(m, 'node'),
    command: _e(TransformCommand.values, m, 'command', TransformCommand.reset),
    value: m['value'] is Map ? jsonEncode(m['value']) : _s(m, 'value'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'node': node,
    if (command != TransformCommand.reset) 'command': command.name,
    if (value.isNotEmpty) 'value': value,
  };
}

/// The legacy `controlDrag` (one action over three render objects) as the
/// typed action of its command: `step` → [ControlTrackAction]; `fling`,
/// `returnFrom`, `shake` → [ControlDismissibleAction]; `reset`, `zoom`,
/// `pose` → [ControlTransformAction] (`reset` falls back to a dismissible or
/// pan at run time).
CoreAction _fromControlDrag(Json m, _Common c) {
  final command = readString(m['command']) ?? 'fling';
  final legacy = {...m, 'command': ?switch (command) {
    'fling' => 'dismiss',
    'returnFrom' || 'shake' => command,
    'zoom' => 'scaleBy',
    'pose' => 'animateTo',
    'reset' => 'reset',
    'step' => 'step',
    _ => null,
  }};
  return switch (command) {
    'step' => ControlTrackAction._fromJson(legacy, c),
    'reset' || 'zoom' || 'pose' => ControlTransformAction._fromJson(legacy, c),
    _ => ControlDismissibleAction._fromJson(legacy, c),
  };
}

/// Scrolls node [node] into view: [alignment] 0 puts it at the start of the
/// view, 1 at the end; [offset] moves it further. [axis] limits it to the
/// scroll views along one axis (a map in a sideways window centers a point
/// without scrolling the page under it); null scrolls every one around it.
final class ScrollToAction extends CoreAction {
  const ScrollToAction({
    this.node = '',
    this.item = '',
    this.durationMs = 400,
    this.curve = 'easeInOut',
    this.alignment = 0,
    this.offset = 0,
    this.offsetFormula = '',
    this.axis,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'scrollTo';
  @override
  String get type => typeName;

  final String node;

  /// When [node] repeats (a list's item template, or a node inside it): the
  /// key of the item whose copy to reveal (an expression; the list's item
  /// key, `id` by default, or else its index). Empty: the first copy.
  final String item;
  final int durationMs;

  /// A `Curves` name.
  final String curve;
  final double alignment, offset;

  /// [offset] as an expression (JSON `"offset": "${...}"`): a link's
  /// `${route.offset}`, a value computed at the time. Wins when it gives a
  /// number.
  final String offsetFormula;
  final ScrollAxis? axis;

  static ScrollToAction _fromJson(Json m, _Common c) => ScrollToAction(
    node: _s(m, 'node'),
    item: _s(m, 'item'),
    durationMs: _i(m, 'durationMs', 400),
    curve: _s(m, 'curve', 'easeInOut'),
    alignment: _d(m, 'alignment', 0),
    offset: m['offset'] is String ? 0 : _d(m, 'offset', 0),
    offsetFormula: m['offset'] is String ? m['offset'] as String : '',
    axis: _axis(m['axis']),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'node': node,
    if (item.isNotEmpty) 'item': item,
    if (durationMs != 400) 'durationMs': durationMs,
    if (curve != 'easeInOut') 'curve': curve,
    if (alignment != 0) 'alignment': writeDouble(alignment),
    if (offsetFormula.isNotEmpty)
      'offset': offsetFormula
    else if (offset != 0)
      'offset': writeDouble(offset),
    'axis': ?axis?.name,
  };
}

/// The scroll views a [ScrollToAction] moves.
enum ScrollAxis { horizontal, vertical }

ScrollAxis? _axis(Object? v) => switch (v) {
  'horizontal' => ScrollAxis.horizontal,
  'vertical' => ScrollAxis.vertical,
  _ => null,
};

/// An `AnimationController` method ([AnimateAction.command]).
enum AnimateCommand {
  /// `forward(from:)`: plays to the end; on a variable, carries on toward
  /// [AnimateAction.target] (from where it is, or from [AnimateAction.from]).
  forward,

  /// `reverse(from:)`: plays back to the start.
  reverse,

  /// Forward when at (or heading to) the start, else back.
  toggle,

  /// `repeat()`, as the animation's own [NodeAnimation.repeat] says (forever
  /// when it says nothing).
  repeat,

  /// `stop()`: holds where it is.
  stop,

  /// `reset()`: back to the start, stopped.
  reset,

  /// `animateTo(target)`: from where it is to [AnimateAction.target] (0–1;
  /// on a variable, any number) over [AnimateAction.duration].
  animateTo,

  /// `animateBack(target)`.
  animateBack,

  /// `value = target`: jumps there; a running animation carries on from it.
  set,
}

/// Drives an animation (Flutter's `AnimationController` methods): node
/// [node]'s [animation] ([NodeAnimation]), or the number variable
/// [variable] (an unbounded controller the screen keeps for it). JSON:
/// `{"type": "animate", "node": "card", "animation": "pop", "command":
/// "forward", "from": "0"}`, `{"type": "animate", "variable": "shownTotal",
/// "command": "animateTo", "target": "${total}", "duration": "800", "curve":
/// "easeOutCubic"}`. The chain waits for it to end (`TickerFuture`) unless
/// it's [nonBlocking]; a repeat ends when its count does.
///
/// Reads the legacy `playAnimation` (`forward` from 0) and `animateVariable`
/// (play → `animateTo`, pause and stop → `stop`, resume → `forward`, seek →
/// `set`).
final class AnimateAction extends CoreAction {
  const AnimateAction({
    this.node = '',
    this.animation = '',
    this.variable = '',
    this.command = AnimateCommand.forward,
    this.from = '',
    this.target = '',
    this.duration = '',
    this.curve,
    this.spring,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'animate';
  @override
  String get type => typeName;

  /// Whose animation: a node id or key; empty: the reacting node.
  final String node;

  /// The animation's id on [node]. A node's `particles` burst plays by its
  /// reserved name too.
  final String animation;

  /// Instead of [node] and [animation]: a number variable.
  final String variable;
  final AnimateCommand command;

  /// Expressions: where [AnimateCommand.forward] / [AnimateCommand.reverse]
  /// start (0–1; on a variable, its start value), and the target of
  /// [AnimateCommand.animateTo], [AnimateCommand.animateBack] and
  /// [AnimateCommand.set].
  final String from, target;

  /// An expression giving milliseconds; empty: the animation's.
  final String duration;

  /// Null: the animation's (linear for a variable).
  final AnimationCurve? curve;

  /// `animateWith(SpringSimulation)` toward [target] instead of a duration.
  final Spring? spring;

  static AnimateAction _fromJson(Json m, _Common c) => AnimateAction(
    node: _s(m, 'node'),
    animation: _s(m, 'animation'),
    variable: _s(m, 'variable'),
    command: _e(AnimateCommand.values, m, 'command', AnimateCommand.forward),
    from: _s(m, 'from'),
    target: _s(m, 'target'),
    duration: _s(m, 'duration'),
    curve: AnimationCurve.parse(m['curve']),
    spring: Spring.fromJson(m['spring']),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  /// The legacy `playAnimation`: [node]'s one-shot effect from its start.
  static AnimateAction _fromPlayAnimation(Json m, _Common c) => AnimateAction(
    node: _s(m, 'node'),
    animation: _s(m, 'animation'),
    from: '0',
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  /// A legacy `setVariable` glide (`animateMs`): `animateTo` its new value
  /// (for `add`/`subtract`, the variable plus or minus the value, read when
  /// the action runs). Null when it isn't one it can say so exactly: no
  /// glide, another op, a path into a variable, a value that isn't a number
  /// or a whole expression.
  static AnimateAction? _fromGlide(Json m, _Common c) {
    final ms = _s(m, 'animateMs').trim();
    if (ms.isEmpty || ms == '0') return null;
    final name = _s(m, 'variable').trim();
    if (name.isEmpty || !RegExp(r'^[A-Za-z_]\w*$').hasMatch(name)) return null;
    final write = ValueWrite.fromJson(m);
    if (write.index.isNotEmpty || write.mapKey.isNotEmpty) return null;
    final value = Behaviors.formulaOf(write.value);
    if (value == null) return null;
    final target = switch (write.op) {
      WriteOp.set => write.value,
      WriteOp.add => '\${= $name + ($value)}',
      WriteOp.subtract => '\${= $name - ($value)}',
      _ => null,
    };
    if (target == null) return null;
    return AnimateAction(
      variable: name,
      command: AnimateCommand.animateTo,
      target: target,
      duration: ms,
      curve: _curve(m, 'curve', AnimationCurve.linear),
      enabled: c.enabled,
      nonBlocking: c.nonBlocking,
      when: c.when,
    );
  }

  /// The legacy `animateVariable` (`mode`, `from`, `to`, `durationMs`,
  /// `duration`, `curve`).
  static AnimateAction _fromAnimateVariable(Json m, _Common c) {
    final mode = _s(m, 'mode', 'play');
    final ms = _i(m, 'durationMs', 1000);
    final bound = _s(m, 'duration');
    return AnimateAction(
      variable: _s(m, 'variable'),
      command: switch (mode) {
        'pause' || 'stop' => AnimateCommand.stop,
        'resume' => AnimateCommand.forward,
        'seek' => AnimateCommand.set,
        _ => AnimateCommand.animateTo,
      },
      from: _s(m, 'from'),
      target: _s(m, 'to', '1'),
      duration: bound.trim().isEmpty ? '$ms' : bound,
      curve: AnimationCurve.parse(m['curve']),
      enabled: c.enabled,
      nonBlocking: c.nonBlocking,
      when: c.when,
    );
  }

  @override
  Json get _fields => {
    if (node.isNotEmpty) 'node': node,
    if (animation.isNotEmpty) 'animation': animation,
    if (variable.isNotEmpty) 'variable': variable,
    if (command != AnimateCommand.forward) 'command': command.name,
    if (from.isNotEmpty) 'from': from,
    if (target.isNotEmpty) 'target': target,
    if (duration.isNotEmpty) 'duration': duration,
    'curve': ?curve?.name,
    'spring': ?spring?.toJson(),
  };
}

/// How strong a [HapticAction] buzz is (Flutter's `HapticFeedback`).
enum HapticKind {
  /// The faint tick of a picker or a dial detent.
  selection,

  /// A light, medium or heavy knock.
  light,
  medium,
  heavy,

  /// A long buzz: an error, an alarm.
  vibrate,
}

/// Buzzes the device (`HapticFeedback`, on phones that support it; nothing
/// elsewhere). Its common `when` buzzes only while a setting holds.
final class HapticAction extends CoreAction {
  const HapticAction({this.kind = HapticKind.selection, super.enabled, super.nonBlocking, super.when});

  static const typeName = 'haptic';
  @override
  String get type => typeName;

  final HapticKind kind;

  static HapticAction _fromJson(Json m, _Common c) => HapticAction(
    kind: _e(HapticKind.values, m, 'kind', HapticKind.selection),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {if (kind != HapticKind.selection) 'kind': kind.name};
}

/// Runs script [script] (a layout's `scripts`, by id) with [arguments] (by
/// parameter name; expressions: one `${...}` passes its value as is, other
/// text passes as JSON when it is JSON, else as text). Its result is the
/// chain's `${result}` (and goes in [resultVariable] when set). When it
/// fails, [onError] runs with `${result}` `{error: {type, message, line,
/// column}, logs}`; without [onError] a failure stops the chain.
final class RunScriptAction extends CoreAction {
  const RunScriptAction({
    this.script = '',
    this.arguments = const {},
    this.resultVariable = '',
    this.onError = const [],
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'runScript';
  @override
  String get type => typeName;

  final String script;
  final Map<String, String> arguments;
  final String resultVariable;
  final List<ActionDef> onError;

  @override
  List<ActionDef> get nested => onError;

  /// `arguments`, or `args` as the editor API's own docs wrote it; a value
  /// that isn't text (a number, a list, a map) is kept as its JSON.
  static RunScriptAction _fromJson(Json m, _Common c) => RunScriptAction(
    script: _s(m, 'script'),
    arguments: {
      for (final e in (m['arguments'] is Map ? _map(m, 'arguments') : _map(m, 'args')).entries)
        if (e.value != null) e.key: e.value is String ? e.value as String : jsonEncode(e.value),
    },
    resultVariable: _s(m, 'resultVariable'),
    onError: _list(m, 'onError'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'script': script,
    if (arguments.isNotEmpty) 'arguments': arguments,
    if (resultVariable.isNotEmpty) 'resultVariable': resultVariable,
    if (onError.isNotEmpty) 'onError': _actionsJson(onError),
  };
}

/// An action of a type this version doesn't know: its JSON, kept. Running
/// it does nothing.
final class UnknownAction extends ActionDef {
  UnknownAction(this.unknownType, Json json)
    : json = {
        for (final e in json.entries)
          if (!const {'type', 'enabled', 'nonBlocking', 'when'}.contains(e.key)) e.key: e.value,
      },
      super(
        enabled: readBool(json['enabled']) ?? true,
        nonBlocking: readBool(json['nonBlocking']) ?? false,
        when: Predicate.fromJson(json['when']),
      );

  final String unknownType;
  final Json json;

  @override
  String get type => unknownType;

  @override
  Json get _fields => json;
}

/// An action of a type its catalog declares without a Dart class (a hosted
/// plugin's, or one a native plugin declares by manifest): its [spec] and
/// its fields as typed [props], as a node holds props for its WidgetSpec.
/// Keys the spec doesn't declare are kept ([Props.unknown]).
final class DeclaredAction extends ActionDef {
  DeclaredAction(this.spec, Json json, ActionCommon common)
    : props = Props.fromJson(spec.fieldSpec, {
        for (final e in json.entries)
          if (!const {'type', 'enabled', 'nonBlocking', 'when'}.contains(e.key)) e.key: e.value,
      }),
      super(enabled: common.enabled, nonBlocking: common.nonBlocking, when: common.when);

  final ActionSpec spec;
  final Props props;

  @override
  String get type => spec.type;

  /// The value of [field] (one of [ActionSpec.fields]).
  T get<T>(PropDef<T> field) => props.get(field);

  /// A field's JSON as written ([ActionSpec.fields] decoded, unknown keys raw).
  Json get values => props.toJson(spec.fieldSpec);

  @override
  List<ActionDef> get nested => [for (final k in spec.nested) ...ActionDef.listFromJson(values[k])];

  @override
  Json get _fields => values;
}

/// Whether [a] and [b] hold equal actions in the same order.
bool actionsEqual(List<ActionDef> a, List<ActionDef> b) => listEquals(a, b);

/// What a [PaginateAction] does to a pagination controller.
enum PaginateCommand {
  /// The next page (or, when the list scrolls, loads it).
  next,

  /// The page before, or in a list that loads both ways, the page before
  /// the first one loaded.
  previous,

  /// Page [PaginateAction.page].
  goTo,
  first,

  /// The last page, once the page count is known.
  last,

  /// Forgets the loaded pages and loads the first again.
  refresh,

  /// Loads again the page that failed.
  retry,

  /// A page holds [PaginateAction.pageSize] items, keeping the first item
  /// shown on screen.
  setPageSize,
}

/// Moves the pagination controller of a list or grid (its `pagination`,
/// by [controller], the pagination's name).
final class PaginateAction extends CoreAction {
  const PaginateAction({
    this.controller = '',
    this.command = PaginateCommand.next,
    this.page = '1',
    this.pageSize = '20',
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'paginate';
  @override
  String get type => typeName;

  final String controller;
  final PaginateCommand command;

  /// [PaginateCommand.goTo]'s page, from 1: a number or an expression.
  final String page;

  /// [PaginateCommand.setPageSize]'s size: a number or an expression.
  final String pageSize;

  static PaginateAction _fromJson(Json m, _Common c) => PaginateAction(
    controller: _s(m, 'controller'),
    command: _e(PaginateCommand.values, m, 'command', PaginateCommand.next),
    page: _s(m, 'page', '1'),
    pageSize: _s(m, 'pageSize', '20'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'controller': controller,
    if (command != PaginateCommand.next) 'command': command.name,
    if (page != '1') 'page': page,
    if (pageSize != '20') 'pageSize': pageSize,
  };
}

// --- declarations ---------------------------------------------------------------

/// The core action types (the [CoreAction] family).
const List<ActionSpec> coreActionSpecs = [
  ActionSpec(NavigateAction.typeName, label: 'Navigate', fields: NavigateFields.all, decode: NavigateAction._fromJson),
  ActionSpec(OpenModalAction.typeName, label: 'Open modal', fields: OpenModalFields.all, decode: OpenModalAction._fromJson),
  ActionSpec(CloseModalAction.typeName, label: 'Close modal', fields: CloseModalFields.all, decode: CloseModalAction._fromJson),
  ActionSpec(RetryFailedAction.typeName, label: 'Retry failed actions', fields: [], doc: 'In an actionError reaction: runs the failed action chain again.', decode: RetryFailedAction._fromJson),
  ActionSpec(OpenLinkAction.typeName, label: 'Open link', fields: OpenLinkFields.all, decode: OpenLinkAction._fromJson),
  ActionSpec(SetValueAction.typeName, label: 'Set value', fields: SetValueFields.all, decode: SetValueAction._fromJson),
  ActionSpec(SetVariantAction.typeName, label: 'Set variant', fields: SetVariantFields.all, decode: SetVariantAction._fromJson),
  ActionSpec(SetVariableAction.typeName, label: 'Set variable', fields: SetVariableFields.all, decode: SetVariableAction._fromJson),
  ActionSpec(CallFunctionAction.typeName, label: 'Call function', fields: CallFunctionFields.all, decode: CallFunctionAction._fromJson),
  ActionSpec(IfAction.typeName, label: 'If', fields: IfFields.all, decode: IfAction._fromJson, nested: ['then', 'else']),
  ActionSpec(ForEachAction.typeName, label: 'For each', fields: ForEachFields.all, decode: ForEachAction._fromJson, nested: ['actions']),
  ActionSpec(ShowToastAction.typeName, label: 'Show toast', fields: ShowToastFields.all, decode: ShowToastAction._fromJson, nested: ['actions']),
  ActionSpec(ConfirmAction.typeName, label: 'Confirm', fields: ConfirmFields.all, decode: ConfirmAction._fromJson, nested: ['actions', 'cancelActions']),
  ActionSpec(DelayAction.typeName, label: 'Delay', fields: DelayFields.all, decode: DelayAction._fromJson),
  ActionSpec(CopyToClipboardAction.typeName, label: 'Copy to clipboard', fields: CopyToClipboardFields.all, decode: CopyToClipboardAction._fromJson),
  ActionSpec(EditTextAction.typeName, label: 'Edit text', fields: EditTextFields.all, decode: EditTextAction._fromJson),
  ActionSpec(FocusAction.typeName, label: 'Focus', fields: FocusFields.all, decode: FocusAction._fromJson),
  ActionSpec(ControlTrackAction.typeName, label: 'Control track', fields: ControlTrackFields.all, decode: ControlTrackAction._fromJson),
  ActionSpec(ControlDismissibleAction.typeName, label: 'Control dismissible', fields: ControlDismissibleFields.all, decode: ControlDismissibleAction._fromJson),
  ActionSpec(ControlTransformAction.typeName, label: 'Control transform', fields: ControlTransformFields.all, decode: ControlTransformAction._fromJson),
  ActionSpec(ScrollToAction.typeName, label: 'Scroll to', fields: ScrollToFields.all, decode: ScrollToAction._fromJson),
  ActionSpec(AnimateAction.typeName, label: 'Animate', fields: AnimateFields.all, decode: AnimateAction._fromJson),
  ActionSpec(HapticAction.typeName, label: 'Haptic feedback', fields: HapticFields.all, decode: HapticAction._fromJson),
  ActionSpec(RunScriptAction.typeName, label: 'Run script', fields: RunScriptFields.all, decode: RunScriptAction._fromJson, nested: ['onError']),
  ActionSpec(PaginateAction.typeName, label: 'Paginate', fields: PaginateFields.all, decode: PaginateAction._fromJson),
];
