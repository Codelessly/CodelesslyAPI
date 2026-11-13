// The standard catalog: the core and the first-party feature libraries
// (data, auth, commerce, media, engage). What decoding uses by default, so
// code written before catalogs existed keeps reading every type.
import 'core/actions.dart';
import 'core/catalog.dart';
import 'core/widgets/media.dart';
import 'core/widgets/widgets.dart';

/// The core: node types, layout, decoration, behaviors, triggers and the
/// core actions ([CoreAction]).
const Catalog coreCatalog = Catalog(id: 'core', widgets: coreWidgetSpecs, actions: coreActionSpecs);

/// APIs, storage, cloud data and files ([DataAction]).
const Catalog dataCatalog = Catalog(id: 'data', actions: dataActionSpecs);

/// Sign-in ([AuthAction]).
const Catalog authCatalog = Catalog(id: 'auth', actions: authActionSpecs);

/// Purchases and paywalls ([PaywallAction]).
const Catalog commerceCatalog = Catalog(id: 'commerce', actions: commerceActionSpecs);

/// Video, audio and web views; speech, sound, image preloading, capture and
/// print ([MediaAction]).
const Catalog mediaCatalog = Catalog(id: 'media', widgets: mediaSpecs, actions: mediaActionSpecs);

/// App events and form submissions ([EngageAction]).
const Catalog engageCatalog = Catalog(id: 'engage', actions: engageActionSpecs);

/// [coreCatalog] and every first-party feature library.
const Catalog standardCatalog = Catalog(
  id: 'standard',
  parts: [coreCatalog, dataCatalog, authCatalog, commerceCatalog, mediaCatalog, engageCatalog],
);
