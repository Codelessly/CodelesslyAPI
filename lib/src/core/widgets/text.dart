import '../behavior_fields.dart' show AnimationCurveCodec;
import '../behaviors.dart' show AnimationCurve;
import '../props.dart';
import '../values/enums.dart';
import '../values/text.dart';

/// `Text.rich`: a string with styled runs.
abstract final class TextProps {
  /// The text shown. May hold expressions: `"Hello, ${user.name}"`.
  static const text = PropDef<String>('text', Codecs.string, '');

  /// Base style for the whole text.
  static const style = PropDef<TextStyle>('style', Codecs.textStyle, TextStyle.empty);

  /// Styled ranges over [text], merged over [style].
  static const runs = PropDef<List<TextRun>>('runs', Codecs.textRuns, []);
  /// How lines are aligned inside the node's width (Flutter's `TextAlign`).
  static const textAlign = PropDef<TextAlign>('textAlign', EnumCodec(TextAlign.values), TextAlign.start);
  /// Where the lines sit when the node is taller than they are.
  static const textAlignVertical =
      PropDef<TextAlignVertical>('textAlignVertical', EnumCodec(TextAlignVertical.values), TextAlignVertical.top);
  /// At most this many lines; the rest is cut as `overflow` says. Null: no limit.
  static const maxLines = PropDef<int?>('maxLines', OptionalIntCodec(), null);
  /// What shows where the text is cut by `maxLines` or the node's size (Flutter's `TextOverflow`): `clip`, `fade`,
  /// `ellipsis`, `visible`.
  static const overflow = PropDef<TextOverflow>('overflow', EnumCodec(TextOverflow.values), TextOverflow.clip);
  /// The user can select and copy the text (Flutter's `SelectableText`).
  static const selectable = PropDef<bool>('selectable', Codecs.bool, false);

  /// Shrinks the whole text to fit its width, keeping its lines
  /// (`FittedBox(fit: BoxFit.scaleDown)`).
  static const scaleDown = PropDef<bool>('scaleDown', Codecs.bool, false);

  /// A number in the text (after binding: "1,204", "\$12.50", "87%") counts
  /// up to each new value in a running app, from the value on screen; the
  /// characters around it, its decimals and its thousands separators stay.
  /// A design canvas (or TickerMode off) shows the final text.
  static const countUp = PropDef<bool>('countUp', Codecs.bool, false);

  /// Milliseconds of one count.
  static const countUpDuration = PropDef<int>('countUpDuration', IntCodec(min: 0), 500);
  /// The curve a number in the text counts up along when it changes.
  static const countUpCurve =
      PropDef<AnimationCurve>('countUpCurve', AnimationCurveCodec(), AnimationCurve.linear);

  /// The first value counts up from 0 when the text first shows; off, it
  /// shows at rest and only later changes count.
  static const countUpOnShow = PropDef<bool>('countUpOnShow', Codecs.bool, true);

  static const spec = WidgetSpec('text',
      props: [
        text, style, runs, textAlign, textAlignVertical, maxLines, overflow, selectable, scaleDown, //
        countUp, countUpDuration, countUpCurve, countUpOnShow,
      ],
      doc: 'Flutter `Text.rich`.');
}
