import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// The JSON of Lamplight's interaction gaps: drag tracks without a
/// variable, with hit areas, parent units and keyboard/wheel/double-tap
/// settings; the animateVariable action; per-button confirm styles.
void main() {
  test('a track without a variable reads and leaves it out', () {
    final DragTrackModel t = DragTrackModel.fromJson({'shape': 'arc'});
    expect(t.variable, '');
    expect(t.hasVariable, isFalse);
    expect(t.toJson().containsKey('variable'), isFalse);
  });

  test('new track fields round-trip and default out', () {
    const DragTrackModel knob = DragTrackModel(
      shape: DragTrackShape.arc,
      max: 100,
      input: DragTrackInput.both,
      hitArea: DragTrackHitArea.parent,
      units: DragTrackUnits.parent,
      wheelStep: 2,
      keyStep: 5,
      doubleTapValues: [100, 50],
    );
    final Map json = knob.toJson();
    expect(json['input'], 'both');
    expect(json['hitArea'], 'parent');
    expect(json['units'], 'parent');
    expect(json['doubleTapValues'], [100.0, 50.0]);
    expect(DragTrackModel.fromJson(json), knob);
    final Map plain = const DragTrackModel(variable: 'v').toJson();
    for (final String key in [
      'hitArea',
      'units',
      'doubleTapValues',
      'wheelStep',
      'keyStep',
    ]) {
      expect(plain.containsKey(key), isFalse, reason: key);
    }
  });

  test('double tap cycles its values, else resets', () {
    const DragTrackModel t = DragTrackModel(max: 100, doubleTapValues: [100, 50]);
    expect(t.doubleTapTarget(30), 100);
    expect(t.doubleTapTarget(100), 50);
    expect(const DragTrackModel(defaultValue: 0.5).doubleTapTarget(1), 0.5);
    expect(const DragTrackModel().doubleTapTarget(1), isNull);
  });

  test('bound geometry replaces fields; unparseable values keep them', () {
    const DragTrackModel t = DragTrackModel(x2: 10, y2: 0);
    final DragTrackModel b = t.withBound({'x2': '240', 'y2': 'oops', 'min': 3});
    expect(b.x2, 240);
    expect(b.y2, 0);
    expect(b.min, 3);
  });

  test('animateVariable reads numbers as text and omits defaults', () {
    final ActionModel action = ActionModel.fromJson({
      'type': 'animateVariable',
      'variable': 'sunriseT',
      'mode': 'resume',
      'from': 0,
      'to': 1,
      'durationMs': 12000,
      'duration': r'${= sunrise.previewSeconds * 1000}',
      'curve': 'easeInOut',
      'nonBlocking': true,
    });
    expect(action, isA<AnimateVariableAction>());
    final AnimateVariableAction a = action as AnimateVariableAction;
    expect(a.mode, AnimateVariableMode.resume);
    expect([a.from, a.to, a.durationMs], ['0', '1', 12000]);
    expect(a.curve, MotionCurve.easeInOut);
    expect(ActionModel.fromJson(a.toJson()), a);
    expect(AnimateVariableAction(variable: 'x').toJson(), {
      'type': 'animateVariable',
      'variable': 'x',
    });
    // An unknown mode plays.
    expect(
      (ActionModel.fromJson({'type': 'animateVariable', 'mode': 'rewind'})
              as AnimateVariableAction)
          .mode,
      AnimateVariableMode.play,
    );
  });

  test('confirm per-button borders and icon round-trip', () {
    final ConfirmAction action = ConfirmAction.fromJson({
      'type': 'confirm',
      'title': 'Take it down?',
      'confirmBorder': {'color': '#B04A3A', 'width': 1.5},
      'cancelBorder': {'color': '#D2C0AC', 'width': 1},
      'iconDiscColor': '#EDE6DC',
      'iconDiscBorder': {'color': '#D2C0AC', 'width': 1},
      'iconSize': 27,
      'centered': true,
      'expandButtons': true,
    });
    expect(action.confirmBorder!.width, 1.5);
    expect(action.cancelBorder, isNotNull);
    expect(action.iconSize, 27);
    expect(action.centered, isTrue);
    expect(ConfirmAction.fromJson(action.toJson()), action);
    expect(
      ConfirmAction.bindableColors,
      containsAll(['confirmBorderColor', 'cancelBorderColor', 'iconDiscColor']),
    );
  });
}
