// The commerce library's action types as declared fields, for generated
// editors (see core/action_fields.dart).
import '../../core/action_fields.dart';
import '../../core/props.dart';
import '../../core/route_transition.dart';
import '../../core/actions.dart';
import 'actions.dart';

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
