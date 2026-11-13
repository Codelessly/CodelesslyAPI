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
  static const color = PropDef<Color?>('color', Codecs.optionalColor, null);
  static const spec = WidgetSpec('icon', props: [icon, color], doc: 'Flutter `Icon`.');
}

