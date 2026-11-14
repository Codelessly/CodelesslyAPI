// The levels of the vocabulary (docs/design/12-agent-first-flutter.md §3):
// every declared thing has a level, a catalog cut to a level is closed, and
// the validator reports what a document uses above the level it is given.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/src/core/levels.dart';
import 'package:codelessly_api/validate.dart';
import 'package:test/test.dart';

void main() {
  test('every node type, action, data source, behavior and trigger the catalog declares has a level, and no table names something undeclared', () {
    final c = standardCatalog;
    expect({for (final w in c.widgets) w.type}, widgetLevels.keys.toSet());
    expect({for (final a in c.actions) a.type}, actionLevels.keys.toSet());
    expect({for (final d in c.dataSources) d.type}, dataSourceLevels.keys.toSet());
    expect(Behaviors.keys, behaviorLevels.keys.toSet());
    final triggers = [for (final t in (c.toJson()['triggers'] as Map)['types'] as List) t is Map ? t['type'] : t];
    expect(triggers.toSet(), triggerLevels.keys.toSet());
  });

  test('a catalog cut to a level holds that level and the ones below, nothing above', () {
    final core = standardCatalog.atLevel(Level.core);
    expect(core.widget('column'), isNotNull);
    expect(core.widget('slider'), isNull);
    expect(core.action('setVariable'), isNull);
    final widgets = standardCatalog.atLevel(Level.widgets);
    expect(widgets.widget('column'), isNotNull);
    expect(widgets.widget('slider'), isNotNull);
    expect(widgets.widget('lineChart'), isNotNull, reason: 'the two simple charts are part of the widget catalog');
    expect(widgets.widget('radialGauge'), isNull);
    expect(standardCatalog.atLevel(Level.features).widgets.length, standardCatalog.widgets.length);
    for (final l in Level.values.skip(1)) {
      final below = standardCatalog.atLevel(Level.values[l.index - 1]);
      final here = standardCatalog.atLevel(l);
      expect({for (final w in here.widgets) w.type}, containsAll({for (final w in below.widgets) w.type}));
    }
  });

  Map<String, Object?> doc(Map<String, Object?> nodes, [Map<String, Object?> more = const {}]) => {
        'schema': 3,
        'roots': ['screen'],
        'nodes': {
          'screen': {'type': 'canvas', 'slots': {'body': 'col'}, 'layout': {'width': 390, 'height': 844}},
          ...nodes,
        },
        ...more,
      };

  test('the level of a document is the highest level anything in it has', () {
    final core = doc({
      'col': {'type': 'column', 'children': ['t']},
      't': {'type': 'text', 'props': {'text': 'Hello'}},
    });
    expect(levelOf(core), Level.core);
    final card = doc({
      'col': {'type': 'column', 'children': ['s', 'b']},
      's': {'type': 'slider'},
      'b': {'type': 'filledButton', 'props': {'label': 'Go'}},
    });
    expect(levelOf(card), Level.widgets);
    final bound = doc({
      'col': {'type': 'column', 'children': ['s']},
      's': {
        'type': 'slider',
        'bind': {'props.value': r'${volume}'},
        'actions': [
          {'trigger': {'type': 'changed'}, 'actions': [{'type': 'setVariable', 'variable': 'volume', 'value': r'${result}'}]},
        ],
      },
    }, {
      'variables': {'screen': [{'name': 'volume', 'type': 'number', 'value': 3}]},
    });
    expect(levelOf(bound), Level.state);
    final moving = doc({
      'col': {'type': 'column', 'children': <String>[], 'animations': [{'preset': 'fadeIn'}]},
    });
    expect(levelOf(moving), Level.full);
  });

  test('validation at a level reports each thing above it, with where and which level (above_level)', () {
    final card = doc({
      'col': {'type': 'column', 'children': ['s']},
      's': {
        'type': 'slider',
        'actions': [
          {'trigger': {'type': 'changed'}, 'actions': [{'type': 'setVariable', 'variable': 'v', 'value': r'${result}'}]},
        ],
      },
    });
    List<Diagnostic> above(Level l) =>
        [for (final d in validateDocument(card, options: ValidateOptions(level: l))) if (d.code == Codes.aboveLevel) d];
    expect(above(Level.state), isEmpty);
    final atWidgets = above(Level.widgets);
    expect(atWidgets.map((d) => d.path), ['/nodes/s/actions/0/actions/0', '/nodes/s/actions/0/actions/0/value']);
    expect(atWidgets.first.message, contains('action setVariable is level 2 (State and behavior)'));
    expect(above(Level.core).map((d) => d.path), contains('/nodes/s/type'));
  });
}
