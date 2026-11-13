// Paywalls as data: store products by stable slot, and the placements an app
// opens a paywall layout at. Prices never live here: they come from the store
// (a slot's [ProductTestData] is only for the SDK's test store on the web,
// which never charges and never grants a real entitlement).
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../core/json.dart';

/// A product slot: a stable id (`monthly`, `annual`) bindings use, mapped to
/// each store's product id.
@immutable
final class ProductSlot {
  const ProductSlot(this.id, {this.iosProductId = '', this.androidProductId = '', this.test});

  final String id;

  /// The App Store product id.
  final String iosProductId;

  /// The Google Play product id.
  final String androidProductId;

  /// What the SDK's test store shows and does for this slot on preview and
  /// demo sites (no store, no payment); null when it has none. Real stores
  /// ignore it.
  final ProductTestData? test;

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
      test: ProductTestData.fromJson(m['test']),
    );
  }

  Json toJson() => {
        'id': id,
        if (iosProductId.isNotEmpty) 'iosProductId': iosProductId,
        if (androidProductId.isNotEmpty) 'androidProductId': androidProductId,
        if (test != null) 'test': test!.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      other is ProductSlot &&
      other.id == id &&
      other.iosProductId == iosProductId &&
      other.androidProductId == androidProductId &&
      other.test == test;

  @override
  int get hashCode => Object.hash(id, iosProductId, androidProductId, test);

  @override
  String toString() => 'ProductSlot($id)';
}

/// How a test purchase of a slot ends in the SDK's test store.
enum TestPurchaseOutcome {
  /// Purchased: grants the slot's test entitlement (the default).
  purchased,

  /// Declined: fails with code `payment-declined`.
  declined,

  /// Cancelled by the user.
  cancelled,
}

/// A product slot's made-up store data for the SDK's test store: what a
/// paywall shows and does on the web (preview and demo sites), where there is
/// no store. Never charges and never grants a real entitlement: the test
/// store's grants stay on the device and the paywall server rejects test
/// receipts.
@immutable
final class ProductTestData {
  const ProductTestData({
    this.price = '',
    this.rawPrice,
    this.currency = 'USD',
    this.currencySymbol = '',
    this.period = '',
    this.trialDays = 0,
    this.entitlementId = '',
    this.outcome = TestPurchaseOutcome.purchased,
  });

  /// The displayed price (`\$4.99`); derived from [rawPrice] when empty.
  final String price;
  final double? rawPrice;

  /// The ISO 4217 currency code (`USD`).
  final String currency;
  final String currencySymbol;

  /// The billing period: `week`, `month`, `year`, or '' for a one-time
  /// (lifetime) purchase.
  final String period;

  /// A free trial's length in days; 0 for none.
  final int trialDays;

  /// The test entitlement a test purchase grants.
  final String entitlementId;

  /// How a test purchase ends.
  final TestPurchaseOutcome outcome;

  static ProductTestData? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    return ProductTestData(
      price: readString(m['price']) ?? '',
      rawPrice: readDouble(m['rawPrice']),
      currency: readString(m['currency']) ?? 'USD',
      currencySymbol: readString(m['currencySymbol']) ?? '',
      period: readString(m['period']) ?? '',
      trialDays: (readInt(m['trialDays']) ?? 0).clamp(0, 3650),
      entitlementId: readString(m['entitlementId']) ?? '',
      outcome: m['outcome'] == 'canceled'
          ? TestPurchaseOutcome.cancelled
          : readEnum(TestPurchaseOutcome.values, m['outcome'], TestPurchaseOutcome.purchased),
    );
  }

  Json toJson() => {
        if (price.isNotEmpty) 'price': price,
        if (rawPrice != null) 'rawPrice': rawPrice,
        'currency': currency,
        if (currencySymbol.isNotEmpty) 'currencySymbol': currencySymbol,
        if (period.isNotEmpty) 'period': period,
        if (trialDays > 0) 'trialDays': trialDays,
        if (entitlementId.isNotEmpty) 'entitlementId': entitlementId,
        if (outcome != TestPurchaseOutcome.purchased) 'outcome': outcome.name,
      };

  @override
  bool operator ==(Object other) => other is ProductTestData && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());

  @override
  String toString() => 'ProductTestData(${toJson()})';
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
  const PaywallConfig({
    this.products = const [],
    this.placements = const [],
    this.termsUrl = '',
    this.privacyUrl = '',
    this.testStore = false,
  });

  final List<ProductSlot> products;
  final List<PaywallPlacement> placements;
  final String termsUrl;
  final String privacyUrl;

  /// Whether the SDK runs these paywalls on its test store where there is no
  /// real store (the web: preview and demo sites), from the slots'
  /// [ProductSlot.test] data. Never charges, never grants real entitlements,
  /// and never applies on iOS or Android.
  final bool testStore;

  bool get isEmpty => products.isEmpty && placements.isEmpty && termsUrl.isEmpty && privacyUrl.isEmpty && !testStore;

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
      testStore: readBool(m['testStore']) ?? false,
    );
  }

  Json toJson() => {
        if (products.isNotEmpty) 'products': [for (final p in products) p.toJson()],
        if (placements.isNotEmpty) 'placements': [for (final p in placements) p.toJson()],
        if (termsUrl.isNotEmpty) 'termsUrl': termsUrl,
        if (privacyUrl.isNotEmpty) 'privacyUrl': privacyUrl,
        if (testStore) 'testStore': true,
      };

  @override
  bool operator ==(Object other) => other is PaywallConfig && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());
}
