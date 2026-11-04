import '../props.dart';
import '../values/enums.dart';

/// Scrolling, for any container that can scroll its content
/// (`SingleChildScrollView`).
abstract final class ScrollProps {
  static const scrollable = PropDef<bool>('scrollable', Codecs.bool, false, doc: 'Scrolls its content.');
  static const scrollDirection =
      PropDef<Axis>('scrollDirection', EnumCodec(Axis.values), Axis.vertical, doc: 'The axis it scrolls along.');
  static const reverse = PropDef<bool>('reverse', Codecs.bool, false);
  static const physics =
      PropDef<ScrollPhysicsType>('physics', EnumCodec(ScrollPhysicsType.values), ScrollPhysicsType.platform);

  /// Scrolls even when the content fits.
  static const alwaysScroll = PropDef<bool>('alwaysScroll', Codecs.bool, false);

  static const List<PropDef<Object?>> all = [scrollable, scrollDirection, reverse, physics, alwaysScroll];
}
