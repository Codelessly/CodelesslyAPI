// A site manifest's `variables` in the forms an author writes them: a list
// of records or an object of name to value, with or without a type.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  Map<String, Variable> read(Object? variables) => {for (final v in SiteManifest.fromJson({'variables': variables}).variables) v.name: v};

  test('the map form: a name and its value, typed by the value', () {
    final vs = read({
      'cart': [],
      'plan': 'pro',
      'count': 3,
      'price': 2.5,
      'open': true,
      'user': {'name': 'Ada'},
      'empty': {},
    });
    expect(vs['cart']!.type, VariableType.list);
    expect(vs['cart']!.value, isEmpty);
    expect(vs['plan']!.type, VariableType.text);
    expect(vs['plan']!.value, 'pro');
    expect(vs['count']!.type, VariableType.integer);
    expect(vs['count']!.value, 3);
    expect(vs['price']!.type, VariableType.decimal);
    expect(vs['open']!.value, true);
    expect(vs['user']!.type, VariableType.map);
    expect(vs['user']!.value, {'name': 'Ada'});
    expect(vs['empty']!.type, VariableType.map);
  });

  test('the map form: a record without its name', () {
    final vs = read({
      'draft': {'value': '', 'persist': true},
      'total': {'type': 'decimal', 'value': 4},
      'items': {'value': [1, 2]},
      'double': {'formula': 'count * 2', 'type': 'integer'},
    });
    expect(vs['draft']!.persist, isTrue);
    expect(vs['draft']!.type, VariableType.text);
    expect(vs['total']!.type, VariableType.decimal);
    expect(vs['total']!.value, 4.0);
    expect(vs['items']!.type, VariableType.list);
    expect(vs['double']!.formula, 'count * 2');
  });

  test('the list form without a type has the type of its value', () {
    final vs = read([
      {'name': 'cart', 'value': []},
      {'name': 'count', 'value': 2},
      {'name': 'on', 'value': false},
      {'name': 'title', 'value': 'x'},
      {'name': 'typed', 'type': 'text', 'value': 2},
    ]);
    expect(vs['cart']!.type, VariableType.list);
    expect(vs['cart']!.value, isA<List>());
    expect(vs['count']!.value, 2);
    expect(vs['on']!.type, VariableType.boolean);
    expect(vs['title']!.type, VariableType.text);
    expect(vs['typed']!.value, '2', reason: 'a type that is written is kept');
  });

  test('what it reads is written back as a list that reads the same', () {
    final m = SiteManifest.fromJson({
      'variables': {'cart': [], 'n': 1},
    });
    expect(SiteManifest.fromJson(m.toJson()).variables, m.variables);
  });

  test('anything else declares nothing, and does not throw', () {
    expect(read('cart'), isEmpty);
    expect(read(3), isEmpty);
    expect(read([1, 'x', {'value': 2}]), isEmpty);
  });

  test('a page variable with no type has its value\'s too', () {
    expect(Variable.fromJson({'name': 'rows', 'value': []})!.type, VariableType.list);
  });
}
