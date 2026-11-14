// A state patch names the node it patches by id. Schema-2 documents from the
// reference generators wrote `self` and `@<key>`, which matched no node:
// the migration resolves them to the id they mean, and validation names the
// id when a schema-3 document still writes them.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

Json _doc(int schema, Map<String, Object?> nodes) => {
      'schema': schema,
      'roots': ['root'],
      'nodes': {
        'root': {'type': 'stack', 'layout': <String, Object?>{}, 'children': [...nodes.keys]},
        ...nodes,
      },
    };

Json _states(Json doc, String id) => ((doc['nodes'] as Map)[id] as Map)['states'] as Json;

void main() {
  group('migration (states.target)', () {
    test('a pressed patch on "self" becomes a patch of the node itself, and its scale now applies', () {
      final report = MigrationReport(document: 't');
      final out = migrate2to3(_doc(2, {
        'card': {
          'type': 'box',
          'layout': <String, Object?>{},
          'states': {
            'pressed': {
              'self': {'motion': {'scale': 0.97}},
            },
          },
        },
      }), report: report);
      expect(_states(out, 'card'), {
        'pressed': {
          'card': {'motion': {'scale': 0.97}},
        },
      });
      final node = LayoutDocument.fromJson(out).nodes['card']!;
      final pressed = node.patched(node.behaviors.states.patchFor('card', {WidgetState.pressed})!);
      expect(pressed.behaviors.motion!.scale, 0.97);
      expect(report.entries.where((e) => e.step == 'states.target').map((e) => e.kind),
          containsAll([MigrationEntryKind.rewrite, MigrationEntryKind.behaviorChange]));
    });

    test('"@key" naming the node\'s own key becomes its id', () {
      final out = migrate2to3(_doc(2, {
        'b1': {
          'type': 'box',
          'key': 'button_16',
          'layout': <String, Object?>{},
          'states': {
            'hovered': {
              '@button_16': {'motion': {'translateY': -2}},
            },
          },
        },
      }));
      expect(_states(out, 'b1'), {
        'hovered': {
          'b1': {'motion': {'translateY': -2}},
        },
      });
    });

    test('"@key" naming one other node by its key becomes that node\'s id', () {
      final out = migrate2to3(_doc(2, {
        'card': {
          'type': 'box',
          'layout': <String, Object?>{},
          'children': ['label'],
          'states': {
            'hovered': {
              '@title': {'opacity': 0.5},
            },
          },
        },
        'label': {'type': 'text', 'key': 'title', 'layout': <String, Object?>{}, 'props': {'text': 'Hi'}},
      }));
      expect((_states(out, 'card')['hovered'] as Map).keys, ['label']);
    });

    test('a resolved patch merges over a patch of the same node by id', () {
      final out = migrate2to3(_doc(2, {
        'card': {
          'type': 'box',
          'layout': <String, Object?>{},
          'states': {
            'hovered': {
              'card': {'opacity': 0.5, 'visible': true},
              'self': {'opacity': 0.8},
            },
          },
        },
      }));
      expect(_states(out, 'card')['hovered'], {
        'card': {'opacity': 0.8, 'visible': true},
      });
    });

    test('a target that names no node by any spelling is left as written', () {
      final out = migrate2to3(_doc(2, {
        'card': {
          'type': 'box',
          'layout': <String, Object?>{},
          'states': {
            'hovered': {
              '@nobody': {'opacity': 0.5},
            },
          },
        },
      }));
      expect((_states(out, 'card')['hovered'] as Map).keys, ['@nobody']);
    });

    test('a node migrated alone resolves "self" to its own id', () {
      final out = migrateNode2to3({
        'id': 'chip',
        'type': 'box',
        'states': {
          'selected': {
            'self': {'opacity': 1},
          },
        },
      });
      expect((out['states'] as Map)['selected'], {
        'chip': {'opacity': 1},
      });
    });
  });

  group('validation of a schema-3 document', () {
    List<Diagnostic> targetErrors(Json doc) => [
          for (final d in validateDocument(doc))
            if (d.code == Codes.unknownTargetNode) d,
        ];

    test('"self" is refused with the node\'s own id as the form to write', () {
      final d = targetErrors(_doc(3, {
        'card': {
          'type': 'box',
          'layout': <String, Object?>{},
          'states': {
            'hovered': {
              'self': {'opacity': 0.5},
            },
          },
        },
      })).single;
      expect(d.path, '/nodes/card/states/hovered/self');
      expect(d.message, contains('this node is "card"'));
      expect(d.suggestion, 'card');
    });

    test('"@key" is refused with the id of the node that has that key', () {
      final d = targetErrors(_doc(3, {
        'b1': {
          'type': 'box',
          'key': 'button',
          'layout': <String, Object?>{},
          'states': {
            'pressed': {
              '@button': {'opacity': 0.5},
            },
          },
        },
      })).single;
      expect(d.message, contains('write "b1"'));
      expect(d.suggestion, 'b1');
    });

    test('an unknown id is still refused and names the form', () {
      final d = targetErrors(_doc(3, {
        'card': {
          'type': 'box',
          'layout': <String, Object?>{},
          'states': {
            'hovered': {
              'crad': {'opacity': 0.5},
            },
          },
        },
      })).single;
      expect(d.message, contains('No node "crad"'));
      expect(d.message, contains('by node id'));
    });
  });
}
