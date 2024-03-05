import 'order_by_query_filter.dart';
import 'where_query_filter.dart';

/// An abstract class that represents common firestore operations.
abstract class QueryFilter {
  /// The name of the field to target.
  final String field;

  /// Creates a new [QueryFilter] instance.
  const QueryFilter({required this.field});

  /// A convenience getter that returns true if this [QueryFilter] is a
  /// [WhereQueryFilter].
  bool get isWhereFilter => this is WhereQueryFilter;

  /// A convenience getter that returns true if this [QueryFilter] is an
  /// [OrderByQueryFilter].
  bool get isOrderByFilter => this is OrderByQueryFilter;
}
