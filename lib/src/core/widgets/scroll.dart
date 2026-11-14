import '../props.dart';
import '../values/enums.dart';

/// Scrolling, for any container that can scroll its content
/// (`SingleChildScrollView`).
abstract final class ScrollProps {
  static const scrollable = PropDef<bool>('scrollable', Codecs.bool, false, doc: 'Scrolls its content.');
  static const scrollDirection =
      PropDef<Axis>('scrollDirection', EnumCodec(Axis.values), Axis.vertical, doc: 'The axis it scrolls along.');
  /// Scrolls from the end: the content starts at the bottom (or right) edge (Flutter's `reverse`).
  static const reverse = PropDef<bool>('reverse', Codecs.bool, false);
  /// How the scroll view responds to the user (Flutter's `ScrollPhysics`): the platform's default, `bouncing`,
  /// `clamping`, or `never` (does not scroll).
  static const physics =
      PropDef<ScrollPhysicsType>('physics', EnumCodec(ScrollPhysicsType.values), ScrollPhysicsType.platform);

  /// Scrolls even when the content fits.
  static const alwaysScroll = PropDef<bool>('alwaysScroll', Codecs.bool, false);

  /// How the scroll view clips its content.
  static const clipBehavior = PropDef<Clip>('clipBehavior', EnumCodec(Clip.values), Clip.hardEdge);

  /// Comes to rest with a child at the start of the view.
  static const itemSnapping = PropDef<bool>('itemSnapping', Codecs.bool, false,
      doc: 'Each drag or fling comes to rest with an item at the start of the view (CSS `scroll-snap-type: mandatory` with `scroll-snap-align: start`), as PageView.pageSnapping does for pages: a carousel of cards.');

  static const List<PropDef<Object?>> all = [scrollable, scrollDirection, reverse, physics, alwaysScroll, clipBehavior, itemSnapping];
}
