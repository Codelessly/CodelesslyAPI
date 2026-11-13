import '../../core/catalog.dart';
import 'actions.dart';
import 'data_sources.dart';

/// The data library's declarations: APIs, storage, cloud data and files, form submissions ([DataAction]); the `cloud` and `api` list data sources.
const Catalog dataCatalog = Catalog(id: 'data', actions: dataActionSpecs, dataSources: dataSourceSpecs);
