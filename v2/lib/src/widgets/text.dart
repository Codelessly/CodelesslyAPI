import '../props.dart';
import '../values/enums.dart';
import '../values/text.dart';

/// `Text.rich`: a string with styled runs.
abstract final class TextProps {
  static const text = PropDef<String>('text', Codecs.string, '');

  /// Base style for the whole text.
  static const style = PropDef<TextStyle>('style', Codecs.textStyle, TextStyle.empty);

  /// Styled ranges over [text], merged over [style].
  static const runs = PropDef<List<TextRun>>('runs', Codecs.textRuns, []);
  static const textAlign = PropDef<TextAlign>('textAlign', EnumCodec(TextAlign.values), TextAlign.start);
  static const textAlignVertical =
      PropDef<TextAlignVertical>('textAlignVertical', EnumCodec(TextAlignVertical.values), TextAlignVertical.top);
  static const maxLines = PropDef<int?>('maxLines', OptionalIntCodec(), null);
  static const overflow = PropDef<TextOverflow>('overflow', EnumCodec(TextOverflow.values), TextOverflow.clip);
  static const selectable = PropDef<bool>('selectable', Codecs.bool, false);

  static const spec = WidgetSpec('text',
      props: [text, style, runs, textAlign, textAlignVertical, maxLines, overflow, selectable],
      doc: 'Flutter `Text.rich`.');
}
