import 'action/call_function_action.dart';

/// A stable product identity independent of the store SKU and locale.
class ProductSlot {
  final String id;
  final String iosProductId;
  final String androidProductId;

  const ProductSlot({
    required this.id,
    required this.iosProductId,
    required this.androidProductId,
  });

  factory ProductSlot.fromJson(Map<String, dynamic> json) => ProductSlot(
    id: json['id'] as String,
    iosProductId: json['iosProductId'] as String,
    androidProductId: json['androidProductId'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'iosProductId': iosProductId,
    'androidProductId': androidProductId,
  };
}

/// A named entry point resolved to a published layout by the host application.
class PaywallPlacement {
  final String id;
  final String layoutId;
  final List<String> productSlots;

  const PaywallPlacement({
    required this.id,
    required this.layoutId,
    required this.productSlots,
  });

  factory PaywallPlacement.fromJson(Map<String, dynamic> json) =>
      PaywallPlacement(
        id: json['id'] as String,
        layoutId: json['layoutId'] as String,
        productSlots: (json['productSlots'] as List).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'layoutId': layoutId,
    'productSlots': productSlots,
  };
}

/// Typed paywall actions encoded using the existing published callFunction wire format.
/// The editor can serialize [toAction] without changing the action visitor.
enum PaywallOperation { purchase, restore, selectProduct, closePaywall }

class PaywallAction {
  final PaywallOperation operation;
  final String? slot;
  const PaywallAction(this.operation, {this.slot});

  CallFunctionAction toAction() => CallFunctionAction(
    name: 'paywall.${operation.name}',
    params: slot == null ? {} : {'slot': slot},
  );
}
