// Route transitions, scripts, persisted variables, the app identity and the
// back and drop-full triggers.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('RouteTransition', () {
    test('a bare preset name reads as the preset', () {
      final t = RouteTransition.fromJson('iosPush')!;
      expect(t.preset, RouteTransitionPreset.iosPush);
      expect(t.toJson(), {'preset': 'iosPush'});
      expect(RouteTransition.fromJson('nope'), isNull);
    });

    test('resolved fills in the preset and keeps given sides', () {
      const side = TransitionSide(motion: Motion(opacity: 0), durationMs: 120);
      final t = const RouteTransition(preset: RouteTransitionPreset.iosModal, enter: side).resolved;
      expect(t.enter, side);
      expect(t.exit!.motion, const Motion(scale: 0.93, translateY: 12));
      expect(t.opaque, isFalse);
      expect(t.barrierColor, const Color(0x33000000));
      expect(t.dismiss!.direction, DragDirection.down);
      expect(t.durationMs, 400);
      expect(const RouteTransition().resolved.durationMs, 300);
      expect(const RouteTransition().resolved.swipeBack, RouteSwipeBack.platform);
    });

    test('durations and intervals', () {
      const t = RouteTransition(preset: RouteTransitionPreset.flip, reverseDurationMs: 200);
      expect(t.resolvedDurationMs, 600);
      expect(t.resolvedReverseDurationMs, 200);
      expect(const TransitionSide(delayMs: 300, durationMs: 150).interval(600), (0.5, 0.75));
      expect(TransitionSide.still.interval(0), (0.0, 1.0));
    });

    test('round-trips sparse JSON with value equality', () {
      final json = {
        'enter': {
          'motion': {'shiftX': 1, 'rotateY': 90},
          'reveal': {'origin': 'point', 'x': 0.5},
          'curve': 'easeOutCubic',
          'delayMs': 10,
        },
        'durationMs': 450,
        'opaque': false,
        'dismiss': {
          'velocity': 900,
          'spring': {'damping': 20},
        },
      };
      final t = RouteTransition.fromJson(json)!;
      expect(t.toJson(), json);
      expect(RouteTransition.fromJson(t.toJson()), t);
    });
  });

  group('scripts', () {
    const json = {
      'id': 's1',
      'name': 'payment',
      'params': [
        {'name': 'principal', 'defaultValue': 1000},
      ],
      'source': 'return principal * 0.05;',
      'version': 3,
      'capabilities': ['variables.read', 'clock'],
      'timeoutMs': 500,
      'tests': [
        {
          'name': 'zero',
          'args': {'principal': 0},
          'expect': 0,
        },
      ],
    };

    test('round-trip, unknown capabilities dropped', () {
      final s = ScriptDef.fromJson({
        ...json,
        'capabilities': ['variables.read', 'clock', 'teleport'],
      })!;
      expect(s.toJson(), json);
      expect(s.capabilities, [ScriptCapability.variablesRead, ScriptCapability.clock]);
      expect(s.paramNames, ['principal']);
      expect(ScriptDef.fromJson(s.toJson()), s);
    });

    test('a page script wins over a project script by name', () {
      final doc = LayoutDocument.fromJson({
        'schema': 2,
        'roots': <String>[],
        'nodes': <String, Object?>{},
        'scripts': [
          json,
          {...json, 'id': 's2', 'pageId': 'p1'},
        ],
      });
      expect(doc.scripts, hasLength(2));
      expect(doc.script('payment')!.id, 's2');
      expect(doc.script('s1')!.id, 's1');
      expect(doc.script('nope'), isNull);
    });

    test('validate: names are identifiers that are not host APIs; params unique', () {
      expect(const ScriptDef(id: 'a', name: 'ok', params: [ScriptParam(name: 'x')]).validate(), isEmpty);
      expect(const ScriptDef(id: 'a', name: 'vars').validate(), isNotEmpty);
      expect(const ScriptDef(id: 'a', name: 'return').validate(), isNotEmpty);
      expect(const ScriptDef(id: 'a', name: '1x').validate(), isNotEmpty);
      expect(const ScriptDef(id: 'a', name: 'ok', params: [ScriptParam(name: 'x'), ScriptParam(name: 'x')]).validate(),
          isNotEmpty);
      expect(const ScriptDef(id: 'a', name: 'ok', timeoutMs: 0).validate(), isNotEmpty);
      final s = ScriptDef.fromJson({...json, 'pageId': 'p1'})!;
      expect(s.copyWith(version: 4).version, 4);
      expect(s.copyWith(clearPageId: true).pageId, isNull);
      expect(s.copyWith(name: 'x').pageId, 'p1');
      expect(ScriptCapability.clock.label, 'Read the clock');
    });
  });

  test('a variable persists, unless computed', () {
    final v = Variable.fromJson({'name': 'draft', 'value': 'x', 'persist': true})!;
    expect(v.persist, isTrue);
    expect(v.persists, isTrue);
    expect(v.extra, isEmpty);
    expect(v.toJson(), {'name': 'draft', 'value': 'x', 'persist': true});
    expect(Variable.fromJson({'name': 'n', 'formula': 'a + 1', 'persist': true})!.persists, isFalse);
    expect(const Variable(name: 'a').toJson(), {'name': 'a'});
  });

  group('AppIdentity', () {
    test('typed core, the rest kept', () {
      final json = {
        'version': 1,
        'name': 'Hive',
        'titleTemplate': r'${page.title} | ${app.name}',
        'description': 'Bees',
        'themeColor': '#FFAA00',
        'pages': {
          'p1': {'title': 'Log', 'socialImage': {'url': 'u'}},
        },
        'social': {'title': 'Hi'},
      };
      final id = AppIdentity.fromJson(json)!;
      expect(id.name, 'Hive');
      expect(id.pages['p1']!.title, 'Log');
      expect(id.pageOf(['x', 'p1'])!.title, 'Log');
      expect(id.toJson(), json);
      final model = PublishModel.fromJson({'projectId': 'p', 'appIdentity': json});
      expect(model.appIdentity, id);
      expect(model.extra, isEmpty);
      expect(PublishModel.fromJson(model.toJson()).appIdentity, id);
    });

    test('renderTitle drops the separator of an empty value', () {
      expect(renderTitle(kDefaultTitleTemplate, appName: 'Hive', pageTitle: 'Log'), 'Log · Hive');
      expect(renderTitle(kDefaultTitleTemplate, appName: 'Hive'), 'Hive');
      expect(renderTitle(r'${page}', appName: 'Hive'), 'Hive');
    });
  });

  test('back pressed and drop full triggers; the canvas blocks back', () {
    expect(Trigger.fromJson({'type': 'backPressed'})!.type, TriggerType.backPressed);
    expect(Trigger.fromJson({'type': 'dropFull'})!.type, TriggerType.dropFull);
    expect(TriggerType.screen, contains(TriggerType.backPressed));
    expect(CanvasProps.spec.props, contains(CanvasProps.blockBack));
    final canvas = Node.fromJson({
      'id': 'c',
      'type': 'canvas',
      'props': {'blockBack': true},
    })!;
    expect(canvas.props.get(CanvasProps.blockBack), isTrue);
  });
}
