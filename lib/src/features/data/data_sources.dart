// The data library's list data sources: where a list, grid or pagination
// loads its items from when it isn't the bound `data` (the core's). Declared
// so an editor and a validator can describe their settings; on the wire they
// are, as before, a list's `query` and a pagination's `source`, `apiId`,
// `parameters`, `itemsPath`, `totalPath` and `cursorPath`, and a reorder's
// `apply: cloud` with its `orderField` (the `source` object of the proposal,
// docs/design/05-plugins-and-layers.md §6.3, is not written yet).
import '../../core/catalog.dart';
import '../../core/widgets/collections.dart';

/// A collection of the app's cloud database: a query over it
/// ([CollectionScrollProps.query]); a reorder writes each item's
/// [ListReorderFields.orderField].
const cloudDataSource = DataSourceSpec(
  'cloud',
  fields: [CollectionScrollProps.query, ListReorderFields.orderField],
  pages: true,
  requires: ['cloud'],
  doc: 'A cloud database query; pages by cursor.',
);

/// One of the project's HTTP APIs, called once per page.
const apiDataSource = DataSourceSpec(
  'api',
  fields: [PaginationFields.apiId, PaginationFields.parameters, PaginationFields.itemsPath, PaginationFields.totalPath,
    PaginationFields.cursorPath],
  pages: true,
  requires: ['api'],
  doc: 'A project API, one call per page; the items, total and cursor read at their paths of the response.',
);

/// The data library's data sources.
const List<DataSourceSpec> dataSourceSpecs = [cloudDataSource, apiDataSource];
