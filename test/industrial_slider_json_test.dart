import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('slider marker, fader thumb, notches and range round-trip', () {
    final node = SliderNode(
      id: 's',
      name: 'Limit',
      basicBoxLocal: NodeBox(0, 0, 300, 32),
      value: 75,
      markerValue: 87,
      properties: SliderProperties(
        thumbShape: SliderThumbShapeEnum.rectangle,
        thumbWidth: 14,
        thumbHeight: 24,
        thumbBorderColor: ColorRGBA.black,
        thumbGripColor: ColorRGBA.black,
        fillFromEnd: true,
        tickMarkStyle: SliderTickMarkStyle.notch,
        notchEvery: 2,
        markerColor: ColorRGBA.white,
        selectableMin: 5,
        selectableMax: 95,
      ),
    );
    final back = NodeJsonConverter.instance.fromJson(node.toJson()) as SliderNode;
    expect(back.markerValue, 87);
    expect(back.properties, node.properties);
    expect(back.triggerTypes, contains(TriggerType.changeEnd));
  });

  test('a slider from before keeps its defaults', () {
    final json = SliderNode(
      id: 's',
      name: 's',
      basicBoxLocal: NodeBox(0, 0, 300, 48),
      value: 1,
      properties: SliderProperties(),
    ).toJson();
    expect(json.containsKey('markerValue'), isFalse);
    expect((json['properties'] as Map).containsKey('thumbShape'), isFalse);
  });
}
