// Paywalls as data: store products by stable slot, and the placements an app
// opens a paywall layout at. Prices never live here: they come from the store.
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../json.dart';

/// A product slot: a stable id (`monthly`, `annual`) bindings use, mapped to
/// each store's product id.
@immutable
final class ProductSlot {
  const ProductSlot(this.id, {this.iosProductId = '', this.androidProductId = ''});

  final String id;

  /// The App Store product id.
  final String iosProductId;

  /// The Google Play product id.
  final String androidProductId;

  /// The product id for [platform] (`ios`, `macos`, `android`).
  String productIdFor(String platform) =>
      platform == 'ios' || platform == 'macos' ? iosProductId : androidProductId;

  static ProductSlot? fromJson(Object? json) {
    final m = readMap(json);
    final id = readString(m?['id']);
    if (m == null || id == null || id.isEmpty) return null;
    return ProductSlot(
      id,
      iosProductId: readString(m['iosProductId']) ?? '',
      androidProductId: readString(m['androidProductId']) ?? '',
    );
  }

  Json toJson() => {
        'id': id,
        if (iosProductId.isNotEmpty) 'iosProductId': iosProductId,
        if (androidProductId.isNotEmpty) 'androidProductId': androidProductId,
      };

  @override
  bool operator ==(Object other) =>
      other is ProductSlot &&
      other.id == id &&
      other.iosProductId == iosProductId &&
      other.androidProductId == androidProductId;

  @override
  int get hashCode => Object.hash(id, iosProductId, androidProductId);

  @override
  String toString() => 'ProductSlot($id)';
}

/// A named entry point (`onboarding`, `settings`) the app opens a paywall
/// at: the layout it shows and the product slots in it.
@immutable
final class PaywallPlacement {
  const PaywallPlacement(this.id, {this.layoutId = '', this.productSlots = const []});

  final String id;
  final String layoutId;
  final List<String> productSlots;

  static PaywallPlacement? fromJson(Object? json) {
    final m = readMap(json);
    final id = readString(m?['id']);
    if (m == null || id == null || id.isEmpty) return null;
    return PaywallPlacement(id, layoutId: readString(m['layoutId']) ?? '', productSlots: readStrings(m['productSlots']));
  }

  Json toJson() => {
        'id': id,
        if (layoutId.isNotEmpty) 'layoutId': layoutId,
        if (productSlots.isNotEmpty) 'productSlots': productSlots,
      };

  @override
  bool operator ==(Object other) =>
      other is PaywallPlacement &&
      other.id == id &&
      other.layoutId == layoutId &&
      const ListEquality<String>().equals(other.productSlots, productSlots);

  @override
  int get hashCode => Object.hash(id, layoutId, const ListEquality<String>().hash(productSlots));
}

/// A project's paywall setup: its product slots, placements and legal links.
@immutable
final class PaywallConfig {
  const PaywallConfig({this.products = const [], this.placements = const [], this.termsUrl = '', this.privacyUrl = ''});

  final List<ProductSlot> products;
  final List<PaywallPlacement> placements;
  final String termsUrl;
  final String privacyUrl;

  bool get isEmpty => products.isEmpty && placements.isEmpty && termsUrl.isEmpty && privacyUrl.isEmpty;

  ProductSlot? product(String id) => products.firstWhereOrNull((p) => p.id == id);
  PaywallPlacement? placement(String id) => placements.firstWhereOrNull((p) => p.id == id);

  /// The slots of [placement], in its order.
  List<ProductSlot> slotsOf(PaywallPlacement placement) => [...placement.productSlots.map(product).nonNulls];

  static PaywallConfig fromJson(Object? json) {
    final m = readMap(json) ?? const {};
    return PaywallConfig(
      products: [...?readList(m['products'])?.map(ProductSlot.fromJson).nonNulls],
      placements: [...?readList(m['placements'])?.map(PaywallPlacement.fromJson).nonNulls],
      termsUrl: readString(m['termsUrl']) ?? '',
      privacyUrl: readString(m['privacyUrl']) ?? '',
    );
  }

  Json toJson() => {
        if (products.isNotEmpty) 'products': [for (final p in products) p.toJson()],
        if (placements.isNotEmpty) 'placements': [for (final p in placements) p.toJson()],
        if (termsUrl.isNotEmpty) 'termsUrl': termsUrl,
        if (privacyUrl.isNotEmpty) 'privacyUrl': privacyUrl,
      };

  @override
  bool operator ==(Object other) => other is PaywallConfig && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());
}
