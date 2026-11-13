// Reactions as declared fields, for generated editors (the editor's
// properties panel): a trigger's fields, the fields every action has, and
// each action type's own fields, under their JSON keys, with the defaults
// their classes omit from the JSON (actions.dart, triggers.dart).
//
// An action's JSON is `{"type": type, ...its fields, "enabled", "nonBlocking",
// "when"}` (ActionDef.toJson); an editor reads the fields listed here off it
// and writes them back, keeping keys it doesn't list.
import 'actions.dart';
import 'behavior_fields.dart' show AnimationCurveCodec, poseType, springType;
import 'behaviors.dart' show AnimationCurve, DragDirection, Pose, Spring;
import 'json.dart' show readMap;
import 'custom_paint.dart' show Expr;
import 'custom_paint_fields.dart' show ExprCodec;
import 'props.dart';
import 'route_transition.dart';
import 'scripts.dart';
import 'triggers.dart';
import 'values/color.dart';

/// The fields every action has.
abstract final class ActionCommonFields {
  static const enabled = PropDef<bool>('enabled', Codecs.bool, true, doc: 'False skips the action.');
  static const nonBlocking = PropDef<bool>('nonBlocking', Codecs.bool, false,
      doc: 'The chain doesn\'t wait for it, and its failure doesn\'t stop the chain.');

  /// A predicate (conditions.dart); null: always.
  static const when = PropDef<Object?>('when', Codecs.any, null, doc: 'Runs only when it holds.');
  static const List<PropDef<Object?>> all = [enabled, nonBlocking, when];
}

/// A reaction's trigger (`Trigger`, its JSON keys).
abstract final class TriggerFields {
  static const type = PropDef<TriggerType>('type', EnumCodec(TriggerType.values), TriggerType.click);
  static const debounceMs = PropDef<int>('debounceMs', Codecs.int, 0);
  static const variable = PropDef<String>('variable', Codecs.string, '');
  static const intervalMs = PropDef<Expr<int>>('intervalMs', ExprCodec(Codecs.int), Expr(1000),
      doc: 'Timer: ms between ticks (a number or an expression).');
  static const key = PropDef<String>('key', Codecs.string, '');
  static const when = PropDef<String>('when', Codecs.string, '');
  static const holdMs = PropDef<int>('holdMs', Codecs.int, kDefaultHoldMs);
  static const visibleFraction = PropDef<double>('visibleFraction', Codecs.double, kDefaultVisibleFraction);
  static const repeat = PropDef<bool>('repeat', Codecs.bool, false, doc: 'keyDown: also while the key repeats.');
  static const visibleMs = PropDef<int>('visibleMs', IntCodec(min: 0), 0,
      doc: 'Viewport: how long it stays in view before firing (ms).');
  static const onceKey = PropDef<String>('onceKey', Codecs.string, '',
      doc: 'Runs once per key (an expression, such as \${item.id}) per app session.');
  static const List<PropDef<Object?>> all = [
    type, debounceMs, variable, intervalMs, key, when, holdMs, visibleFraction, repeat, //
    visibleMs, onceKey,
  ];
}

Object? _out(Object? v) => v == null ? null : (v as dynamic).toJson();
const _curve = AnimationCurveCodec();

// --- route transitions ----------------------------------------------------------

const routeTransitionType = PropType.object('RouteTransition', routeTransitionFields);
const transitionSideType = PropType.object('TransitionSide', transitionSideFields);
const transitionRevealType = PropType.object('TransitionReveal', transitionRevealFields);
const routeDismissType = PropType.object('RouteDismiss', routeDismissFields);

/// [RouteTransition]; a bare preset name reads as that preset.
const routeTransitionCodec = ValueCodec<RouteTransition?>(RouteTransition.fromJson, _out, routeTransitionType);

abstract final class RouteTransitionFields {
  static const preset = PropDef<RouteTransitionPreset?>('preset', OptionalEnumCodec(RouteTransitionPreset.values), null,
      doc: 'A ready-made transition; the sides given override its own.');
  static const _side = ValueCodec<TransitionSide?>(TransitionSide.fromJson, _out, transitionSideType);
  static const enter = PropDef<TransitionSide?>('enter', _side, null, doc: 'Where the incoming screen starts.');
  static const exit = PropDef<TransitionSide?>('exit', _side, null, doc: 'Where the covered screen ends.');
  static const popEnter = PropDef<TransitionSide?>('popEnter', _side, null, doc: 'Null: exit reversed.');
  static const popExit = PropDef<TransitionSide?>('popExit', _side, null, doc: 'Null: enter reversed.');
  static const durationMs = PropDef<int?>('durationMs', Codecs.optionalInt, null, doc: 'Null: the preset\'s (300).');
  static const reverseDurationMs = PropDef<int?>('reverseDurationMs', Codecs.optionalInt, null);
  static const barrierColor = PropDef<Color?>('barrierColor', Codecs.optionalColor, null);
  static const opaque = PropDef<bool?>('opaque', Codecs.optionalBool, null);
  static const swipeBack = PropDef<RouteSwipeBack?>('swipeBack', OptionalEnumCodec(RouteSwipeBack.values), null);
  static const dismiss = PropDef<RouteDismiss?>(
      'dismiss', ValueCodec<RouteDismiss?>(RouteDismiss.fromJson, _out, routeDismissType), null,
      doc: 'A drag that closes the screen.');
  static const List<PropDef<Object?>> all = [
    preset, enter, exit, popEnter, popExit, durationMs, reverseDurationMs, barrierColor, opaque, swipeBack, dismiss, //
  ];
}

List<PropDef<Object?>> routeTransitionFields() => RouteTransitionFields.all;

abstract final class TransitionSideFields {
  static const motion = PropDef<Pose>('motion', ValueCodec<Pose>(_poseIn, _out, poseType), Pose.none,
      doc: 'The values it moves from (entering) or to (leaving).');
  static const reveal = PropDef<TransitionReveal?>(
      'reveal', ValueCodec<TransitionReveal?>(TransitionReveal.fromJson, _out, transitionRevealType), null);
  static const curve = PropDef<AnimationCurve>('curve', _curve, AnimationCurve.fastOutSlowIn);
  static const delayMs = PropDef<int>('delayMs', IntCodec(min: 0), 0);
  static const durationMs = PropDef<int?>('durationMs', Codecs.optionalInt, null, doc: 'Null: to the end.');
  static const List<PropDef<Object?>> all = [motion, reveal, curve, delayMs, durationMs];
}

Pose? _poseIn(Object? j) => readMap(j) == null ? null : Pose.fromJson(j);

List<PropDef<Object?>> transitionSideFields() => TransitionSideFields.all;

abstract final class TransitionRevealFields {
  static const shape = PropDef<RevealShape>('shape', EnumCodec(RevealShape.values), RevealShape.circle);
  static const origin = PropDef<RevealOrigin>('origin', EnumCodec(RevealOrigin.values), RevealOrigin.tap);
  static const x = PropDef<double>('x', Codecs.double, 0);
  static const y = PropDef<double>('y', Codecs.double, 0);
  static const startRadius = PropDef<double>('startRadius', Codecs.double, 0);
  static const List<PropDef<Object?>> all = [shape, origin, x, y, startRadius];
}

List<PropDef<Object?>> transitionRevealFields() => TransitionRevealFields.all;

abstract final class RouteDismissFields {
  static const direction = PropDef<DragDirection>('direction', EnumCodec(DragDirection.values), DragDirection.down);
  static const distance = PropDef<double>('distance', Codecs.double, 0.25);
  static const velocity = PropDef<double>('velocity', Codecs.double, 700);
  static const spring = PropDef<Spring>('spring', ValueCodec<Spring>(_dismissSpringIn, _dismissSpringOut, springType), RouteDismiss.defaultSpring);
  static const List<PropDef<Object?>> all = [direction, distance, velocity, spring];
}

List<PropDef<Object?>> routeDismissFields() => RouteDismissFields.all;

Spring? _dismissSpringIn(Object? j) => Spring.fromJson(j, fallback: RouteDismiss.defaultSpring);
Object? _dismissSpringOut(Spring s) => s.toJsonOver(RouteDismiss.defaultSpring);


// --- scripts ----------------------------------------------------------------------

const scriptType = PropType.object('ScriptDef', scriptFields);

/// [ScriptDef] (a layout's `scripts`).
abstract final class ScriptFields {
  static const id = PropDef<String>('id', Codecs.string, '');
  static const name = PropDef<String>('name', Codecs.string, '', doc: 'A JavaScript identifier: script.<name>(...).');
  static const description = PropDef<String>('description', Codecs.string, '');
  static const params = PropDef<Object?>('params', Codecs.any, null, doc: '[{"name", "description", "defaultValue"}].');
  static const source = PropDef<String>('source', Codecs.string, '', doc: 'JavaScript.');
  static const version = PropDef<int>('version', Codecs.int, 1);
  static const capabilities = PropDef<List<String>>('capabilities', Codecs.strings, [],
      doc: 'What it may do: variables.read, variables.write, nodes.read, navigation, api, cloud, actions, clock.');
  static const timeoutMs = PropDef<int>('timeoutMs', IntCodec(min: 1), ScriptDef.defaultTimeoutMs);
  static const memoryLimitMb = PropDef<int>('memoryLimitMb', IntCodec(min: 1), ScriptDef.defaultMemoryLimitMb);
  static const pageId = PropDef<String?>('pageId', Codecs.optionalString, null, doc: 'Null: a project script.');
  static const tests = PropDef<Object?>('tests', Codecs.any, null,
      doc: 'Sample runs: [{"name", "args", "vars", "nodes", "expect", "expectError"}].');
  static const List<PropDef<Object?>> all = [
    id, name, description, params, source, version, capabilities, timeoutMs, memoryLimitMb, pageId, tests, //
  ];
}

List<PropDef<Object?>> scriptFields() => ScriptFields.all;

/// [NavigateAction].
abstract final class NavigateFields {
  static const mode = PropDef<NavigationMode>('mode', EnumCodec(NavigationMode.values), NavigationMode.push);
  static const to = PropDef<String>('to', Codecs.string, '', doc: 'A screen (canvas) or layout id.');
  static const params = PropDef<Object?>('params', Codecs.any, null, doc: 'Values the destination reads as \${route.<name>}.');
  static const base = PropDef<String>('base', Codecs.string, '');
  static const baseParams = PropDef<Object?>('baseParams', Codecs.any, null);
  static const transition = PropDef<PageTransition>('transition', EnumCodec(PageTransition.values), PageTransition.platform);
  static const transitionMs = PropDef<int?>('transitionMs', Codecs.optionalInt, null);
  static const reverseTransitionMs = PropDef<int?>('reverseTransitionMs', Codecs.optionalInt, null);
  static const routeTransition = PropDef<RouteTransition?>('routeTransition', routeTransitionCodec, null,
      doc: 'A custom transition; replaces transition and its times.');
  static const List<PropDef<Object?>> all = [
    mode, to, params, base, baseParams, transition, transitionMs, reverseTransitionMs, routeTransition, //
  ];
}

/// The [ValueWrite] keys, stored flat in [SetVariableAction],
/// [SetStorageAction] and [CloudDocumentsAction] JSON.
abstract final class ValueWriteFields {
  static const op = PropDef<WriteOp>('op', EnumCodec(WriteOp.values), WriteOp.set, doc: 'How the value changes.');
  static const value = PropDef<String>('value', Codecs.string, '', doc: 'The value (an expression); not for toggle, removeAt.');
  static const index = PropDef<String>('index', Codecs.string, '', doc: 'A list index (an expression).');
  static const mapKey = PropDef<String>('mapKey', Codecs.string, '', doc: 'A map key (an expression).');
  static const List<PropDef<Object?>> all = [op, value, index, mapKey];
}

/// [OpenModalAction].
abstract final class OpenModalFields {
  static const to = PropDef<String>('to', Codecs.string, '', doc: 'The screen (canvas) shown.');
  static const params = PropDef<Object?>('params', Codecs.any, null, doc: 'Values the modal reads as \${route.<name>}.');
  static const presentation =
      PropDef<ModalPresentation>('presentation', EnumCodec(ModalPresentation.values), ModalPresentation.dialog);
  static const barrierDismissible = PropDef<bool>('barrierDismissible', Codecs.bool, true);
  static const barrierColor = PropDef<Color?>('barrierColor', Codecs.optionalColor, null, doc: 'Null: the default scrim.');
  static const barrierBlur = PropDef<double>('barrierBlur', Codecs.double, 0);
  static const showCloseButton = PropDef<bool>('showCloseButton', Codecs.bool, false);
  static const showDragHandle = PropDef<bool>('showDragHandle', Codecs.bool, false);
  static const alignment = PropDef<List<double>>('alignment', Codecs.doubles, [0, 0], doc: 'A dialog\'s alignment, [x, y] (-1 to 1).');
  static const anchor = PropDef<ModalAnchor>('anchor', EnumCodec(ModalAnchor.values), ModalAnchor.none);
  static const placement = PropDef<PopoverPlacement>('placement', EnumCodec(PopoverPlacement.values), PopoverPlacement.belowStart);
  static const anchorGap = PropDef<double>('anchorGap', Codecs.double, 4);
  static const anchorOffset = PropDef<double>('anchorOffset', Codecs.double, 0);
  static const anchorReserve = PropDef<double>('anchorReserve', Codecs.double, 0,
      doc: 'Room a popover keeps below its top: when its top plus this would pass the screen\'s bottom margin, it moves up to fit it (a menu keeps its place as it grows). 0: by its own height.');
  static const anchorNode = PropDef<String>('anchorNode', Codecs.string, '',
      doc: 'Anchor "node": the node the popover sits by (an id; may be an expression).');
  static const anchorItem = PropDef<String>('anchorItem', Codecs.string, '',
      doc: 'Anchor "node", for a node a list repeats: the item whose copy it sits by (its id or key, or its index).');
  static const insets = PropDef<List<double>>('insets', Codecs.doubles, [0, 0, 0, 0],
      doc: 'Space kept around a dialog: left, top, right, bottom.');
  static const sheetWidth = PropDef<double?>('sheetWidth', Codecs.optionalDouble, null);
  static const sheetRadius = PropDef<double?>('sheetRadius', Codecs.optionalDouble, null,
      doc: 'A bottom sheet\'s top corner radius; the sheet clips the screen to it (null: the default).');
  static const sheetBelow = PropDef<String>('sheetBelow', Codecs.string, '',
      doc: 'Adaptive: a bottom sheet on breakpoints narrower than this one (a breakpoint id; empty: the second).');
  static const maxHeightFactor = PropDef<double>('maxHeightFactor', Codecs.double, 1);
  static const fullHeight = PropDef<bool>('fullHeight', Codecs.bool, false);
  static const cover = PropDef<bool>('cover', Codecs.bool, false,
      doc: 'A dialog that covers the screen: its screen fills it at the device size (its breakpoint follows the device).');
  static const enterScale = PropDef<double>('enterScale', Codecs.double, 1);
  static const routeTransition = PropDef<RouteTransition?>('routeTransition', routeTransitionCodec, null,
      doc: 'A custom transition: entrance, the screen behind, barrier, drag to dismiss.');
  static const List<PropDef<Object?>> all = [
    to, params, presentation, barrierDismissible, barrierColor, barrierBlur, showCloseButton, showDragHandle, //
    alignment, anchor, placement, anchorGap, anchorOffset, anchorReserve, anchorNode, anchorItem, insets, sheetWidth, sheetRadius, sheetBelow, maxHeightFactor,
    fullHeight, cover, enterScale, routeTransition,
  ];
}

/// [CloseModalAction].
abstract final class CloseModalFields {
  static const result = PropDef<Object?>('result', Codecs.any, null,
      doc: 'What the opening chain reads as \${result}; text values are expressions.');
  static const List<PropDef<Object?>> all = [result];
}

/// [OpenLinkAction].
abstract final class OpenLinkFields {
  static const url = PropDef<String>('url', Codecs.string, '', doc: 'A web page, mailto:, tel: or app link.');
  static const List<PropDef<Object?>> all = [url];
}

/// [SetValueAction].
abstract final class SetValueFields {
  static const node = PropDef<String>('node', Codecs.string, '');
  static const values = PropDef<Object?>('values', Codecs.any, null,
      doc: 'The properties set: [{"path", "value" | "mode"}].');
  static const List<PropDef<Object?>> all = [node, values];
}

/// [SetVariantAction].
abstract final class SetVariantFields {
  static const node = PropDef<String>('node', Codecs.string, '', doc: 'A variance node.');
  static const variant = PropDef<String>('variant', Codecs.string, '', doc: 'The variant\'s id (an expression).');
  static const List<PropDef<Object?>> all = [node, variant];
}

/// [SetVariableAction].
abstract final class SetVariableFields {
  static const variable = PropDef<String>('variable', Codecs.string, '',
      doc: 'The variable\'s name; a path into it sets that part.');
  static const animateMs = PropDef<String>('animateMs', Codecs.string, '',
      doc: 'A number: glide to the new value over these milliseconds (an expression).');
  static const curve = PropDef<AnimationCurve>('curve', _curve, AnimationCurve.linear, doc: 'The glide\'s easing.');
  static const List<PropDef<Object?>> all = [variable, ...ValueWriteFields.all, animateMs, curve];
}

/// [CallFunctionAction].
abstract final class CallFunctionFields {
  static const name = PropDef<String>('name', Codecs.string, '', doc: 'The function the app registered.');
  static const params = PropDef<Object?>('params', Codecs.any, null, doc: 'Its arguments; text values are expressions.');
  static const optional = PropDef<bool>('optional', Codecs.bool, false,
      doc: 'A function the app didn\'t register is skipped (\${result} is null) instead of failing the chain.');
  static const List<PropDef<Object?>> all = [name, params, optional];
}

/// [IfAction].
abstract final class IfFields {
  static const condition = PropDef<Object?>('condition', Codecs.any, null, doc: 'A predicate; null never holds.');
  static const then = PropDef<Object?>('then', Codecs.any, null, doc: 'Nested actions: run when it holds.');
  static const orElse = PropDef<Object?>('else', Codecs.any, null, doc: 'Nested actions: run when it doesn\'t.');
  static const List<PropDef<Object?>> all = [condition, then, orElse];
}

/// [ForEachAction].
abstract final class ForEachFields {
  static const items = PropDef<String>('items', Codecs.string, '', doc: 'A list (a path or expression).');
  static const actions = PropDef<Object?>('actions', Codecs.any, null,
      doc: 'Nested actions: run per item (\${loop.item}, \${loop.index}).');
  static const List<PropDef<Object?>> all = [items, actions];
}

/// [ShowToastAction].
abstract final class ShowToastFields {
  static const message = PropDef<String>('message', Codecs.string, '', doc: 'An expression.');
  static const title = PropDef<String>('title', Codecs.string, '');
  static const durationMs = PropDef<int>('durationMs', Codecs.int, 2600);
  static const style = PropDef<ToastStyle>('style', EnumCodec(ToastStyle.values), ToastStyle.neutral);
  static const position = PropDef<ToastPosition>('position', EnumCodec(ToastPosition.values), ToastPosition.bottom);
  static const actionLabel = PropDef<String>('actionLabel', Codecs.string, '', doc: 'Its button.');
  static const actions = PropDef<Object?>('actions', Codecs.any, null, doc: 'Nested actions: run by its button.');
  static const showClose = PropDef<bool>('showClose', Codecs.bool, false);
  static const icon = PropDef<Object?>('icon', Codecs.any, null, doc: 'An icon glyph\'s JSON.');
  static const look = PropDef<Object?>('look', Codecs.any, null,
      doc: 'Cosmetics, JSON: colors, radius, border, shadows, padding, widths, text styles, offsets, alignment; '
          'the button\'s actionBackgroundColor, actionBorder, actionCornerRadius, actionShadows; iconShadows; '
          'rotation (degrees), enterCurve, enterOffset (a share of its height).');
  static const variables = PropDef<Object?>('variables', Codecs.any, null, doc: 'Style values bound to expressions, by style key.');
  static const List<PropDef<Object?>> all = [
    message, title, durationMs, style, position, actionLabel, actions, showClose, icon, look, variables, //
  ];
}

/// [ConfirmAction].
abstract final class ConfirmFields {
  static const title = PropDef<String>('title', Codecs.string, '');
  static const message = PropDef<String>('message', Codecs.string, '');
  static const caption = PropDef<String>('caption', Codecs.string, '');
  static const confirmLabel = PropDef<String>('confirmLabel', Codecs.string, 'OK');
  static const cancelLabel = PropDef<String>('cancelLabel', Codecs.string, 'Cancel');
  static const destructive = PropDef<bool>('destructive', Codecs.bool, false);
  static const actions = PropDef<Object?>('actions', Codecs.any, null, doc: 'Nested actions: run when confirmed.');
  static const cancelActions = PropDef<Object?>('cancelActions', Codecs.any, null, doc: 'Nested actions: run when canceled.');
  static const dialog = PropDef<String>('dialog', Codecs.string, '', doc: 'A screen id to show as the dialog.');
  static const params = PropDef<Object?>('params', Codecs.any, null);
  static const presentation =
      PropDef<ModalPresentation>('presentation', EnumCodec(ModalPresentation.values), ModalPresentation.dialog);
  static const placement = PropDef<PopoverPlacement>('placement', EnumCodec(PopoverPlacement.values), PopoverPlacement.belowStart);
  static const barrierDismissible = PropDef<bool>('barrierDismissible', Codecs.bool, true);
  static const look = PropDef<Object?>('look', Codecs.any, null,
      doc: 'Cosmetics, JSON: colors, radius, border, shadows, text styles, button radius/border/shadows; '
          'confirmBorder, cancelBorder, buttonHeight, expandButtons; icon, iconSize, iconColor, iconDiscColor, '
          'iconDiscSize, iconDiscBorder; centered, width, maxWidth, insets, padding.');
  static const variables = PropDef<Object?>('variables', Codecs.any, null, doc: 'Style values bound to expressions, by style key.');
  static const List<PropDef<Object?>> all = [
    title, message, caption, confirmLabel, cancelLabel, destructive, actions, cancelActions, dialog, params, //
    presentation, placement, barrierDismissible, look, variables,
  ];
}

/// [DelayAction].
abstract final class DelayFields {
  static const ms = PropDef<int>('ms', Codecs.int, 500);
  static const duration = PropDef<String>('duration', Codecs.string, '', doc: 'A formula giving milliseconds.');
  static const List<PropDef<Object?>> all = [ms, duration];
}

/// [CopyToClipboardAction].
abstract final class CopyToClipboardFields {
  static const text = PropDef<String>('text', Codecs.string, '', doc: 'An expression.');
  static const List<PropDef<Object?>> all = [text];
}

/// [EditTextAction].
abstract final class EditTextFields {
  static const node = PropDef<String>('node', Codecs.string, '', doc: 'A text field.');
  static const operation = PropDef<EditTextOperation>('operation', EnumCodec(EditTextOperation.values), EditTextOperation.insert);
  static const text = PropDef<String>('text', Codecs.string, '');
  static const before = PropDef<String>('before', Codecs.string, '');
  static const after = PropDef<String?>('after', Codecs.optionalString, null, doc: 'Null: the same as before.');
  static const numbered = PropDef<bool>('numbered', Codecs.bool, false);
  static const List<PropDef<Object?>> all = [node, operation, text, before, after, numbered];
}

/// [FocusAction].
abstract final class FocusFields {
  static const node = PropDef<String>('node', Codecs.string, '', doc: 'A text field; empty with unfocus: every field.');
  static const unfocus = PropDef<bool>('unfocus', Codecs.bool, false);
  static const selectAll = PropDef<bool>('selectAll', Codecs.bool, false);
  static const List<PropDef<Object?>> all = [node, unfocus, selectAll];
}

/// [ControlDragAction].
abstract final class ControlDragFields {
  static const node = PropDef<String>('node', Codecs.string, '', doc: 'A draggable node.');
  static const command = PropDef<DragCommand>('command', EnumCodec(DragCommand.values), DragCommand.fling);
  static const direction = PropDef<DragDirection>('direction', EnumCodec(DragDirection.values), DragDirection.right);
  static const steps = PropDef<String>('steps', Codecs.string, '1', doc: 'Step: how many steps (an expression).');
  static const value = PropDef<String>('value', Codecs.string, '',
      doc: 'Zoom: the factor (1.5 in, 0.67 out). Pose: {x, y, scale, rotation} (an expression).');
  static const List<PropDef<Object?>> all = [node, command, direction, steps, value];
}

/// [ScrollToAction].
abstract final class ScrollToFields {
  static const node = PropDef<String>('node', Codecs.string, '');
  static const item = PropDef<String>('item', Codecs.string, '',
      doc: 'For a repeated node: the key (or index) of the list item whose copy to reveal.');
  static const durationMs = PropDef<int>('durationMs', Codecs.int, 400);
  static const curve = PropDef<String>('curve', Codecs.string, 'easeInOut', doc: 'A Curves name.');
  static const alignment = PropDef<double>('alignment', Codecs.double, 0, doc: '0: at the start of the view, 1: at the end.');
  static const offset = PropDef<double>('offset', Codecs.double, 0);
  static const axis = PropDef<ScrollAxis?>('axis', OptionalEnumCodec(ScrollAxis.values), null,
      doc: 'Only the scroll views along this axis; null: every one.');
  static const List<PropDef<Object?>> all = [node, item, durationMs, curve, alignment, offset, axis];
}

/// [AnimateAction]: an `AnimationController` method on a node's animation
/// or a number variable.
abstract final class AnimateFields {
  static const node = PropDef<String>('node', Codecs.string, '', doc: 'A node id or key; empty: the reacting node.');
  static const animation = PropDef<String>('animation', Codecs.string, '', doc: "The animation's id on the node.");
  static const variable = PropDef<String>('variable', Codecs.string, '', doc: 'Instead of a node: a number variable.');
  static const command = PropDef<AnimateCommand>('command', EnumCodec(AnimateCommand.values), AnimateCommand.forward);
  static const from = PropDef<String>('from', Codecs.string, '', doc: 'Where forward/reverse start (an expression).');
  static const target = PropDef<String>('target', Codecs.string, '', doc: 'animateTo, animateBack, set (an expression).');
  static const duration = PropDef<String>('duration', Codecs.string, '', doc: 'Milliseconds (an expression); empty: the animation\'s.');
  static const curve = PropDef<AnimationCurve?>('curve', OptionalEnumCodec(AnimationCurve.values), null);
  static const spring = PropDef<Spring?>('spring', ValueCodec<Spring?>(Spring.fromJson, _out, springType), null);
  static const List<PropDef<Object?>> all = [node, animation, variable, command, from, target, duration, curve, spring];
}

/// [HapticAction].
abstract final class HapticFields {
  static const kind = PropDef<HapticKind>('kind', EnumCodec(HapticKind.values), HapticKind.selection);
  static const List<PropDef<Object?>> all = [kind];
}

/// [RunScriptAction].
abstract final class RunScriptFields {
  static const script = PropDef<String>('script', Codecs.string, '', doc: 'A script of the layout\'s scripts.');
  static const arguments = PropDef<Object?>('arguments', Codecs.any, null, doc: 'By parameter name (expressions).');
  static const resultVariable = PropDef<String>('resultVariable', Codecs.string, '', doc: 'Gets the result.');
  static const onError = PropDef<Object?>('onError', Codecs.any, null,
      doc: 'Nested actions: run when it fails (\${result.error}, \${result.logs}).');
  static const List<PropDef<Object?>> all = [script, arguments, resultVariable, onError];
}

/// [PaginateAction].
abstract final class PaginateFields {
  static const controller = PropDef<String>('controller', Codecs.string, '', doc: 'The pagination\'s name.');
  static const command = PropDef<PaginateCommand>('command', EnumCodec(PaginateCommand.values), PaginateCommand.next);
  static const page = PropDef<String>('page', Codecs.string, '1', doc: 'For goTo: a number or an expression.');
  static const pageSize = PropDef<String>('pageSize', Codecs.string, '20', doc: 'For setPageSize.');
  static const List<PropDef<Object?>> all = [controller, command, page, pageSize];
}
