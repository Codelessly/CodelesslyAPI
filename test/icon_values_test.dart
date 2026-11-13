// An icon is written the same way wherever it goes: the icon node's
// props.icon and an input's InputIcon both read a Material icon name, the
// typed object, and an untyped {"name": ...}.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

void main() {
  const material = {'type': 'MATERIAL_ICON', 'name': 'search', 'style': 'filled'};
  test('an input icon given as a name reads as the icon prop does', () {
    expect(InputIcon.fromJson({'icon': 'search'})!.icon, material);
    expect(Node.fromJson({'type': 'icon', 'props': {'icon': 'search'}}, id: 'i')!.prop(IconProps.icon), material);
  });
  test('an icon given only by name is the Material icon of that name', () {
    expect(InputIcon.fromJson({'icon': {'name': 'search'}})!.icon, material);
    expect(Node.fromJson({'type': 'icon', 'props': {'icon': {'name': 'menu', 'style': 'rounded'}}}, id: 'i')!.prop(IconProps.icon),
        {'type': 'MATERIAL_ICON', 'name': 'menu', 'style': 'rounded'});
  });
  test('a text field\'s prefixIcon as a name validates', () {
    final d = {
      'schema': 4,
      'roots': ['c'],
      'nodes': {
        'c': {'type': 'canvas', 'layout': {'width': 390, 'height': 844}, 'slots': {'body': 'f'}},
        'f': {
          'type': 'textField',
          'layout': {'width': {'fill': 390}, 'height': 48},
          'props': {
            'decoration': {'prefixIcon': {'icon': 'search', 'size': 18}},
          },
        },
      },
    };
    expect(validateDocument(d), isEmpty);
  });
}
