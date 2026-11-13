import '../../core/catalog.dart';
import 'actions.dart';
import 'widgets.dart';

/// The media library's declarations: Video, audio and web views; speech, sound, image preloading, capture, print and file downloads ([MediaAction]).
const Catalog mediaCatalog = Catalog(id: 'media', widgets: mediaSpecs, actions: mediaActionSpecs);
