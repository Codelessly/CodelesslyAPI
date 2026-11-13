/// Flutter's widgets and layouts as plain, immutable data: the core and
/// every first-party feature library, with [standardCatalog].
///
/// A program that needs only part of it imports that part:
/// `package:codelessly_api/core.dart` (the model and its [Catalog], no
/// feature), and `data.dart`, `auth.dart`, `commerce.dart`, `media.dart`,
/// `engage.dart`, `publish.dart`, `managed.dart` over it.
library;

export 'auth.dart';
export 'commerce.dart';
export 'core.dart';
export 'data.dart';
export 'engage.dart';
export 'managed.dart';
export 'media.dart';
export 'publish.dart';
export 'src/service_config.dart';
export 'src/standard_catalog.dart';
