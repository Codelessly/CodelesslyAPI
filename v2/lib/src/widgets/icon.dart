import '../json.dart';
import '../props.dart';
import '../values/color.dart';

Json? _iconIn(Object? j) => readMap(j);
Object? _iconOut(Json j) => j;

/// Flutter `Icon` (font icons) or an SVG/image icon.
abstract final class IconProps {
  /// Which glyph: `{"font": "material"|"symbols"|"cupertino", "name", "codepoint", "style"}`
  /// or `{"svg": url}` / `{"image": url}`.
  static const icon = PropDef<Json>('icon', ValueCodec(_iconIn, _iconOut), {});
  static const color = PropDef<Color?>('color', ValueCodec(Color.fromJson, _colorOut), null);
  static const spec = WidgetSpec('icon', props: [icon, color], doc: 'Flutter `Icon`.');
}

Object? _colorOut(Color? c) => c?.toJson();
