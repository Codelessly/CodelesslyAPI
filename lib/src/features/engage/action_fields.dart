// The engage library's action types as declared fields, for generated
// editors (see core/action_fields.dart).
import '../../core/props.dart';
import 'actions.dart';

/// [EmitEventAction].
abstract final class EmitEventFields {
  static const event = PropDef<String>('event', Codecs.string, '', doc: 'The app event\'s name (an expression).');
  static const props = PropDef<Object?>('props', Codecs.any, null, doc: 'Its properties; text values are expressions.');
  static const List<PropDef<Object?>> all = [event, props];
}
