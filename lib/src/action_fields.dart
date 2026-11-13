// Reactions as declared fields, for generated editors (the editor's
// properties panel): a trigger's fields, the fields every action has, and
// each action type's own fields, under their JSON keys, with the defaults
// their classes omit from the JSON (actions.dart, triggers.dart).
//
// An action's JSON is `{"type": type, ...its fields, "enabled", "nonBlocking",
// "when"}` (ActionDef.toJson); an editor reads the fields listed here off it
// and writes them back, keeping keys it doesn't list.
import 'actions.dart';
import 'behavior_fields.dart' show AnimationCurveCodec, motionType;
import 'behaviors.dart' show AnimationCurve, DragDirection, Motion;
import 'catalog.dart';
import 'standard_catalog.dart';
import 'json.dart' show readMap, readString;
import 'props.dart';
import 'route_transition.dart';
import 'scripts.dart';
import 'triggers.dart';
import 'values/color.dart';
import 'variables.dart' show VariableType;

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
  static const intervalMs = PropDef<int>('intervalMs', Codecs.int, 1000);
  static const key = PropDef<String>('key', Codecs.string, '');
  static const when = PropDef<String>('when', Codecs.string, '');
  static const holdMs = PropDef<int>('holdMs', Codecs.int, kDefaultHoldMs);
  static const every = PropDef<String>('every', Codecs.string, '');
  static const runWhen = PropDef<String>('runWhen', Codecs.string, '');
  static const visibleFraction = PropDef<double>('visibleFraction', Codecs.double, kDefaultVisibleFraction);
  static const repeat = PropDef<bool>('repeat', Codecs.bool, false, doc: 'keyDown: also while the key repeats.');
  static const visibleMs = PropDef<int>('visibleMs', IntCodec(min: 0), 0,
      doc: 'Viewport: how long it stays in view before firing (ms).');
  static const onceKey = PropDef<String>('onceKey', Codecs.string, '',
      doc: 'Runs once per key (an expression, such as \${item.id}) per app session.');
  static const List<PropDef<Object?>> all = [
    type, debounceMs, variable, intervalMs, key, when, holdMs, every, runWhen, visibleFraction, repeat, //
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
const transitionSpringType = PropType.object('TransitionSpring', transitionSpringFields);

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
  static const motion = PropDef<Motion>('motion', ValueCodec<Motion>(_motionIn, _out, motionType), Motion.none,
      doc: 'The values it moves from (entering) or to (leaving).');
  static const reveal = PropDef<TransitionReveal?>(
      'reveal', ValueCodec<TransitionReveal?>(TransitionReveal.fromJson, _out, transitionRevealType), null);
  static const curve = PropDef<AnimationCurve>('curve', _curve, AnimationCurve.fastOutSlowIn);
  static const delayMs = PropDef<int>('delayMs', IntCodec(min: 0), 0);
  static const durationMs = PropDef<int?>('durationMs', Codecs.optionalInt, null, doc: 'Null: to the end.');
  static const List<PropDef<Object?>> all = [motion, reveal, curve, delayMs, durationMs];
}

Motion? _motionIn(Object? j) => readMap(j) == null ? null : Motion.fromJson(j);

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
  static const spring = PropDef<TransitionSpring>(
      'spring', ValueCodec<TransitionSpring>(TransitionSpring.fromJson, _out, transitionSpringType), TransitionSpring());
  static const List<PropDef<Object?>> all = [direction, distance, velocity, spring];
}

List<PropDef<Object?>> routeDismissFields() => RouteDismissFields.all;

abstract final class TransitionSpringFields {
  static const stiffness = PropDef<double>('stiffness', Codecs.double, 380);
  static const damping = PropDef<double>('damping', Codecs.double, 36);
  static const mass = PropDef<double>('mass', Codecs.double, 1);
  static const List<PropDef<Object?>> all = [stiffness, damping, mass];
}

List<PropDef<Object?>> transitionSpringFields() => TransitionSpringFields.all;

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

/// [PrintAction].
abstract final class PrintFields {
  static const node = PropDef<String>('node', Codecs.string, '', doc: 'A rendered node to print through a user-confirmed platform dialog.');
  static const List<PropDef<Object?>> all = [node];
}

/// [SubmitFormAction].
abstract final class SubmitFormFields {
  /// Only `local` is offered: [FormService.unsupported] marks old data.
  static const service = PropDef<FormService>('service', EnumCodec([FormService.local]), FormService.local);
  static const payload = PropDef<String>('payload', Codecs.string, '', doc: 'An expression yielding a JSON object.');
  static const validationScript = PropDef<String>('validationScript', Codecs.string, '', doc: 'Await a script returning {valid, errors?, payload?}.');
  static const validationArguments = PropDef<Object?>('validationArguments', Codecs.any, null, doc: 'Named script argument expressions.');
  static const responseVariable = PropDef<String>('responseVariable', Codecs.string, '', doc: 'Optional mutable list variable receiving the validated payload. Persist the variable to keep submissions.');
  static const prepend = PropDef<bool>('prepend', Codecs.bool, false);
  static const resultVariable = PropDef<String>('resultVariable', Codecs.string, '');
  static const onSuccess = PropDef<Object?>('onSuccess', Codecs.any, null);
  static const onError = PropDef<Object?>('onError', Codecs.any, null);
  static const List<PropDef<Object?>> all = [service, payload, validationScript, validationArguments, responseVariable,
    prepend, resultVariable, onSuccess, onError];
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

/// [AnimateVariableAction].
abstract final class AnimateVariableFields {
  static const variable = PropDef<String>('variable', Codecs.string, '', doc: 'A number variable.');
  static const mode = PropDef<AnimateVariableMode>('mode', EnumCodec(AnimateVariableMode.values), AnimateVariableMode.play);
  static const from = PropDef<String>('from', Codecs.string, '', doc: 'Play: the start (empty: the value now).');
  static const to = PropDef<String>('to', Codecs.string, '1', doc: 'Play: the end; seek: the value to jump to.');
  static const durationMs = PropDef<int>('durationMs', Codecs.int, 1000);
  static const duration = PropDef<String>('duration', Codecs.string, '', doc: 'An expression giving milliseconds.');
  static const curve = PropDef<AnimationCurve>('curve', _curve, AnimationCurve.linear);
  static const List<PropDef<Object?>> all = [variable, mode, from, to, durationMs, duration, curve];
}

/// [CallFunctionAction].
abstract final class CallFunctionFields {
  static const name = PropDef<String>('name', Codecs.string, '', doc: 'The function the app registered.');
  static const params = PropDef<Object?>('params', Codecs.any, null, doc: 'Its arguments; text values are expressions.');
  static const optional = PropDef<bool>('optional', Codecs.bool, false,
      doc: 'A function the app didn\'t register is skipped (\${result} is null) instead of failing the chain.');
  static const List<PropDef<Object?>> all = [name, params, optional];
}

/// [CallApiAction].
abstract final class CallApiFields {
  static const api = PropDef<String>('api', Codecs.string, '', doc: 'An API of services.apis.');
  static const params = PropDef<Object?>('params', Codecs.any, null, doc: 'Its inputs, by name (expressions).');
  static const onSuccess = PropDef<Object?>('onSuccess', Codecs.any, null, doc: 'Nested actions: run after a 2xx response.');
  static const onError = PropDef<Object?>('onError', Codecs.any, null, doc: 'Nested actions: run after a failure.');
  static const List<PropDef<Object?>> all = [api, params, onSuccess, onError];
}

/// [SetStorageAction].
abstract final class SetStorageFields {
  static const operation = PropDef<StorageOperation>('operation', EnumCodec(StorageOperation.values), StorageOperation.write);
  static const key = PropDef<String>('key', Codecs.string, '', doc: 'The key; may be a path. Not for clear.');
  static const valueType = PropDef<VariableType>('valueType', EnumCodec(VariableType.values), VariableType.text,
      doc: 'How the written value is read (write only).');
  static const skipIfExists = PropDef<bool>('skipIfExists', Codecs.bool, false, doc: 'Leaves a key that has a value.');
  static const List<PropDef<Object?>> all = [operation, key, valueType, ...ValueWriteFields.all, skipIfExists];
}

/// [CloudDocumentsAction].
abstract final class CloudDocumentsFields {
  static const operation = PropDef<CloudDocumentsOperation>(
      'operation', EnumCodec(CloudDocumentsOperation.values), CloudDocumentsOperation.add);
  static const path = PropDef<String>('path', Codecs.string, '', doc: 'The collection path (an expression).');
  static const id = PropDef<String>('id', Codecs.string, '', doc: 'The document id (an expression).');
  static const autoId = PropDef<bool>('autoId', Codecs.bool, false, doc: 'Add: a generated id.');
  static const skipIfExists = PropDef<bool>('skipIfExists', Codecs.bool, true, doc: 'Add only.');
  static const document = PropDef<String>('document', Codecs.string, '',
      doc: 'The document (add) or documents (setMany): an expression, or JSON text.');
  static const raw = PropDef<bool>('raw', Codecs.bool, false, doc: 'The document is taken as written: no expressions.');
  static const field = PropDef<String>('field', Codecs.string, '', doc: 'Update: the field (a path).');
  static const valueType = PropDef<VariableType>('valueType', EnumCodec(VariableType.values), VariableType.text,
      doc: 'Update only.');
  static const ids = PropDef<String>('ids', Codecs.string, '', doc: 'RemoveMany: ids, comma separated or a list.');
  static const whereFilters = PropDef<Object?>('whereFilters', Codecs.any, null, doc: 'RemoveMany: the filters.');
  static const idField = PropDef<String>('idField', Codecs.string, 'id');
  static const merge = PropDef<bool>('merge', Codecs.bool, false);
  static const replaceCollection = PropDef<bool>('replaceCollection', Codecs.bool, false);
  static const List<PropDef<Object?>> all = [
    operation, path, id, autoId, skipIfExists, document, raw, field, valueType, ...ValueWriteFields.all, //
    ids, whereFilters, idField, merge, replaceCollection,
  ];
}

/// [LoadCloudDataAction].
abstract final class LoadCloudDataFields {
  static const variable = PropDef<String>('variable', Codecs.string, '');
  static const single = PropDef<bool>('single', Codecs.bool, true, doc: 'One document, or the query\'s documents.');
  static const id = PropDef<String>('id', Codecs.string, '');
  static const query = PropDef<Object?>('query', Codecs.any, null,
      doc: 'The collection and, for a query, its filters, sorts, limit and joins (a CloudQueryDef).');
  static const scope = PropDef<CloudDataScope>('scope', EnumCodec(CloudDataScope.values), CloudDataScope.screen,
      doc: 'Screen: a subscription per screen, until it goes. App: one subscription the whole app shares, '
          'into an app variable every screen reads.');
  static const limit = PropDef<String>('limit', Codecs.string, '',
      doc: 'The most documents: a number or expression; empty: the query\'s, else $kDefaultCloudLoadLimit; 0: all.');
  static const aggregate = PropDef<CloudLoadAggregate>(
      'aggregate', EnumCodec(CloudLoadAggregate.values), CloudLoadAggregate.none,
      doc: 'A number (count, sum, average) instead of the documents, without loading them.');
  static const aggregateField = PropDef<String>('aggregateField', Codecs.string, '', doc: 'Sum and average: the field.');
  static const refreshSeconds = PropDef<int>('refreshSeconds', IntCodec(min: 0), 0,
      doc: 'Aggregate: also runs again this often (writes made elsewhere); 0: after this app\'s writes only.');
  static const reactive = PropDef<bool>('reactive', Codecs.bool, true,
      doc: 'Runs again when a value its query reads changes (\${auth.uid}, a bound limit).');
  static const List<PropDef<Object?>> all = [
    variable, single, id, query, scope, limit, aggregate, aggregateField, refreshSeconds, reactive, //
  ];
}

/// [ReloadCloudDataAction].
abstract final class ReloadCloudDataFields {
  static const variable = PropDef<String>('variable', Codecs.string, '', doc: 'A variable a load cloud data action fills.');
  static const List<PropDef<Object?>> all = [variable];
}

/// [AuthAction].
abstract final class AuthFields {
  static const operation = PropDef<AuthOperation>('operation', EnumCodec(AuthOperation.values), AuthOperation.signIn);
  static const email = PropDef<String>('email', Codecs.string, '');
  static const password = PropDef<String>('password', Codecs.string, '');
  static const displayName = PropDef<String>('displayName', Codecs.string, '');
  static const photoUrl = PropDef<String>('photoUrl', Codecs.string, '');
  static const currentPassword = PropDef<String>('currentPassword', Codecs.string, '',
      doc: 'Re-authenticates first (change password, delete account).');
  static const errorVariable = PropDef<String>('errorVariable', Codecs.string, '', doc: 'Gets a failure\'s message.');
  static const List<PropDef<Object?>> all = [operation, email, password, displayName, photoUrl, currentPassword, errorVariable];
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

/// [CloudFilesAction].
abstract final class CloudFilesFields {
  static const operation =
      PropDef<CloudFilesOperation>('operation', EnumCodec(CloudFilesOperation.values), CloudFilesOperation.upload);
  static const path = PropDef<String>('path', Codecs.string, '', doc: 'The storage folder.');
  static const kind = PropDef<CloudFileKind>('kind', EnumCodec(CloudFileKind.values), CloudFileKind.image);
  static const allowMultiple = PropDef<bool>('allowMultiple', Codecs.bool, true);
  static const maxSizeMB = PropDef<double>('maxSizeMB', Codecs.double, 10);
  static const progressVariable = PropDef<String>('progressVariable', Codecs.string, '');
  static const access = PropDef<CloudFileAccess>('access', EnumCodec(CloudFileAccess.values), CloudFileAccess.public);
  static const source = PropDef<String>('source', Codecs.string, '',
      doc: 'Uploads this instead of asking the user: a data: URL (\${result.image} of a screenshot), or a list.');
  static const fileName = PropDef<String>('fileName', Codecs.string, '', doc: 'The name a source file is stored under.');
  static const actions = PropDef<Object?>('actions', Codecs.any, null, doc: 'Nested actions: run with each file.');
  static const List<PropDef<Object?>> all = [
    operation, path, kind, allowMultiple, maxSizeMB, progressVariable, access, source, fileName, actions, //
  ];
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

/// [DownloadFileAction].
abstract final class DownloadFileFields {
  static const fileName = PropDef<String>('fileName', Codecs.string, 'export.txt', doc: 'Suggested filename, an expression.');
  static const text = PropDef<String>('text', Codecs.string, '', doc: 'Generated file contents as UTF-8 text.');
  static const mimeType = PropDef<String>('mimeType', Codecs.string, 'text/plain');
  static const List<PropDef<Object?>> all = [fileName, text, mimeType];
}

/// [PreloadImagesAction].
abstract final class PreloadImagesFields {
  static const urls = PropDef<String>('urls', Codecs.string, '', doc: 'The image URLs: a list (an expression) or comma-separated text.');
  static const progressVariable = PropDef<String>('progressVariable', Codecs.string, '',
      doc: 'A variable to hold the share loaded (0-1) while it runs.');
  static const List<PropDef<Object?>> all = [urls, progressVariable];
}

/// [DelayAction].
abstract final class DelayFields {
  static const ms = PropDef<int>('ms', Codecs.int, 500);
  static const duration = PropDef<String>('duration', Codecs.string, '', doc: 'A formula giving milliseconds.');
  static const List<PropDef<Object?>> all = [ms, duration];
}

/// [CloudDataAction].
abstract final class CloudDataFields {
  static const operation = PropDef<CloudDataOperation>('operation', EnumCodec(CloudDataOperation.values), CloudDataOperation.create);
  static const collection = PropDef<String>('collection', Codecs.string, '');
  static const id = PropDef<String>('id', Codecs.string, '');
  static const fields = PropDef<Object?>('fields', Codecs.any, null, doc: 'Field writes: [{"field", "value", "operation"}].');
  static const whereFilters = PropDef<Object?>('whereFilters', Codecs.any, null);
  static const orderByFilters = PropDef<Object?>('orderByFilters', Codecs.any, null);
  static const limit = PropDef<int?>('limit', Codecs.optionalInt, null);
  static const aggregateField = PropDef<String>('aggregateField', Codecs.string, '');
  static const loadRelated = PropDef<List<String>>('loadRelated', Codecs.strings, []);
  static const resultVariable = PropDef<String>('resultVariable', Codecs.string, '');
  static const List<PropDef<Object?>> all = [
    operation, collection, id, fields, whereFilters, orderByFilters, limit, aggregateField, loadRelated, //
    resultVariable,
  ];
}

/// [CloudBatchAction].
abstract final class CloudBatchFields {
  static const steps = PropDef<Object?>('steps', Codecs.any, null, doc: 'Nested cloudData actions.');
  static const transaction = PropDef<bool>('transaction', Codecs.bool, false,
      doc: 'All or none: more than $kMaxCloudBatchWrites writes fail instead of committing in chunks.');
  static const forEach = PropDef<String>('forEach', Codecs.string, '',
      doc: 'A list: the steps run per item (\${loop.item}, \${loop.index}), all in one commit.');
  static const List<PropDef<Object?>> all = [steps, transaction, forEach];
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

/// [PaywallAction].
abstract final class PaywallFields {
  static const offer = PropDef<String?>('offer', Codecs.optionalString, null, doc: 'storeDefault, trial, or standard; expressions allowed.');
  static const placement = PropDef<String?>('placement', Codecs.optionalString, null, doc: 'The server-resolved placement to open.');
  static const operation = PropDef<PaywallOperation>('operation', EnumCodec(PaywallOperation.values), PaywallOperation.purchase);
  static const slot = PropDef<String?>('slot', Codecs.optionalString, null);
  static const url = PropDef<String?>('url', Codecs.optionalString, null, doc: 'A legal link.');
  static const transition = PropDef<PageTransition>('transition', EnumCodec(PageTransition.values), PageTransition.platform,
      doc: 'openPaywall: how its screen opens.');
  static const transitionMs = PropDef<int?>('transitionMs', Codecs.optionalInt, null);
  static const reverseTransitionMs = PropDef<int?>('reverseTransitionMs', Codecs.optionalInt, null);
  static const routeTransition = PropDef<RouteTransition?>('routeTransition', routeTransitionCodec, null,
      doc: 'openPaywall: a custom transition for its screen; replaces transition and its times.');
  static const List<PropDef<Object?>> all = [
    operation, placement, offer, slot, url, transition, transitionMs, reverseTransitionMs, routeTransition, //
  ];
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

/// [SpeakAction].
abstract final class SpeakFields {
  static const text = PropDef<String>('text', Codecs.string, '');
  static const language = PropDef<String>('language', Codecs.string, '');
  static const rate = PropDef<String>('rate', Codecs.string, '1', doc: 'A number or expression.');
  static const pitch = PropDef<String>('pitch', Codecs.string, '', doc: 'A number or expression.');
  static const stop = PropDef<bool>('stop', Codecs.bool, false, doc: 'Stops speaking.');
  static const readAlong = PropDef<bool>('readAlong', Codecs.bool, false,
      doc: 'Times every word (speech.wordIndex) even when the voice reports no word boundaries, '
          'and reads along silently without a voice; the action waits until the text is said.');
  static const startWord = PropDef<String>('startWord', Codecs.string, '',
      doc: 'Read along: the word to start at (an index or expression), to carry on after a pause.');
  static const List<PropDef<Object?>> all = [text, language, rate, pitch, stop, readAlong, startWord];
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

/// [PlaySoundAction].
abstract final class PlaySoundFields {
  static const sound = PropDef<String>('sound', Codecs.string, 'wood', doc: 'A synthesised voice name.');
  static const operation = PropDef<String>('operation', Codecs.string, 'play', doc: 'play, start, stop, or stopAll.');
  static const voiceId = PropDef<String>('voiceId', Codecs.string, '', doc: 'The independently owned sustained voice.');
  static const frequency = PropDef<String>('frequency', Codecs.string, '440', doc: 'Sustained tone frequency in hertz.');
  static const waveform = PropDef<String>('waveform', Codecs.string, 'sine',
      doc: 'Sustained voice: sine, triangle, square, sawtooth, felt, reed or pluck.');
  static const note = PropDef<String>('note', Codecs.string, '', doc: 'A MIDI note number (60 = middle C) in place of frequency.');
  static const duration = PropDef<String>('duration', Codecs.string, '', doc: 'Milliseconds until a started voice releases itself; empty sustains.');
  static const volume = PropDef<String>('volume', Codecs.string, '1');
  static const pitch = PropDef<String>('pitch', Codecs.string, '1');
  static const at = PropDef<String>('at', Codecs.string, '', doc: 'A time on the sound clock.');
  static const url = PropDef<String>('url', Codecs.string, '', doc: 'A sound file.');
  static const List<PropDef<Object?>> all = [sound, operation, voiceId, frequency, waveform, note, duration, volume, pitch, at, url];
}

/// [PlayAnimationAction].
abstract final class PlayAnimationFields {
  static const node = PropDef<String>('node', Codecs.string, '');
  static const animation = PropDef<String>('animation', Codecs.string, '', doc: 'A one-shot animation (or particles).');
  static const List<PropDef<Object?>> all = [node, animation];
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

/// [EmitEventAction].
abstract final class EmitEventFields {
  static const event = PropDef<String>('event', Codecs.string, '', doc: 'The app event\'s name (an expression).');
  static const props = PropDef<Object?>('props', Codecs.any, null, doc: 'Its properties; text values are expressions.');
  static const List<PropDef<Object?>> all = [event, props];
}

/// [CaptureScreenshotAction].
abstract final class CaptureScreenshotFields {
  static const target = PropDef<CaptureTarget>('target', EnumCodec(CaptureTarget.values), CaptureTarget.layout,
      doc: 'The screen, one of its nodes, or the whole app (in the host\'s capture scope).');
  static const node = PropDef<String>('node', Codecs.string, '', doc: 'The node captured (target node).');
  static const pixelRatio = PropDef<double>('pixelRatio', Codecs.double, 0, doc: 'Pixels per logical pixel; 0: the device\'s.');
  static const List<PropDef<Object?>> all = [target, node, pixelRatio];
}

/// Every action type an editor can make, by JSON type.
abstract final class ActionSpecs {
  /// The standard catalog's action declarations ([standardCatalog]).
  static Iterable<ActionSpec> get all => standardCatalog.actions;

  static ActionSpec? of(String type) => standardCatalog.action(type);


  /// The keys of action JSON [json], and of the actions nested in it, that
  /// its type doesn't have, as paths (`look`, `actions[1].style`): a
  /// misspelled or misplaced field (`style` where a confirm takes `look`)
  /// that decoding drops without a word. A type this version doesn't know
  /// is kept whole, so it has none.
  static List<String> unknownKeys(Object? json, [String path = '']) {
    final m = readMap(json);
    final spec = m == null ? null : of(readString(m['type']) ?? '');
    if (m == null || spec == null) return const [];
    final known = {
      'type', ActionCommonFields.enabled.key, ActionCommonFields.nonBlocking.key, ActionCommonFields.when.key,
      for (final f in spec.fields) f.key,
      ...?ActionDef.fromJson(m)?.toJson().keys,
    };
    final out = <String>[];
    for (final e in m.entries) {
      if (!known.contains(e.key)) out.add('$path${e.key}');
      final v = e.value;
      if (v is! List) continue;
      for (var i = 0; i < v.length; i++) {
        final item = v[i];
        if (item is Map && item['type'] is String) out.addAll(unknownKeys(item, '$path${e.key}[$i].'));
      }
    }
    return out;
  }
}

/// Keys of action JSON that no field of its type reads, found in
/// [reactions] (a node's `actions`: reactions `{trigger, actions}`, or a
/// bare list of actions), nested chains included (`then`, `else`,
/// `actions`, `onSuccess`, `onError`, `cancelActions`). Decoding drops such
/// keys silently (a `delay` given `durationMs` waits its default 500 ms), so
/// tools report them: each as "<path>: <type> has no "<key>" (it takes: ...)".
List<String> unknownActionKeys(Object? reactions, {String at = 'actions'}) {
  final out = <String>[];
  const structural = {'type', 'id', 'enabled', 'nonBlocking', 'when'};
  const nested = {'then', 'else', 'actions', 'onSuccess', 'onError', 'cancelActions'};
  void action(Object? a, String path) {
    final m = readMap(a);
    if (m == null) return;
    final type = m['type'];
    final spec = type is String ? ActionSpecs.of(type) : null;
    if (spec != null) {
      final known = {...structural, for (final f in spec.fields) f.key};
      for (final k in m.keys) {
        if (!known.contains(k)) {
          out.add('$path: ${spec.type} has no "$k" (it takes: ${spec.fields.map((f) => f.key).join(', ')})');
        }
      }
    }
    for (final k in nested) {
      if (m[k] case final List list) {
        for (var i = 0; i < list.length; i++) {
          action(list[i], '$path.$k[$i]');
        }
      }
    }
  }

  if (reactions is List) {
    for (var i = 0; i < reactions.length; i++) {
      final r = readMap(reactions[i]);
      if (r == null) continue;
      if (r.containsKey('trigger')) {
        final trigger = readMap(r['trigger']);
        final known = {for (final f in TriggerFields.all) f.key};
        for (final k in trigger?.keys ?? const <String>[]) {
          if (!known.contains(k)) out.add('$at[$i].trigger has no "$k" (it takes: ${known.join(', ')})');
        }
        if (r['actions'] case final List chain) {
          for (var j = 0; j < chain.length; j++) {
            action(chain[j], '$at[$i].actions[$j]');
          }
        }
      } else {
        action(r, '$at[$i]');
      }
    }
  }
  return out;
}
