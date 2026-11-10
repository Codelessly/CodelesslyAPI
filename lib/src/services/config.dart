// What a publish model carries for the app's services.
import 'package:meta/meta.dart';

import '../json.dart';
import 'http_api.dart';
import 'paywall.dart';

/// The services part of a publish model (its `services` key):
///
/// ```json
/// {"apis": {"tides": {"url": "https://...", "inputs": [...]}},
///  "paywall": {"products": [...], "placements": [...]}}
/// ```
///
/// Data rules and schemas aren't here: they change without a publish, so
/// the cloud database service reads them live.
@immutable
final class ServiceConfig {
  ServiceConfig({Map<String, HttpApi> apis = const {}, this.paywall = const PaywallConfig(), this.extra = const {}})
      : apis = Map.unmodifiable(apis);

  static final empty = ServiceConfig();

  /// API id → API.
  final Map<String, HttpApi> apis;
  final PaywallConfig paywall;

  /// Keys this version doesn't model, kept.
  final Json extra;

  /// Decodes the config. Each API's id is its key.
  static ServiceConfig fromJson(Object? json) {
    final m = readMap(json) ?? const {};
    return ServiceConfig(
      apis: {
        for (final e in (readMap(m['apis']) ?? const {}).entries)
          if (readMap(e.value) != null) e.key: HttpApi.fromJson(e.value).copyWith(id: e.key),
      },
      paywall: PaywallConfig.fromJson(m['paywall']),
      extra: {
        for (final e in m.entries)
          if (e.key != 'apis' && e.key != 'paywall') e.key: e.value,
      },
    );
  }

  Json toJson() => {
        if (apis.isNotEmpty) 'apis': {for (final e in apis.entries) e.key: e.value.toJson()..remove('id')},
        if (!paywall.isEmpty) 'paywall': paywall.toJson(),
        ...extra,
      };

  ServiceConfig copyWith({Map<String, HttpApi>? apis, PaywallConfig? paywall}) =>
      ServiceConfig(apis: apis ?? this.apis, paywall: paywall ?? this.paywall, extra: extra);

  @override
  bool operator ==(Object other) => other is ServiceConfig && jsonEquality.equals(other.toJson(), toJson());

  @override
  int get hashCode => jsonEquality.hash(toJson());
}
