import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('Double tap and hover triggers survive JSON', () {
    for (final type in [
      TriggerType.doubleTap,
      TriggerType.cursorEnter,
      TriggerType.cursorExit,
    ]) {
      final reaction = Reaction(
        trigger: TriggerModel(type: type),
        action: CallFunctionAction(name: 'f'),
      );
      final json = reaction.toJson();
      expect(json['trigger'], {'type': type.name});
      expect(Reaction.fromJson(json).trigger.type, type);
    }
    expect(TriggerType.doubleTap.prettify, 'Double Tap');
  });

  test(
    'Trigger JSON with the earlier hover names reads as cursor triggers',
    () {
      expect(
        TriggerModel.fromJson({'type': 'hoverEnter'}).type,
        TriggerType.cursorEnter,
      );
      expect(
        TriggerModel.fromJson({'type': 'hoverExit'}).type,
        TriggerType.cursorExit,
      );
      expect(TriggerType.hovers, [
        TriggerType.cursorEnter,
        TriggerType.cursorExit,
      ]);
    },
  );

  test('Shapes, buttons, icons and sliders offer the new triggers', () {
    final box = NodeBox(0, 0, 10, 10);
    final frame = FrameNode(
      id: 'f',
      name: 'f',
      basicBoxLocal: box,
      children: const [],
    );
    final rect = RectangleNode(id: 'r', name: 'r', basicBoxLocal: box);
    final slider = SliderNode(
      id: 's',
      name: 's',
      basicBoxLocal: box,
      value: 0,
      properties: SliderProperties(),
    );
    for (final ReactionMixin node in [frame, rect]) {
      expect(
        node.triggerTypes,
        containsAll([
          TriggerType.click,
          TriggerType.doubleTap,
          ...TriggerType.hovers,
        ]),
      );
    }
    expect(slider.triggerTypes.first, TriggerType.changed);
    expect(slider.triggerTypes, contains(TriggerType.doubleTap));
    expect(
      slider.propertyVariables.map((v) => v.name),
      containsAll(['value', 'min', 'max']),
    );
  });

  test('Slider orientation, inversion and thumb stroke survive JSON', () {
    final props = SliderProperties(
      min: -8,
      max: 8,
      orientation: AxisC.vertical,
      inverted: true,
      thumbStrokeColor: ColorRGBA.white,
      thumbStrokeWidth: 2,
    );
    final json = props.toJson();
    expect(json['orientation'], 'vertical');
    expect(json['inverted'], true);
    expect(json['thumbStrokeWidth'], 2);
    expect(json['thumbStrokeColor'], isNotNull);
    final back = SliderProperties.fromJson(json);
    expect(back, props);

    final defaults = SliderProperties().toJson();
    for (final key in [
      'orientation',
      'inverted',
      'thumbStrokeWidth',
      'thumbStrokeColor',
    ]) {
      expect(defaults.containsKey(key), isFalse, reason: key);
    }
    expect(SliderProperties.fromJson({}).orientation, AxisC.horizontal);
  });
}
