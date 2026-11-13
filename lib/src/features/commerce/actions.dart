// The commerce library's action types: purchases and paywalls. One immutable
// class per type, decoded through its ActionSpec ([commerceActionSpecs]); the
// SDK's commerce feature runs them.

import 'action_fields.dart';
import '../../core/actions.dart';
import '../../core/catalog.dart';
import '../../core/json.dart';
import '../../core/route_transition.dart';

/// The fields every action has.
typedef _Common = ActionCommon;

// Reading an action's fields: the core's rules (core/actions.dart).
String _s(Json m, String k, [String def = '']) => switch (m[k]) {
  final String s => s,
  final num n => '$n',
  final bool b => '$b',
  _ => def,
};
String? _sOrNull(Json m, String k) => m[k] == null ? null : _s(m, k);
T _e<T extends Enum>(List<T> values, Json m, String k, T def) => readEnum(values, m[k], def);

/// Opens a placement, or acts inside a paywall screen.
enum PaywallOperation { purchase, restore, selectProduct, closePaywall, openLegalLink, openPaywall }

/// A paywall interaction: buy the selected (or [slot]'s) product, restore
/// purchases, select a product, close the paywall, open a legal [url], or
/// open a server-resolved [placement].
///
/// [PaywallOperation.openPaywall] shows the placement's screen as a
/// navigation would: with [routeTransition] (a custom transition: a cover
/// from the bottom, a reveal...) or [transition], [transitionMs] and
/// [reverseTransitionMs]; it plays in reverse when the paywall closes.
final class PaywallAction extends ActionDef {
  const PaywallAction({
    this.operation = PaywallOperation.purchase,
    this.placement,
    this.offer,
    this.slot,
    this.url,
    this.transition = PageTransition.platform,
    this.transitionMs,
    this.reverseTransitionMs,
    this.routeTransition,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'paywall';
  @override
  String get type => typeName;

  final PaywallOperation operation;

  /// Server-resolved placement to open; required for [PaywallOperation.openPaywall].
  final String? placement;

  /// Optional offer preference: storeDefault, trial, or standard (expressions allowed).
  final String? offer;
  final String? slot;
  final String? url;

  /// [PaywallOperation.openPaywall]: how its screen opens, as
  /// [NavigateAction.transition] (and its durations) does.
  final PageTransition transition;
  final int? transitionMs, reverseTransitionMs;

  /// [PaywallOperation.openPaywall]: a custom transition for its screen; when
  /// set it replaces [transition], [transitionMs] and [reverseTransitionMs]
  /// (as [NavigateAction.routeTransition]).
  final RouteTransition? routeTransition;

  static PaywallAction _fromJson(Json m, _Common c) => PaywallAction(
    operation: _e(PaywallOperation.values, m, 'operation', PaywallOperation.purchase),
    placement: _sOrNull(m, 'placement'),
    offer: _sOrNull(m, 'offer'),
    slot: _sOrNull(m, 'slot'),
    url: _sOrNull(m, 'url'),
    transition: _e(PageTransition.values, m, 'transition', PageTransition.platform),
    transitionMs: readInt(m['transitionMs']),
    reverseTransitionMs: readInt(m['reverseTransitionMs']),
    routeTransition: RouteTransition.fromJson(m['routeTransition']),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get fieldsJson => {
    'operation': operation.name,
    'placement': ?placement,
    'offer': ?offer,
    'slot': ?slot,
    'url': ?url,
    if (transition != PageTransition.platform) 'transition': transition.name,
    'transitionMs': ?transitionMs,
    'reverseTransitionMs': ?reverseTransitionMs,
    'routeTransition': ?routeTransition?.toJson(),
  };
}

/// The commerce library's action type ([PaywallAction]).
const List<ActionSpec> commerceActionSpecs = [
  ActionSpec(PaywallAction.typeName, label: 'Paywall', fields: PaywallFields.all, decode: PaywallAction._fromJson, requires: ['purchases']),
];
