// A list given its data= and an each right under it repeats twice: every
// item drew the whole list again (two turns showed four). Said.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

void main() {
  const head = 'state turns=[{"id":1,"t":"a"},{"id":2,"t":"b"}]\nColumn\n';

  test('data= and an each under it: said', () {
    final r = parseNotation('${head}  ListView#transcript data={turns} h=300\n    each record in turns\n      Text "{record.t}"\n', catalog: standardCatalog);
    expect(r.issues.single.message, startsWith('This ListView repeats the line under it for each item of its data= already'));
  });

  test('one or the other: nothing to say', () {
    expect(parseNotation('${head}  ListView#transcript data={turns} h=300\n    Text "{item.t}"\n', catalog: standardCatalog).issues, isEmpty);
    expect(parseNotation('${head}  ListView#transcript h=300\n    each record in turns\n      Text "{record.t}"\n', catalog: standardCatalog).issues, isEmpty);
  });

  test('several lines under the each: still said beside data=; without data= they are one item', () {
    final both = parseNotation('${head}  ListView#transcript data={turns} h=300\n    each record in turns\n      Text "{record.t}"\n      Text "{record.id}"\n', catalog: standardCatalog);
    expect(both.issues.map((i) => i.message), contains(startsWith('This ListView repeats the line under it for each item of its data= already')));
    final each = parseNotation('${head}  ListView#transcript h=300\n    each record in turns\n      Text#a "{record.t}"\n      Text#b "{record.id}"\n', catalog: standardCatalog);
    expect(each.issues, isEmpty);
    final nodes = each.document['nodes'] as Map;
    final list = nodes.values.cast<Map>().singleWhere((n) => n['type'] == 'listView');
    final item = nodes[(list['children'] as List).single] as Map;
    expect(item['children'], ['a', 'b']);
  });
}
