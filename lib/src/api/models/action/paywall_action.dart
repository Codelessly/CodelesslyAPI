import '../../mixins.dart';
import '../../../schema/flutter_prop.dart';
import '../condition.dart';
import 'action.dart';

/// Native paywall interactions in published layouts.
enum PaywallOperation {
  /// Purchase selected or specified slot.
  purchase,

  /// Restore verified store purchases.
  restore,

  /// Change the selected product slot.
  selectProduct,

  /// Close without a purchase.
  closePaywall,

  /// Open the published privacy or terms link.
  openLegalLink,
}

/// A store-safe authored action, dispatched only within a paywall surface.
class PaywallAction extends ActionModel with SerializableMixin {
  /// Action performed by this paywall control.
  @PaywallWireField('operation', 'string', required: true)
  final PaywallOperation operation;

  /// Stable slot for purchase or product selection.
  @PaywallWireField('slot', 'string')
  final String? slot;

  /// Published URL for terms or privacy; must pass URL compliance validation.
  @PaywallWireField('url', 'string')
  final String? url;

  /// Creates a native paywall action.
  PaywallAction(
    this.operation, {
    this.slot,
    this.url,
    super.enabled,
    super.nonBlocking,
  }) : super(type: ActionType.paywall);

  /// Decode a published paywall action.
  factory PaywallAction.fromJson(Map json) => PaywallAction(
    PaywallOperation.values.byName(json['operation'] as String),
    slot: json['slot'] as String?,
    url: json['url'] as String?,
    enabled: json['enabled'] as bool? ?? true,
    nonBlocking: json['nonBlocking'] as bool? ?? false,
  );

  @override
  Map toJson() => {
    'type': type.name,
    'operation': operation.name,
    if (slot != null) 'slot': slot,
    if (url != null) 'url': url,
    if (!enabled) 'enabled': false,
    if (nonBlocking) 'nonBlocking': true,
  };

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitPaywallAction(this);
}
