import '../json.dart';
import '../props.dart';
import '../values/color.dart';


/// Flutter `Icon` (font icons) or an SVG/image icon.
abstract final class IconProps {
  /// Which glyph: `{"type":"MATERIAL_ICON"|"MATERIAL_SYMBOL", "name", "style"}`
  /// or `{"type":"CUPERTINO_ICON", "codepoint"}`. Image icons use
  /// `{"source":"image", "image":url}`.
  static const icon = PropDef<Json>('icon', Codecs.icon, {},
      doc: 'Which glyph: a Material icon name, `"check_circle"` (a style by suffix: `"search_rounded"`), the one form '
          'to write everywhere (an icon node, an input\'s `prefixIcon`). Also read: an image URL, and the object forms '
          'of older documents (`{"type": "MATERIAL_ICON", "name", "style"}`, `{"type": "CUPERTINO_ICON", "codepoint"}`).');
  /// The glyph's colour (`"#AARRGGBB"` or a theme colour's name).
  static const color = PropDef<Color?>('color', Codecs.optionalColor, null);

  /// Flutter's `Icon.size`: the glyph's extent (square).
  static const size = PropDef<double?>('size', OptionalDoubleCodec(min: 0), null,
      doc: 'Flutter `Icon.size`: the glyph\'s width and height. Unset, the glyph fills the node\'s box (contained, centred), '
          'as before. Set, the glyph is drawn at this size, centred in the node\'s box (at most the box), and a hugging axis '
          'of the node takes it (`{"hug": 24}` with `"size": 18` is 18 wide).');
  static const spec = WidgetSpec('icon', props: [icon, color, size], doc: 'Flutter `Icon`.');
}

