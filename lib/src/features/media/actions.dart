// The media library's action types: speech, sound, images, capture, print and file downloads. One immutable
// class per type, decoded through its ActionSpec ([mediaActionSpecs]); the
// SDK's media feature runs them.

import 'action_fields.dart';
import '../../core/actions.dart';
import '../../core/catalog.dart';
import '../../core/json.dart';

/// The fields every action has.
typedef _Common = ActionCommon;

// Reading an action's fields: the core's rules (core/actions.dart).
String _s(Json m, String k, [String def = '']) => switch (m[k]) {
  final String s => s,
  final num n => '$n',
  final bool b => '$b',
  _ => def,
};
double _d(Json m, String k, double def) => readDouble(m[k]) ?? def;
bool _b(Json m, String k, bool def) => readBool(m[k]) ?? def;
T _e<T extends Enum>(List<T> values, Json m, String k, T def) => readEnum(values, m[k], def);

/// Exports generated UTF-8 text (CSV, JSON, plain text...) as a file.
/// The browser downloads it; native apps show the platform save picker.
/// Cancellation returns `{saved: false}` as the action result.
final class DownloadFileAction extends MediaAction {
  const DownloadFileAction({this.fileName = 'export.txt', this.text = '', this.mimeType = 'text/plain',
    super.enabled, super.nonBlocking, super.when});

  static const typeName = 'downloadFile';
  @override
  String get type => typeName;
  final String fileName, text, mimeType;

  static DownloadFileAction _fromJson(Json m, _Common c) => DownloadFileAction(
    fileName: _s(m, 'fileName', 'export.txt'), text: _s(m, 'text'), mimeType: _s(m, 'mimeType', 'text/plain'),
    enabled: c.enabled, nonBlocking: c.nonBlocking, when: c.when);
  @override
  Json get fieldsJson => {'fileName': fileName, 'text': text, 'mimeType': mimeType};
}

/// The media library's action types: speech, sound, images, capture, print.
sealed class MediaAction extends ActionDef {
  const MediaAction({super.enabled, super.nonBlocking, super.when});
}

/// Requests the platform print dialog for a rendered node. The user chooses
/// the destination and confirms; this action never silently submits a job.
final class PrintAction extends MediaAction {
  const PrintAction({this.node = '', super.enabled, super.nonBlocking, super.when});
  static const typeName = 'print';
  @override
  String get type => typeName;
  final String node;
  static PrintAction _fromJson(Json m, _Common c) => PrintAction(
    node: _s(m, 'node'), enabled: c.enabled, nonBlocking: c.nonBlocking, when: c.when);
  @override
  Json get fieldsJson => {'node': node};
}

/// Loads images ahead of showing them (a story's pages before reading), so
/// they draw at once: [urls] is an expression giving a list of URLs (or a
/// comma-separated text). While it runs, [progressVariable] (a variable's
/// name; empty for none) holds the share done (0–1). It waits for every image
/// and gives `{loaded, failed, total}`.
final class PreloadImagesAction extends MediaAction {
  const PreloadImagesAction({this.urls = '', this.progressVariable = '', super.enabled, super.nonBlocking, super.when});

  static const typeName = 'preloadImages';
  @override
  String get type => typeName;
  final String urls, progressVariable;

  static PreloadImagesAction _fromJson(Json m, _Common c) => PreloadImagesAction(
    urls: _s(m, 'urls'), progressVariable: _s(m, 'progressVariable'),
    enabled: c.enabled, nonBlocking: c.nonBlocking, when: c.when);
  @override
  Json get fieldsJson => {
    if (urls.isNotEmpty) 'urls': urls,
    if (progressVariable.isNotEmpty) 'progressVariable': progressVariable,
  };
}

/// Reads [text] aloud, or [stop]s speaking. [rate] and [pitch] are numbers
/// or expressions.
///
/// With [readAlong] the words are timed for a read-along highlight
/// (`speech.wordIndex`): the text is said a phrase at a time, each word gets
/// time by its syllables from the moment its phrase starts sounding, and the
/// voice's word boundaries (when it reports them) snap the highlight to the
/// real word and set the pace; without a voice the words are read along
/// silently at that pace. It starts at [startWord] and the action waits until
/// the text has been said (its result: `{completed: bool}`).
final class SpeakAction extends MediaAction {
  const SpeakAction({
    this.text = '',
    this.language = '',
    this.rate = '1',
    this.pitch = '',
    this.stop = false,
    this.readAlong = false,
    this.startWord = '',
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'speak';
  @override
  String get type => typeName;

  final String text, language, rate, pitch, startWord;
  final bool stop, readAlong;

  static SpeakAction _fromJson(Json m, _Common c) => SpeakAction(
    text: _s(m, 'text'),
    language: _s(m, 'language'),
    rate: _s(m, 'rate', '1'),
    pitch: _s(m, 'pitch'),
    stop: _b(m, 'stop', false),
    readAlong: _b(m, 'readAlong', false),
    startWord: _s(m, 'startWord'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get fieldsJson => {
    if (text.isNotEmpty) 'text': text,
    if (language.isNotEmpty) 'language': language,
    if (rate != '1') 'rate': rate,
    if (pitch.isNotEmpty) 'pitch': pitch,
    if (stop) 'stop': true,
    if (readAlong) 'readAlong': true,
    if (startWord.isNotEmpty) 'startWord': startWord,
  };
}

/// Plays a synthesised [sound] (a voice name), now or [at] a time on the
/// sound clock, or the sound file at [url]. Every field is an expression.
final class PlaySoundAction extends MediaAction {
  const PlaySoundAction({
    this.sound = 'wood',
    this.operation = 'play',
    this.voiceId = '',
    this.frequency = '440',
    this.waveform = 'sine',
    this.note = '',
    this.duration = '',
    this.volume = '1',
    this.pitch = '1',
    this.at = '',
    this.url = '',
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'playSound';
  @override
  String get type => typeName;

  final String sound, volume, pitch, at, url;

  /// `play` is the existing one-shot; `start` sustains a tone until `stop`
  /// with the same voiceId. `stopAll` releases the app's sustained tones.
  final String operation, voiceId, frequency;

  /// A sustained voice's sound: `sine` (default), `triangle`, `square`,
  /// `sawtooth`, or an instrument voice with its own envelope and filter:
  /// `felt` (a soft electric piano), `reed` (an organ-like reed) or `pluck`
  /// (a plucked string that dies away on its own).
  final String waveform;

  /// A MIDI note number (60 = middle C, 69 = A 440) for `start`, used in
  /// place of [frequency] when not empty: `${item.midi}`.
  final String note;

  /// Milliseconds after which a `start`ed voice releases by itself (a
  /// latched note, an audition, a metronome tick); empty sustains until
  /// `stop`.
  final String duration;

  static PlaySoundAction _fromJson(Json m, _Common c) => PlaySoundAction(
    sound: _s(m, 'sound', 'wood'),
    operation: _s(m, 'operation', 'play'),
    voiceId: _s(m, 'voiceId'),
    frequency: _s(m, 'frequency', '440'),
    waveform: _s(m, 'waveform', 'sine'),
    note: _s(m, 'note'),
    duration: _s(m, 'duration'),
    volume: _s(m, 'volume', '1'),
    pitch: _s(m, 'pitch', '1'),
    at: _s(m, 'at'),
    url: _s(m, 'url'),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get fieldsJson => {
    if (operation != 'play') 'operation': operation,
    if (voiceId.isNotEmpty) 'voiceId': voiceId,
    if (frequency != '440') 'frequency': frequency,
    if (waveform != 'sine') 'waveform': waveform,
    if (note.isNotEmpty) 'note': note,
    if (duration.isNotEmpty) 'duration': duration,
    if (sound != 'wood') 'sound': sound,
    if (volume != '1') 'volume': volume,
    if (pitch != '1') 'pitch': pitch,
    if (at.isNotEmpty) 'at': at,
    if (url.isNotEmpty) 'url': url,
  };
}

/// What a [CaptureScreenshotAction] captures.
enum CaptureTarget {
  /// The screen the action runs on (its layout, as shown).
  layout,

  /// One node of that screen, as shown ([CaptureScreenshotAction.node]):
  /// an image with a drawing over it, a card.
  node,

  /// The whole app, when the host wraps it in the runtime's capture scope;
  /// else the screen, as [layout].
  app,
}

/// Captures what is on screen as a PNG image. `${result}` is
/// `{"image": "data:image/png;base64,...", "width", "height"}` (in
/// pixels): bind it to an image fill to show it, or upload it with a
/// `cloudFiles` action whose `source` is `${result.image}`. JSON:
/// `{"type": "captureScreenshot", "target": "app"}`.
final class CaptureScreenshotAction extends MediaAction {
  const CaptureScreenshotAction({
    this.target = CaptureTarget.layout,
    this.node = '',
    this.pixelRatio = 0,
    super.enabled,
    super.nonBlocking,
    super.when,
  });

  static const typeName = 'captureScreenshot';
  @override
  String get type => typeName;

  final CaptureTarget target;

  /// [CaptureTarget.node]'s node id.
  final String node;

  /// Image pixels per logical pixel; 0: the device's.
  final double pixelRatio;

  static CaptureScreenshotAction _fromJson(Json m, _Common c) => CaptureScreenshotAction(
    target: _e(CaptureTarget.values, m, 'target', CaptureTarget.layout),
    node: _s(m, 'node'),
    pixelRatio: _d(m, 'pixelRatio', 0),
    enabled: c.enabled,
    nonBlocking: c.nonBlocking,
    when: c.when,
  );

  @override
  Json get fieldsJson => {
    if (target != CaptureTarget.layout) 'target': target.name,
    if (node.isNotEmpty) 'node': node,
    if (pixelRatio != 0) 'pixelRatio': writeDouble(pixelRatio),
  };
}

/// The media library's action types ([MediaAction]).
const List<ActionSpec> mediaActionSpecs = [
  ActionSpec(PrintAction.typeName, label: 'Print', fields: PrintFields.all, decode: PrintAction._fromJson, requires: ['print']),
  ActionSpec(PreloadImagesAction.typeName, label: 'Preload images', fields: PreloadImagesFields.all, decode: PreloadImagesAction._fromJson, requires: ['network']),
  ActionSpec(SpeakAction.typeName, label: 'Speak', fields: SpeakFields.all, decode: SpeakAction._fromJson, requires: ['speech']),
  ActionSpec(PlaySoundAction.typeName, label: 'Play sound', fields: PlaySoundFields.all, decode: PlaySoundAction._fromJson, requires: ['sound']),
  ActionSpec(CaptureScreenshotAction.typeName, label: 'Capture screenshot', fields: CaptureScreenshotFields.all, decode: CaptureScreenshotAction._fromJson, requires: ['capture']),
  ActionSpec(DownloadFileAction.typeName, label: 'Download file', fields: DownloadFileFields.all, decode: DownloadFileAction._fromJson, requires: ['files']),
];
