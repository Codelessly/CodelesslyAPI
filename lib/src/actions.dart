// Actions: what a reaction does, one step of its chain. Pure data, one
// immutable class per action type; the SDK runs each with a typed handler
// (DESIGN.md §5.2).
//
// Text fields of an action are expressions (`${count}`, `${= a + b}`,
// `Hello ${name}`), evaluated when the action runs. `${result}` is what the
// previous action of the chain gave (an API's response, a document id, a
// for-each's item), or the trigger's event.
import 'package:meta/meta.dart';

import 'behaviours.dart' show AnimationCurve, DragDirection;
import 'conditions.dart';
import 'json.dart';
import 'publish/breakpoints.dart' show Breakpoint, Breakpoints;
import 'route_transition.dart';
import 'services/cloud.dart';
import 'values/color.dart';
import 'values/paint.dart' show listEquals;
import 'variables.dart';

/// One action. Every action can be turned off ([enabled]), run without
/// being awaited ([nonBlocking]: the chain goes on at once and its failure
/// doesn't stop it) and run only while a predicate holds ([when]). JSON:
/// `{"type": type, ...its fields, "enabled": false, "nonBlocking": true,
/// "when": {...}}`. Unknown types decode as [UnknownAction].
@immutable
sealed class ActionDef {
  const ActionDef({this.enabled = true, this.nonBlocking = false, this.when});

  /// False skips the action.
  final bool enabled;

  /// The chain doesn't wait for it, and its failure doesn't stop the chain.
  final bool nonBlocking;

  /// Runs only when it holds; null: always.
  final Predicate? when;

  /// The JSON `type`.
  String get type;

  /// Its own fields, as JSON (sparse).
  Json get _fields;

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
    ..._fields,
    if (!enabled) 'enabled': false,
    if (nonBlocking) 'nonBlocking': true,
    if (when != null) 'when': when!.toJson(),
  };

  /// Decodes an action; null for anything that isn't a JSON object with a
  /// type. A type this version doesn't know is an [UnknownAction].
  static ActionDef? fromJson(Object? json) {
    final m = readMap(json);
    final type = readString(m?['type']);
    if (m == null || type == null || type.isEmpty) return null;
    final c = _Common(m);
    final decode = _decoders[type];
    return decode == null ? UnknownAction(type, m) : decode(m, c);
  }

  static List<ActionDef> listFromJson(Object? json) => [...?readList(json)?.map(fromJson).nonNulls];

  /// Every action type, by its JSON `type`.
  static Iterable<String> get types => _decoders.keys;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActionDef && other.runtimeType == runtimeType && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());

  @override
  String toString() => '$runtimeType(${toJson()})';
}

/// The fields every action has.
final class _Common {
  _Common(Json m)
    : enabled = readBool(m['enabled']) ?? true,
      nonBlocking = readBool(m['nonBlocking']) ?? false,
      when = Predicate.fromJson(m['when']);
  final bool enabled, nonBlocking;
  final Predicate? when;
}

typedef _Decoder = ActionDef Function(Json m, _Common c);

final Map<String, _Decoder> _decoders = {
  NavigateAction.typeName: NavigateAction._fromJson,
  OpenModalAction.typeName: OpenModalAction._fromJson,
  CloseModalAction.typeName: CloseModalAction._fromJson,
  OpenLinkAction.typeName: OpenLinkAction._fromJson,
  SubmitFormAction.typeName: SubmitFormAction._fromJson,
  SetValueAction.typeName: SetValueAction._fromJson,
  SetVariantAction.typeName: SetVariantAction._fromJson,
  SetVariableAction.typeName: SetVariableAction._fromJson,
  CallFunctionAction.typeName: CallFunctionAction._fromJson,
  CallApiAction.typeName: CallApiAction._fromJson,
  SetStorageAction.typeName: SetStorageAction._fromJson,
  CloudDocumentsAction.typeName: CloudDocumentsAction._fromJson,
  LoadCloudDataAction.typeName: LoadCloudDataAction._fromJson,
  AuthAction.typeName: AuthAction._fromJson,
  IfAction.typeName: IfAction._fromJson,
  ForEachAction.typeName: ForEachAction._fromJson,
  CloudFilesAction.typeName: CloudFilesAction._fromJson,
  ShowToastAction.typeName: ShowToastAction._fromJson,
  ConfirmAction.typeName: ConfirmAction._fromJson,
  DelayAction.typeName: DelayAction._fromJson,
  CloudDataAction.typeName: CloudDataAction._fromJson,
  CloudBatchAction.typeName: CloudBatchAction._fromJson,
  CopyToClipboardAction.typeName: CopyToClipboardAction._fromJson,
  DownloadFileAction.typeName: DownloadFileAction._fromJson,
  EditTextAction.typeName: EditTextAction._fromJson,
  PaywallAction.typeName: PaywallAction._fromJson,
  FocusAction.typeName: FocusAction._fromJson,
  ControlDragAction.typeName: ControlDragAction._fromJson,
  SpeakAction.typeName: SpeakAction._fromJson,
  ScrollToAction.typeName: ScrollToAction._fromJson,
  PlaySoundAction.typeName: PlaySoundAction._fromJson,
  PlayAnimationAction.typeName: PlayAnimationAction._fromJson,
  AnimateVariableAction.typeName: AnimateVariableAction._fromJson,
  HapticAction.typeName: HapticAction._fromJson,
  RunScriptAction.typeName: RunScriptAction._fromJson,
  PaginateAction.typeName: PaginateAction._fromJson,
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
final class NavigateAction extends ActionDef {
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

/// What a popover is anchored to.
enum ModalAnchor { none, trigger, pointer }

/// Shows a screen (canvas) as a modal: a dialog, a sheet, a popover. The
/// [CloseModalAction] that closes it gives the chain that opened it its
/// `${result}`. JSON: `{"type": "openModal", "to": "canvas-d",
/// "presentation": "bottomSheet"}`.
final class OpenModalAction extends ActionDef {
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
    this.insets = const [0, 0, 0, 0],
    this.sheetWidth,
    this.sheetBelow = '',
    this.maxHeightFactor = 1,
    this.fullHeight = false,
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

  /// Space kept around a dialog: left, top, right, bottom.
  final List<double> insets;
  final double? sheetWidth;

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
    insets: _doubles(m['insets'], 4) ?? const [0, 0, 0, 0],
    sheetWidth: _dOrNull(m, 'sheetWidth'),
    sheetBelow: _s(m, 'sheetBelow'),
    maxHeightFactor: _d(m, 'maxHeightFactor', 1),
    fullHeight: _b(m, 'fullHeight', false),
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
    if (insets.any((v) => v != 0)) 'insets': [for (final v in insets) writeDouble(v)],
    if (sheetWidth case final double w) 'sheetWidth': writeDouble(w),
    if (sheetBelow.isNotEmpty) 'sheetBelow': sheetBelow,
    if (maxHeightFactor != 1) 'maxHeightFactor': writeDouble(maxHeightFactor),
    if (fullHeight) 'fullHeight': true,
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
final class CloseModalAction extends ActionDef {
  const CloseModalAction({this.result = const {}, super.enabled, super.nonBlocking, super.when});

  static const typeName = 'closeModal';
  @override
  String get type => typeName;

  final Json result;

  static CloseModalAction _fromJson(Json m, _Common c) =>
      CloseModalAction(result: _map(m, 'result'), enabled: c.enabled, nonBlocking: c.nonBlocking, when: c.when);

  @override
  Json get _fields => {if (result.isNotEmpty) 'result': result};
}

/// Opens a URL (a web page, `mailto:`, `tel:`, an app link).
final class OpenLinkAction extends ActionDef {
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

/// Where a form goes.
enum FormService { mailchimp }

/// Submits a sign-up form to a newsletter service: the email in text field
/// [emailField] (and names in [firstNameField], [lastNameField]).
final class SubmitFormAction extends ActionDef {
  const SubmitFormAction({
    this.service = FormService.mailchimp,
    this.emailField = '',
    this.apiKey = '',
    this.dataCenter = '',
    this.listId = '',
    this.firstNameField = '',
    this.lastNameField = '',
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'submitForm';
  @override
  String get type => typeName;

  final FormService service;

  /// Node ids of the text fields read.
  final String emailField, firstNameField, lastNameField;
  final String apiKey, dataCenter, listId;

  static SubmitFormAction _fromJson(Json m, _Common c) => SubmitFormAction(
    service: _e(FormService.values, m, 'service', FormService.mailchimp),
    emailField: _s(m, 'emailField'),
    apiKey: _s(m, 'apiKey'),
    dataCenter: _s(m, 'dataCenter'),
    listId: _s(m, 'listId'),
    firstNameField: _s(m, 'firstNameField'),
    lastNameField: _s(m, 'lastNameField'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'service': service.name,
    'emailField': emailField,
    if (apiKey.isNotEmpty) 'apiKey': apiKey,
    if (dataCenter.isNotEmpty) 'dataCenter': dataCenter,
    if (listId.isNotEmpty) 'listId': listId,
    if (firstNameField.isNotEmpty) 'firstNameField': firstNameField,
    if (lastNameField.isNotEmpty) 'lastNameField': lastNameField,
  };
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
final class SetValueAction extends ActionDef {
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
final class SetVariantAction extends ActionDef {
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
final class SetVariableAction extends ActionDef {
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

  static SetVariableAction _fromJson(Json m, _Common c) => SetVariableAction(
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

/// What an [AnimateVariableAction] does.
enum AnimateVariableMode {
  /// Animates from [AnimateVariableAction.from] (empty: the current value)
  /// to [AnimateVariableAction.to], restarting one already running.
  play,

  /// Holds the running animation where it is.
  pause,

  /// Goes on with a paused animation.
  resume,

  /// Ends the animation, leaving the variable where it is.
  stop,

  /// Sets the variable to [AnimateVariableAction.to]; its timeline goes
  /// on from there (or stays paused there).
  seek,
}

/// Animates number variable [variable] over time: plays it from [from] to
/// [to] over [durationMs] (or [duration], an expression giving
/// milliseconds) along [curve], or pauses, resumes, stops or seeks the
/// animation it runs. A play (or a resume) completes when its timeline
/// ends: make it non-blocking to go on at once. Resume with nothing paused
/// plays from where the value is.
final class AnimateVariableAction extends ActionDef {
  const AnimateVariableAction({
    this.variable = '',
    this.mode = AnimateVariableMode.play,
    this.from = '',
    this.to = '1',
    this.durationMs = 1000,
    this.duration = '',
    this.curve = AnimationCurve.linear,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'animateVariable';
  @override
  String get type => typeName;

  final String variable;
  final AnimateVariableMode mode;

  /// Expressions: where play starts (empty: the variable's value now) and
  /// ends; for seek, [to] is the value to jump to.
  final String from, to;
  final int durationMs;

  /// An expression giving milliseconds, over [durationMs] when it gives a
  /// number.
  final String duration;
  final AnimationCurve curve;

  static AnimateVariableAction _fromJson(Json m, _Common c) => AnimateVariableAction(
    variable: _s(m, 'variable'),
    mode: _e(AnimateVariableMode.values, m, 'mode', AnimateVariableMode.play),
    from: _s(m, 'from'),
    to: _s(m, 'to', '1'),
    durationMs: _i(m, 'durationMs', 1000),
    duration: _s(m, 'duration'),
    curve: _curve(m, 'curve', AnimationCurve.linear),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'variable': variable,
    if (mode != AnimateVariableMode.play) 'mode': mode.name,
    if (from.isNotEmpty) 'from': from,
    if (to != '1') 'to': to,
    if (durationMs != 1000) 'durationMs': durationMs,
    if (duration.isNotEmpty) 'duration': duration,
    if (curve != AnimationCurve.linear) 'curve': curve.name,
  };
}

/// Calls a function the app registered by [name] with [params] (text
/// values are expressions). Its result is the chain's `${result}`.
final class CallFunctionAction extends ActionDef {
  const CallFunctionAction({this.name = '', this.params = const {}, super.enabled, super.nonBlocking, super.when});

  static const typeName = 'callFunction';
  @override
  String get type => typeName;

  final String name;
  final Json params;

  static CallFunctionAction _fromJson(Json m, _Common c) => CallFunctionAction(
    name: _s(m, 'name'),
    params: _map(m, 'params'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {'name': name, if (params.isNotEmpty) 'params': params};
}

/// Calls API [api] (the publish model's `services.apis`) with [params], its
/// inputs (expressions; an empty one takes the input's default). Then
/// [onSuccess] runs after a 2xx response, [onError] after any other or a
/// failed request, both reading the response as `${result}`. A failed
/// request without [onError] stops the chain.
final class CallApiAction extends ActionDef {
  const CallApiAction({
    this.api = '',
    this.params = const {},
    this.onSuccess = const [],
    this.onError = const [],
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'callApi';
  @override
  String get type => typeName;

  final String api;
  final Map<String, String> params;
  final List<ActionDef> onSuccess, onError;

  @override
  List<ActionDef> get nested => [...onSuccess, ...onError];

  static CallApiAction _fromJson(Json m, _Common c) => CallApiAction(
    api: _s(m, 'api'),
    params: {
      for (final e in _map(m, 'params').entries) e.key: e.value is String ? e.value as String : '${e.value ?? ''}',
    },
    onSuccess: _list(m, 'onSuccess'),
    onError: _list(m, 'onError'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'api': api,
    if (params.isNotEmpty) 'params': params,
    if (onSuccess.isNotEmpty) 'onSuccess': _actionsJson(onSuccess),
    if (onError.isNotEmpty) 'onError': _actionsJson(onError),
  };
}

/// What a [SetStorageAction] does.
enum StorageOperation {
  /// Writes key [SetStorageAction.key] ([SetStorageAction.write]).
  write,

  /// Removes the key.
  remove,

  /// Removes every key.
  clear,
}

/// Changes the app's values on the device (read as `${storage.<key>}`). A
/// key may be a path (`prefs.theme`) into a stored map or list.
final class SetStorageAction extends ActionDef {
  const SetStorageAction({
    this.operation = StorageOperation.write,
    this.key = '',
    this.valueType = VariableType.text,
    this.write = const ValueWrite(),
    this.skipIfExists = false,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'setStorage';
  @override
  String get type => typeName;

  final StorageOperation operation;
  final String key;

  /// How the written value is read.
  final VariableType valueType;
  final ValueWrite write;

  /// Leaves a key that has a value.
  final bool skipIfExists;

  static SetStorageAction _fromJson(Json m, _Common c) => SetStorageAction(
    operation: _e(StorageOperation.values, m, 'operation', StorageOperation.write),
    key: _s(m, 'key'),
    valueType: _e(VariableType.values, m, 'valueType', VariableType.text),
    write: ValueWrite.fromJson(m),
    skipIfExists: _b(m, 'skipIfExists', false),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    if (operation != StorageOperation.write) 'operation': operation.name,
    if (operation != StorageOperation.clear) 'key': key,
    if (operation == StorageOperation.write) ...{
      if (valueType != VariableType.text) 'valueType': valueType.name,
      ...write.toJson(),
      if (skipIfExists) 'skipIfExists': true,
    },
  };
}

// --- cloud data ------------------------------------------------------------------

/// What a [CloudDocumentsAction] writes.
enum CloudDocumentsOperation {
  /// Adds document [CloudDocumentsAction.value] (a JSON object).
  add,

  /// Changes field [CloudDocumentsAction.field] of a document.
  update,

  /// Removes a document.
  remove,

  /// Removes the documents with [CloudDocumentsAction.ids], or those
  /// matching [CloudDocumentsAction.where] (all, without).
  removeMany,

  /// Writes the list of documents [CloudDocumentsAction.value].
  setMany,
}

/// Writes documents of a cloud collection: one at a time by id, or many at
/// once.
final class CloudDocumentsAction extends ActionDef {
  const CloudDocumentsAction({
    this.operation = CloudDocumentsOperation.add,
    this.path = '',
    this.id = '',
    this.autoId = false,
    this.skipIfExists = true,
    this.value = '',
    this.raw = false,
    this.field = '',
    this.valueType = VariableType.text,
    this.write = const ValueWrite(),
    this.ids = '',
    this.where = const [],
    this.idField = 'id',
    this.merge = false,
    this.replaceCollection = false,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'cloudDocuments';
  @override
  String get type => typeName;

  final CloudDocumentsOperation operation;

  /// The collection path (an expression).
  final String path;

  /// The document id (an expression).
  final String id;

  /// [CloudDocumentsOperation.add]: a generated id.
  final bool autoId;
  final bool skipIfExists;

  /// The document ([CloudDocumentsOperation.add]) or list of documents
  /// ([CloudDocumentsOperation.setMany]): an expression, or JSON text.
  final String value;

  /// [value] is taken as written: no expressions.
  final bool raw;

  /// [CloudDocumentsOperation.update]: the field (a path) and how it changes.
  final String field;
  final VariableType valueType;
  final ValueWrite write;

  /// [CloudDocumentsOperation.removeMany]: ids, comma separated or a list
  /// (an expression).
  final String ids;
  final List<WhereFilter> where;
  final String idField;
  final bool merge, replaceCollection;

  static CloudDocumentsAction _fromJson(Json m, _Common c) => CloudDocumentsAction(
    operation: _e(CloudDocumentsOperation.values, m, 'operation', CloudDocumentsOperation.add),
    path: _s(m, 'path'),
    id: _s(m, 'id'),
    autoId: _b(m, 'autoId', false),
    skipIfExists: _b(m, 'skipIfExists', true),
    value: _s(m, 'document'),
    raw: _b(m, 'raw', false),
    field: _s(m, 'field'),
    valueType: _e(VariableType.values, m, 'valueType', VariableType.text),
    write: ValueWrite.fromJson(m),
    ids: _s(m, 'ids'),
    where: [...?readList(m['whereFilters'])?.map(WhereFilter.fromJson).nonNulls],
    idField: _s(m, 'idField', 'id'),
    merge: _b(m, 'merge', false),
    replaceCollection: _b(m, 'replaceCollection', false),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'operation': operation.name,
    'path': path,
    if (id.isNotEmpty) 'id': id,
    if (autoId) 'autoId': true,
    if (operation == CloudDocumentsOperation.add && !skipIfExists) 'skipIfExists': false,
    if (value.isNotEmpty) 'document': value,
    if (raw) 'raw': true,
    if (operation == CloudDocumentsOperation.update) ...{
      'field': field,
      if (valueType != VariableType.text) 'valueType': valueType.name,
      ...write.toJson(),
    },
    if (ids.isNotEmpty) 'ids': ids,
    if (where.isNotEmpty) 'whereFilters': [for (final w in where) w.toJson()],
    if (idField != 'id') 'idField': idField,
    if (merge) 'merge': true,
    if (replaceCollection) 'replaceCollection': true,
  };
}

/// Streams a cloud document, or a collection query's documents, into
/// variable [variable] while the screen shows: `{status: loading|loaded|
/// error, data, ...}`.
final class LoadCloudDataAction extends ActionDef {
  const LoadCloudDataAction({
    this.variable = '',
    this.single = true,
    this.id = '',
    this.query = const CloudQueryDef(),
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'loadCloudData';
  @override
  String get type => typeName;

  final String variable;

  /// One document ([id] of [query]'s collection) or the query's documents.
  final bool single;
  final String id;

  /// The collection ([CloudQueryDef.collectionPath]) and, for a query, its
  /// filters, sorts and limit.
  final CloudQueryDef query;

  static LoadCloudDataAction _fromJson(Json m, _Common c) => LoadCloudDataAction(
    variable: _s(m, 'variable'),
    single: _b(m, 'single', true),
    id: _s(m, 'id'),
    query: CloudQueryDef.fromJson(m['query']),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'variable': variable,
    if (!single) 'single': false,
    if (id.isNotEmpty) 'id': id,
    'query': query.toJson(),
  };
}

/// What a [CloudDataAction] does.
enum CloudDataOperation { create, update, delete, get, query, count, sum, average }

/// How a [CloudFieldWrite] changes its field.
enum CloudFieldOperation { set, increment, arrayAdd, arrayRemove, delete, serverTime }

/// One field a [CloudDataAction] writes: [value] is an expression.
@immutable
final class CloudFieldWrite {
  const CloudFieldWrite(this.field, this.value, {this.operation = CloudFieldOperation.set});

  final String field;
  final String value;
  final CloudFieldOperation operation;

  static CloudFieldWrite? fromJson(Object? json) {
    final m = readMap(json);
    final field = readString(m?['field']);
    if (m == null || field == null) return null;
    return CloudFieldWrite(
      field,
      _s(m, 'value'),
      operation: readEnum(CloudFieldOperation.values, m['operation'], CloudFieldOperation.set),
    );
  }

  Json toJson() => {
    'field': field,
    if (value.isNotEmpty) 'value': value,
    if (operation != CloudFieldOperation.set) 'operation': operation.name,
  };

  @override
  bool operator ==(Object other) =>
      other is CloudFieldWrite && other.field == field && other.value == value && other.operation == operation;

  @override
  int get hashCode => Object.hash(field, value, operation);
}

/// Creates, updates, deletes, reads, queries or aggregates documents of a
/// collection. Its result (the new id, the document, the documents, the
/// number) is the chain's `${result}` and goes in [resultVariable].
final class CloudDataAction extends ActionDef {
  const CloudDataAction({
    this.operation = CloudDataOperation.create,
    this.collection = '',
    this.id = '',
    this.fields = const [],
    this.where = const [],
    this.orderBy = const [],
    this.limit,
    this.aggregateField = '',
    this.loadRelated = const [],
    this.deleteSubcollections = const [],
    this.resultVariable = '',
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'cloudData';
  @override
  String get type => typeName;

  final CloudDataOperation operation;
  final String collection;
  final String id;
  final List<CloudFieldWrite> fields;
  final List<WhereFilter> where;
  final List<OrderBy> orderBy;
  final int? limit;
  final String aggregateField;
  final List<String> loadRelated;
  final List<String> deleteSubcollections;
  final String resultVariable;

  static CloudDataAction _fromJson(Json m, _Common c) => CloudDataAction(
    operation: _e(CloudDataOperation.values, m, 'operation', CloudDataOperation.create),
    collection: _s(m, 'collection'),
    id: _s(m, 'id'),
    fields: [...?readList(m['fields'])?.map(CloudFieldWrite.fromJson).nonNulls],
    where: [...?readList(m['whereFilters'])?.map(WhereFilter.fromJson).nonNulls],
    orderBy: [...?readList(m['orderByFilters'])?.map(OrderBy.fromJson).nonNulls],
    limit: readInt(m['limit']),
    aggregateField: _s(m, 'aggregateField'),
    loadRelated: readStrings(m['loadRelated']),
    deleteSubcollections: readStrings(m['deleteSubcollections']),
    resultVariable: _s(m, 'resultVariable'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'operation': operation.name,
    'collection': collection,
    if (id.isNotEmpty) 'id': id,
    if (fields.isNotEmpty) 'fields': [for (final f in fields) f.toJson()],
    if (where.isNotEmpty) 'whereFilters': [for (final w in where) w.toJson()],
    if (orderBy.isNotEmpty) 'orderByFilters': [for (final o in orderBy) o.toJson()],
    'limit': ?limit,
    if (aggregateField.isNotEmpty) 'aggregateField': aggregateField,
    if (loadRelated.isNotEmpty) 'loadRelated': loadRelated,
    if (deleteSubcollections.isNotEmpty) 'deleteSubcollections': deleteSubcollections,
    if (resultVariable.isNotEmpty) 'resultVariable': resultVariable,
  };
}

/// Several [CloudDataAction] writes at once; in a [transaction], all or
/// none.
final class CloudBatchAction extends ActionDef {
  const CloudBatchAction({
    this.steps = const [],
    this.transaction = false,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'cloudBatch';
  @override
  String get type => typeName;

  final List<CloudDataAction> steps;
  final bool transaction;

  static CloudBatchAction _fromJson(Json m, _Common c) => CloudBatchAction(
    steps: [...ActionDef.listFromJson(m['steps']).whereType<CloudDataAction>()],
    transaction: _b(m, 'transaction', false),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {'steps': _actionsJson(steps), if (transaction) 'transaction': true};
}

/// What a [CloudFilesAction] does.
enum CloudFilesOperation { upload, delete }

/// What files an upload picks.
enum CloudFileKind { image, any }

/// Who can read an uploaded file.
enum CloudFileAccess {
  /// Anyone with its URL.
  public,

  /// Only the user who uploaded it.
  private,
}

/// Uploads files the user picks to (or deletes them from) cloud storage
/// folder [path]; [actions] run with each file (`${result.url}`...).
final class CloudFilesAction extends ActionDef {
  const CloudFilesAction({
    this.operation = CloudFilesOperation.upload,
    this.path = '',
    this.kind = CloudFileKind.image,
    this.allowMultiple = true,
    this.maxSizeMB = 10,
    this.progressVariable = '',
    this.access = CloudFileAccess.public,
    this.actions = const [],
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'cloudFiles';
  @override
  String get type => typeName;

  final CloudFilesOperation operation;
  final String path;
  final CloudFileKind kind;
  final bool allowMultiple;
  final double maxSizeMB;
  final String progressVariable;
  final CloudFileAccess access;
  final List<ActionDef> actions;

  @override
  List<ActionDef> get nested => actions;

  static CloudFilesAction _fromJson(Json m, _Common c) => CloudFilesAction(
    operation: _e(CloudFilesOperation.values, m, 'operation', CloudFilesOperation.upload),
    path: _s(m, 'path'),
    kind: _e(CloudFileKind.values, m, 'kind', CloudFileKind.image),
    allowMultiple: _b(m, 'allowMultiple', true),
    maxSizeMB: _d(m, 'maxSizeMB', 10),
    progressVariable: _s(m, 'progressVariable'),
    access: _e(CloudFileAccess.values, m, 'access', CloudFileAccess.public),
    actions: _list(m, 'actions'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    if (operation != CloudFilesOperation.upload) 'operation': operation.name,
    'path': path,
    if (kind != CloudFileKind.image) 'kind': kind.name,
    if (!allowMultiple) 'allowMultiple': false,
    if (maxSizeMB != 10) 'maxSizeMB': writeDouble(maxSizeMB),
    if (progressVariable.isNotEmpty) 'progressVariable': progressVariable,
    if (access != CloudFileAccess.public) 'access': access.name,
    if (actions.isNotEmpty) 'actions': _actionsJson(actions),
  };
}

// --- auth -------------------------------------------------------------------------

/// What an [AuthAction] does.
enum AuthOperation {
  signIn,
  signUp,
  signOut,
  updateProfile,
  sendPasswordResetEmail,
  sendEmailVerification,
  updatePassword, //
  deleteAccount,
  signInWithGoogle,
  signInWithApple,
  sendSignInLink,
  completeSignInLink,
  updatePhoto,
}

/// Signs app users in, up and out, and manages their account. A failure's
/// message goes in [errorVariable] (and stops the chain).
final class AuthAction extends ActionDef {
  const AuthAction({
    this.operation = AuthOperation.signIn,
    this.email = '',
    this.password = '',
    this.displayName = '',
    this.photoUrl = '',
    this.errorVariable = '',
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'auth';
  @override
  String get type => typeName;

  final AuthOperation operation;
  final String email, password, displayName, photoUrl;
  final String errorVariable;

  static AuthAction _fromJson(Json m, _Common c) => AuthAction(
    operation: _e(AuthOperation.values, m, 'operation', AuthOperation.signIn),
    email: _s(m, 'email'),
    password: _s(m, 'password'),
    displayName: _s(m, 'displayName'),
    photoUrl: _s(m, 'photoUrl'),
    errorVariable: _s(m, 'errorVariable'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'operation': operation.name,
    if (email.isNotEmpty) 'email': email,
    if (password.isNotEmpty) 'password': password,
    if (displayName.isNotEmpty) 'displayName': displayName,
    if (photoUrl.isNotEmpty) 'photoUrl': photoUrl,
    if (errorVariable.isNotEmpty) 'errorVariable': errorVariable,
  };
}

// --- flow ---------------------------------------------------------------------------

/// Runs [then] when [condition] holds, else [orElse]. JSON: `{"type": "if",
/// "condition": {...}, "then": [...], "else": [...]}`.
final class IfAction extends ActionDef {
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
final class ForEachAction extends ActionDef {
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
final class DelayAction extends ActionDef {
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
final class ShowToastAction extends ActionDef {
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
final class ConfirmAction extends ActionDef {
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
final class CopyToClipboardAction extends ActionDef {
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

/// Exports generated UTF-8 text (CSV, JSON, plain text...) as a file.
/// The browser downloads it; native apps show the platform save picker.
/// Cancellation returns `{saved: false}` as the action result.
final class DownloadFileAction extends ActionDef {
  const DownloadFileAction({this.fileName = 'export.txt', this.text = '', this.mimeType = 'text/plain',
    super.enabled, super.nonBlocking, super.when});

  static const typeName = 'downloadFile';
  @override
  String get type => typeName;
  final String fileName, text, mimeType;

  static DownloadFileAction _fromJson(Json m, _Common c) => DownloadFileAction(
    fileName: _s(m, 'fileName', 'export.txt'), text: _s(m, 'text'), mimeType: _s(m, 'mimeType', 'text/plain'),
    enabled: c.enabled, nonBlocking: c.nonBlocking, when: c.when);
  @override
  Json get _fields => {'fileName': fileName, 'text': text, 'mimeType': mimeType};
}

/// Reads [text] aloud, or [stop]s speaking. [rate] and [pitch] are numbers
/// or expressions.
final class SpeakAction extends ActionDef {
  const SpeakAction({
    this.text = '',
    this.language = '',
    this.rate = '1',
    this.pitch = '',
    this.stop = false,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'speak';
  @override
  String get type => typeName;

  final String text, language, rate, pitch;
  final bool stop;

  static SpeakAction _fromJson(Json m, _Common c) => SpeakAction(
    text: _s(m, 'text'),
    language: _s(m, 'language'),
    rate: _s(m, 'rate', '1'),
    pitch: _s(m, 'pitch'),
    stop: _b(m, 'stop', false),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    if (text.isNotEmpty) 'text': text,
    if (language.isNotEmpty) 'language': language,
    if (rate != '1') 'rate': rate,
    if (pitch.isNotEmpty) 'pitch': pitch,
    if (stop) 'stop': true,
  };
}

/// Plays a synthesised [sound] (a voice name), now or [at] a time on the
/// sound clock, or the sound file at [url]. Every field is an expression.
final class PlaySoundAction extends ActionDef {
  const PlaySoundAction({
    this.sound = 'wood',
    this.operation = 'play',
    this.voiceId = '',
    this.frequency = '440',
    this.volume = '1',
    this.pitch = '1',
    this.at = '',
    this.url = '',
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'playSound';
  @override
  String get type => typeName;

  final String sound, volume, pitch, at, url;

  /// `play` is the existing one-shot; `start` sustains a tone until `stop`
  /// with the same voiceId. `stopAll` releases the app's sustained tones.
  final String operation, voiceId, frequency;

  static PlaySoundAction _fromJson(Json m, _Common c) => PlaySoundAction(
    sound: _s(m, 'sound', 'wood'),
    operation: _s(m, 'operation', 'play'),
    voiceId: _s(m, 'voiceId'),
    frequency: _s(m, 'frequency', '440'),
    volume: _s(m, 'volume', '1'),
    pitch: _s(m, 'pitch', '1'),
    at: _s(m, 'at'),
    url: _s(m, 'url'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    if (operation != 'play') 'operation': operation,
    if (voiceId.isNotEmpty) 'voiceId': voiceId,
    if (frequency != '440') 'frequency': frequency,
    if (sound != 'wood') 'sound': sound,
    if (volume != '1') 'volume': volume,
    if (pitch != '1') 'pitch': pitch,
    if (at.isNotEmpty) 'at': at,
    if (url.isNotEmpty) 'url': url,
  };
}

// --- purchases ----------------------------------------------------------------------

/// What a [PaywallAction] does, inside a paywall screen.
enum PaywallOperation { purchase, restore, selectProduct, closePaywall, openLegalLink }

/// A paywall interaction: buy the selected (or [slot]'s) product, restore
/// purchases, select a product, close the paywall, open a legal [url].
final class PaywallAction extends ActionDef {
  const PaywallAction({
    this.operation = PaywallOperation.purchase,
    this.slot,
    this.url,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'paywall';
  @override
  String get type => typeName;

  final PaywallOperation operation;
  final String? slot;
  final String? url;

  static PaywallAction _fromJson(Json m, _Common c) => PaywallAction(
    operation: _e(PaywallOperation.values, m, 'operation', PaywallOperation.purchase),
    slot: _sOrNull(m, 'slot'),
    url: _sOrNull(m, 'url'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {'operation': operation.name, 'slot': ?slot, 'url': ?url};
}

// --- nodes --------------------------------------------------------------------------

/// What an [EditTextAction] does to its text field.
enum EditTextOperation { wrap, toggleList, insert, replaceWord, setText, clear, focus }

/// Edits text field [node]'s text at its cursor: wraps the selection in
/// [before] / [after], toggles a (numbered) list, inserts or sets [text],
/// replaces the word being typed, clears it or focuses it.
final class EditTextAction extends ActionDef {
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
final class FocusAction extends ActionDef {
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

/// What a [ControlDragAction] does to a draggable node. [step] turns a
/// drag track control by [ControlDragAction.steps] of its step, as if
/// dragged there (a dial's nudge buttons and arrow keys).
enum DragCommand { fling, returnFrom, reset, shake, step }

/// Flings, returns, resets or shakes draggable node [node] (a swipe card),
/// or steps a drag track.
final class ControlDragAction extends ActionDef {
  const ControlDragAction({
    this.node = '',
    this.command = DragCommand.fling,
    this.direction = DragDirection.right,
    this.steps = '1',
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'controlDrag';
  @override
  String get type => typeName;

  final String node;
  final DragCommand command;
  final DragDirection direction;

  /// [DragCommand.step]: how many steps to turn, negative toward the
  /// track's start; a number or an expression.
  final String steps;

  static ControlDragAction _fromJson(Json m, _Common c) => ControlDragAction(
    node: _s(m, 'node'),
    command: _e(DragCommand.values, m, 'command', DragCommand.fling),
    direction: _e(DragDirection.values, m, 'direction', DragDirection.right),
    steps: _s(m, 'steps', '1'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'node': node,
    if (command != DragCommand.fling) 'command': command.name,
    if (direction != DragDirection.right) 'direction': direction.name,
    if (steps != '1') 'steps': steps,
  };
}

/// Scrolls node [node] into view: [alignment] 0 puts it at the start of the
/// view, 1 at the end; [offset] moves it further. [axis] limits it to the
/// scroll views along one axis (a map in a sideways window centres a point
/// without scrolling the page under it); null scrolls every one around it.
final class ScrollToAction extends ActionDef {
  const ScrollToAction({
    this.node = '',
    this.durationMs = 400,
    this.curve = 'easeInOut',
    this.alignment = 0,
    this.offset = 0,
    this.axis,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'scrollTo';
  @override
  String get type => typeName;

  final String node;
  final int durationMs;

  /// A `Curves` name.
  final String curve;
  final double alignment, offset;
  final ScrollAxis? axis;

  static ScrollToAction _fromJson(Json m, _Common c) => ScrollToAction(
    node: _s(m, 'node'),
    durationMs: _i(m, 'durationMs', 400),
    curve: _s(m, 'curve', 'easeInOut'),
    alignment: _d(m, 'alignment', 0),
    offset: _d(m, 'offset', 0),
    axis: _axis(m['axis']),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {
    'node': node,
    if (durationMs != 400) 'durationMs': durationMs,
    if (curve != 'easeInOut') 'curve': curve,
    if (alignment != 0) 'alignment': writeDouble(alignment),
    if (offset != 0) 'offset': writeDouble(offset),
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

/// Plays node [node]'s one-shot animation (or particles) named [animation].
final class PlayAnimationAction extends ActionDef {
  const PlayAnimationAction({this.node = '', this.animation = '', super.enabled, super.nonBlocking, super.when});

  static const typeName = 'playAnimation';
  @override
  String get type => typeName;

  final String node, animation;

  static PlayAnimationAction _fromJson(Json m, _Common c) => PlayAnimationAction(
    node: _s(m, 'node'),
    animation: _s(m, 'animation'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get _fields => {'node': node, if (animation.isNotEmpty) 'animation': animation};
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
final class HapticAction extends ActionDef {
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
final class RunScriptAction extends ActionDef {
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

  static RunScriptAction _fromJson(Json m, _Common c) => RunScriptAction(
    script: _s(m, 'script'),
    arguments: {
      for (final e in _map(m, 'arguments').entries)
        if (e.value != null) e.key: e.value is String ? e.value as String : '${e.value}',
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
final class PaginateAction extends ActionDef {
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
