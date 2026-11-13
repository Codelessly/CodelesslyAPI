// The media library's action types as declared fields, for generated
// editors (see core/action_fields.dart).
import '../../core/props.dart';
import 'actions.dart';

/// [PrintAction].
abstract final class PrintFields {
  static const node = PropDef<String>('node', Codecs.string, '', doc: 'A rendered node to print through a user-confirmed platform dialog.');
  static const List<PropDef<Object?>> all = [node];
}

/// [PreloadImagesAction].
abstract final class PreloadImagesFields {
  static const urls = PropDef<String>('urls', Codecs.string, '', doc: 'The image URLs: a list (an expression) or comma-separated text.');
  static const progressVariable = PropDef<String>('progressVariable', Codecs.string, '',
      doc: 'A variable to hold the share loaded (0-1) while it runs.');
  static const List<PropDef<Object?>> all = [urls, progressVariable];
}

/// [SpeakAction].
abstract final class SpeakFields {
  static const text = PropDef<String>('text', Codecs.string, '');
  static const language = PropDef<String>('language', Codecs.string, '');
  static const rate = PropDef<String>('rate', Codecs.string, '1', doc: 'A number or expression.');
  static const pitch = PropDef<String>('pitch', Codecs.string, '', doc: 'A number or expression.');
  static const stop = PropDef<bool>('stop', Codecs.bool, false, doc: 'Stops speaking.');
  static const readAlong = PropDef<bool>('readAlong', Codecs.bool, false,
      doc: 'Times every word (speech.wordIndex) even when the voice reports no word boundaries, '
          'and reads along silently without a voice; the action waits until the text is said.');
  static const startWord = PropDef<String>('startWord', Codecs.string, '',
      doc: 'Read along: the word to start at (an index or expression), to carry on after a pause.');
  static const List<PropDef<Object?>> all = [text, language, rate, pitch, stop, readAlong, startWord];
}

/// [PlaySoundAction].
abstract final class PlaySoundFields {
  static const sound = PropDef<String>('sound', Codecs.string, 'wood', doc: 'A synthesised voice name.');
  static const operation = PropDef<String>('operation', Codecs.string, 'play', doc: 'play, start, stop, or stopAll.');
  static const voiceId = PropDef<String>('voiceId', Codecs.string, '', doc: 'The independently owned sustained voice.');
  static const frequency = PropDef<String>('frequency', Codecs.string, '440', doc: 'Sustained tone frequency in hertz.');
  static const waveform = PropDef<String>('waveform', Codecs.string, 'sine',
      doc: 'Sustained voice: sine, triangle, square, sawtooth, felt, reed or pluck.');
  static const note = PropDef<String>('note', Codecs.string, '', doc: 'A MIDI note number (60 = middle C) in place of frequency.');
  static const duration = PropDef<String>('duration', Codecs.string, '', doc: 'Milliseconds until a started voice releases itself; empty sustains.');
  static const volume = PropDef<String>('volume', Codecs.string, '1');
  static const pitch = PropDef<String>('pitch', Codecs.string, '1');
  static const at = PropDef<String>('at', Codecs.string, '', doc: 'A time on the sound clock.');
  static const url = PropDef<String>('url', Codecs.string, '', doc: 'A sound file.');
  static const List<PropDef<Object?>> all = [sound, operation, voiceId, frequency, waveform, note, duration, volume, pitch, at, url];
}

/// [CaptureScreenshotAction].
abstract final class CaptureScreenshotFields {
  static const target = PropDef<CaptureTarget>('target', EnumCodec(CaptureTarget.values), CaptureTarget.layout,
      doc: 'The screen, one of its nodes, or the whole app (in the host\'s capture scope).');
  static const node = PropDef<String>('node', Codecs.string, '', doc: 'The node captured (target node).');
  static const pixelRatio = PropDef<double>('pixelRatio', Codecs.double, 0, doc: 'Pixels per logical pixel; 0: the device\'s.');
  static const List<PropDef<Object?>> all = [target, node, pixelRatio];
}

/// [DownloadFileAction].
abstract final class DownloadFileFields {
  static const fileName = PropDef<String>('fileName', Codecs.string, 'export.txt', doc: 'Suggested filename, an expression.');
  static const text = PropDef<String>('text', Codecs.string, '', doc: 'Generated file contents as UTF-8 text.');
  static const mimeType = PropDef<String>('mimeType', Codecs.string, 'text/plain');
  static const List<PropDef<Object?>> all = [fileName, text, mimeType];
}
