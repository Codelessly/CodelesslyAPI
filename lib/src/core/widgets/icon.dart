import '../json.dart';
import '../props.dart';
import '../values/color.dart';


/// Flutter `Icon` (font icons) or an SVG/image icon.
abstract final class IconProps {
  /// Which glyph: `{"type":"MATERIAL_ICON"|"MATERIAL_SYMBOL", "name", "style"}`
  /// or `{"type":"CUPERTINO_ICON", "codepoint"}`. Image icons use
  /// `{"source":"image", "image":url}`.
  static const icon = PropDef<Json>('icon', Codecs.icon, {});
  static const color = PropDef<Color?>('color', Codecs.optionalColor, null);
  static const spec = WidgetSpec('icon', props: [icon, color], doc: 'Flutter `Icon`.');
}

