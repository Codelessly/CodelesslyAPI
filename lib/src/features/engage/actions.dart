// The engage library's action types: app events. One immutable
// class per type, decoded through its ActionSpec ([engageActionSpecs]); the
// SDK's engage feature runs them.

import 'action_fields.dart';
import '../../core/actions.dart';
import '../../core/catalog.dart';
import '../../core/json.dart';

/// The fields every action has.
typedef _Common = ActionCommon;

// Reading an action's fields: the core's rules (core/actions.dart).
String _s(Json m, String k, [String def = '']) => switch (m[k]) {
  final String s => s,
  final num n => '$n',
  final bool b => '$b',
  _ => def,
};
Json _map(Json m, String k) => readMap(m[k]) ?? const {};

/// The engage library's action types: app events.
sealed class EngageAction extends ActionDef {
  const EngageAction({super.enabled, super.nonBlocking, super.when});
}

/// Fires app event [event] with [props] (text values are expressions) on
/// the app's event bus: the project's automations listening for it run (a
/// popup after the third order), and the host app hears it
/// (`codelessly.events`). The same bus a host fires with
/// `codelessly.emit(name, props)`. JSON: `{"type": "emitEvent", "event":
/// "onboarding_done", "props": {"plan": "${plan}"}}`.
final class EmitEventAction extends EngageAction {
  const EmitEventAction({this.event = '', this.props = const {}, super.enabled, super.nonBlocking, super.when});

  static const typeName = 'emitEvent';
  @override
  String get type => typeName;

  /// The event's name (an expression).
  final String event;

  /// Its properties; text values are expressions.
  final Json props;

  static EmitEventAction _fromJson(Json m, _Common c) => EmitEventAction(
    event: _s(m, 'event'),
    props: _map(m, 'props'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get fieldsJson => {'event': event, if (props.isNotEmpty) 'props': props};
}

/// The engage library's action types ([EngageAction]).
const List<ActionSpec> engageActionSpecs = [
  ActionSpec(EmitEventAction.typeName, label: 'Emit event', fields: EmitEventFields.all, decode: EmitEventAction._fromJson, requires: ['events']),
];
