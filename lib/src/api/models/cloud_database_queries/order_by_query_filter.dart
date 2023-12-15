import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import 'query_filter.dart';

part 'order_by_query_filter.g.dart';

/// Enum representing the Firestore order by operations.
enum OrderByQuerySortOrder {
  /// Represents an ascending order operation.
  ascending('asc', 'In Ascending Order'),

  /// Represents a descending order operation.
  descending('desc', 'In Descending Order');

  /// The operation name.
  final String value;

  /// The human-readable name of the operation.
  final String label;

  const OrderByQuerySortOrder(this.value, this.label);
}

/// Represents the order-by operation in Firestore.
@JsonSerializable()
class OrderByQueryFilter extends QueryFilter with EquatableMixin {
  /// The order-by operation to perform.
  final OrderByQuerySortOrder sortOrder;

  /// Creates a new [OrderByQueryFilter] instance, given a [field] and an
  /// [sortOrder].
  const OrderByQueryFilter({
    required super.field,
    this.sortOrder = OrderByQuerySortOrder.ascending,
  });

  /// Creates a copy of this [OrderByQueryFilter] instance with the given
  /// parameters.
  OrderByQueryFilter copyWith({
    String? field,
    OrderByQuerySortOrder? sortOrder,
  }) {
    return OrderByQueryFilter(
      field: field ?? this.field,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Converts a JSON object to a [OrderByQueryFilter] instance.
  factory OrderByQueryFilter.fromJson(Map<String, dynamic> json) =>
      _$OrderByQueryFilterFromJson(json);

  /// Converts this [OrderByQueryFilter] instance to a JSON object.
  Map<String, dynamic> toJson() => _$OrderByQueryFilterToJson(this);

  @override
  List<Object?> get props => [field, sortOrder];
}
