import '../json.dart';
import '../props.dart';
import '../values/color.dart';


/// Flutter `Icon` (font icons) or an SVG/image icon.
abstract final class IconProps {
  /// Which glyph: `{"font": "material"|"symbols"|"cupertino", "name", "codepoint", "style"}`
  /// or `{"svg": url}` / `{"image": url}`.
  static const icon = PropDef<Json>('icon', Codecs.icon, {});
  static const color = PropDef<Color?>('color', Codecs.optionalColor, null);
  static const spec = WidgetSpec('icon', props: [icon, color], doc: 'Flutter `Icon`.');
}

