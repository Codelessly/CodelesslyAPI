// Published components (docs/design/06 §4.7): the model's `components`
// entries, each layout's closure, the stored component and the bundle's
// `components` map.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

const card = {
  'schema': 2,
  'id': 'Card',
  'roots': ['card'],
  'widget': {
    'type': 'Card',
    'props': [
      {'key': 'title', 'type': {'kind': 'string'}, 'default': ''},
    ],
  },
  'nodes': {
    'card': {'type': 'column', 'children': ['t']},
    't': {'type': 'text', 'props': {'text': r'${props.title}'}},
  },
};

void main() {
  test('the stored component round-trips, its document a component document', () {
    final c = PublishComponent.fromJson({
      'schema': 2,
      'id': 'Card',
      'version': 3,
      'digest': 'abc',
      'lastUpdated': 1000,
      'fonts': ['Inter/400/false'],
      'document': card,
      'owner': 'u1',
    });
    expect(c.id, 'Card');
    expect(c.isComponent, isTrue);
    expect(c.document.componentType, 'Card');
    expect(c.version, 3);
    expect(c.lastUpdated, DateTime.fromMillisecondsSinceEpoch(1000, isUtc: true));
    expect(c.extra, {'owner': 'u1'});
    final again = PublishComponent.fromJson(c.toJson());
    expect(again.toJson(), c.toJson());
    expect(again.document.extra[kWidgetKey], card['widget']);
  });

  test('decoding is lenient: a missing document is an empty one, the id falls back to the key', () {
    final c = PublishComponent.fromJson({'version': 'x'}, id: 'Ghost');
    expect(c.id, 'Ghost');
    expect(c.isComponent, isFalse);
    expect(c.version, 0);
    expect(PublishComponent.fromJson(null).isComponent, isFalse);
  });

  test('canonicalJson: one text whatever the key order, whole doubles as integers', () {
    expect(canonicalJson({'b': 1, 'a': [2.0, {'d': null, 'c': 'x'}]}), '{"a":[2,{"c":"x","d":null}],"b":1}');
    expect(canonicalJson({'a': 1.5}), '{"a":1.5}');
    final reordered = {
      'nodes': card['nodes'],
      'widget': card['widget'],
      'roots': card['roots'],
      'id': 'Card',
      'schema': 2,
    };
    expect(canonicalJson(reordered), canonicalJson(card));
    expect(PublishComponent(document: LayoutDocument.fromJson(card)).digestInput, canonicalJson(LayoutDocument.fromJson(card).toJson()));
  });

  test('a stored component keeps its document as stored: written back and digested as the publisher wrote it', () {
    final raw = {...card, 'nodes': {...card['nodes']! as Map, 'extra': {'type': 'box', 'zzz': 1}}};
    final c = PublishComponent.fromJson({'schema': 2, 'id': 'Card', 'document': raw});
    expect(c.toJson()['document'], raw);
    expect(c.digestInput, canonicalJson(raw));
    expect(c.copyWith(version: 2).digestInput, canonicalJson(raw));
    expect(c.copyWith(document: c.document).digestInput, canonicalJson(c.document.toJson()));
  });

  test('the model lists components and each layout its closure; fonts of called components come with the layout', () {
    final model = PublishModel.fromJson({
      'schema': 2,
      'projectId': 'p',
      'layouts': {
        'home': {'canvases': [{'id': 'home'}], 'fonts': ['a'], 'components': ['Header', 'Button']},
      },
      'fonts': {
        'a': {'family': 'A'},
        'b': {'family': 'B'},
        'c': {'family': 'C'},
      },
      'components': {
        'Header': {'version': 2, 'digest': 'h', 'lastUpdated': 5, 'fonts': ['b', 'a']},
        'Button': {'version': 1, 'digest': 'b', 'fonts': ['c']},
        'Unused': {'version': 1},
      },
    });
    expect(model.components.keys, ['Header', 'Button', 'Unused']);
    expect(model.components['Header']!.version, 2);
    expect(model.components['Header']!.digest, 'h');
    expect(model.layouts['home']!.components, ['Header', 'Button']);
    expect([for (final f in model.fontsOf('home')) f.family], ['A', 'B', 'C']);
    expect(model.extra.containsKey('components'), isFalse);
    expect(PublishModel.fromJson(model.toJson()).toJson(), model.toJson());
    // A model without components writes none.
    expect(PublishModel(projectId: 'p').toJson().containsKey('components'), isFalse);
    expect(const PublishLayoutInfo(id: 'x').toJson().containsKey('components'), isFalse);
  });

  test('the publish path of a component, under each source', () {
    expect(PublishSource.publish.componentPath('p', 'Card'), 'publish/p/components/Card');
    expect(PublishSource.preview.componentPath('p', 'Card'), 'publish_preview/p/components/Card');
  });

  test('a bundle carries its components; one without writes none', () {
    final bundle = PublishBundle.fromJson({
      'schema': 2,
      'model': {'projectId': 'p', 'components': {'Card': {'version': 1}}},
      'layouts': {},
      'components': {
        'Card': {'version': 1, 'document': card},
      },
    });
    expect(bundle.components['Card']!.id, 'Card');
    expect(bundle.components['Card']!.document.componentRoot, 'card');
    expect(PublishBundle.fromJson(bundle.toJson()).toJson(), bundle.toJson());
    expect(PublishBundle(model: PublishModel(projectId: 'p')).toJson().containsKey('components'), isFalse);
  });

  test('PublishComponentInfo.of a stored component', () {
    final c = PublishComponent(document: LayoutDocument.fromJson(card), version: 4, digest: 'd', fonts: const ['f']);
    final info = PublishComponentInfo.of(c);
    expect(info, const PublishComponentInfo(id: 'Card', version: 4, digest: 'd', fonts: ['f']));
  });
}
