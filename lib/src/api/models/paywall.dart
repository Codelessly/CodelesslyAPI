/// A stable product identity independent of the store SKU and locale.
class ProductSlot {
  /// Slot key used in paywall bindings.
  final String id;

  /// Apple App Store product identifier.
  final String iosProductId;

  /// Google Play product identifier.
  final String androidProductId;

  /// Defines a cross-platform product slot.
  const ProductSlot({
    required this.id,
    required this.iosProductId,
    required this.androidProductId,
  });

  /// Reads a published product slot.
  factory ProductSlot.fromJson(Map<String, dynamic> json) => ProductSlot(
    id: json['id'] as String,
    iosProductId: json['iosProductId'] as String,
    androidProductId: json['androidProductId'] as String,
  );

  /// Serializes the slot for publishing.
  Map<String, dynamic> toJson() => {
    'id': id,
    'iosProductId': iosProductId,
    'androidProductId': androidProductId,
  };
}

/// A named entry point resolved to a published layout by the host application.
class PaywallPlacement {
  /// Key supplied by the host app.
  final String id;

  /// ID of the published layout.
  final String layoutId;

  /// Named product slots displayed in the layout.
  final List<String> productSlots;

  /// Defines a published placement.
  const PaywallPlacement({
    required this.id,
    required this.layoutId,
    required this.productSlots,
  });

  /// Reads a published placement.
  factory PaywallPlacement.fromJson(Map<String, dynamic> json) =>
      PaywallPlacement(
        id: json['id'] as String,
        layoutId: json['layoutId'] as String,
        productSlots: (json['productSlots'] as List).cast<String>(),
      );

  /// Serializes the placement for publishing.
  Map<String, dynamic> toJson() => {
    'id': id,
    'layoutId': layoutId,
    'productSlots': productSlots,
  };
}
