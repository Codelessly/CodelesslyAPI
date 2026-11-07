// v1 master's new action fields, actions, triggers, route transitions,
// scripts, persisted variables and app identity → v2.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

Json one(ActionModel a, [MigrationReport? report]) => ActionMigration(report: report).action(a);

/// A page with one canvas, its body frame and [canvas] keys on the canvas.
Map<String, Object?> page(Map<String, Object?> canvas) => {
      'rootNode': {'children': ['c']},
      'c': {
        'id': 'c', 'type': 'canvas', 'name': 'Home', 'parentID': 'rootNode', 'basicBoxLocal': [0, 0, 400, 300],
        'properties': {'bodyId': 'f'}, 'children': ['f'], ...canvas,
      },
      'f': {'id': 'f', 'name': 'f', 'parentID': 'c', 'type': 'frame', 'basicBoxLocal': [0, 0, 400, 300]},
    };

void main() {
  test('back pressed and drop full triggers keep their names', () {
    final m = ActionMigration();
    expect(m.trigger(TriggerModel(type: TriggerType.backPressed)), {'type': 'backPressed'});
    expect(m.trigger(TriggerModel(type: TriggerType.dropFull)), {'type': 'dropFull'});
  });

  test('a canvas that blocks back: its binding is props.blockBack, its backPressed reaction kept', () {
    final report = MigrationReport();
    final v2 = migrateDocument(page({
      'variables': {'blockBack': r'${= dirty}'},
      'reactions': [
        {
          'trigger': {'type': 'backPressed'},
          'action': {'type': 'confirm', 'title': 'Discard?'},
        },
      ],
    }), report: report);
    final c = (v2['nodes'] as Map)['c'] as Map;
    expect(c['bind'], {'props.blockBack': r'${= dirty}'});
    expect((c['actions'] as List).single['trigger'], {'type': 'backPressed'});
    expect(report.unmapped.keys.where((k) => !k.endsWith('createdTimestamp')), isEmpty);
    expect(report.unmappedBindings, isEmpty);
  });

  test('set variable glides', () {
    final a = SetVariableAction(
      variable: VariableData(id: 'v', name: 't', type: VariableType.decimal),
      newValue: '1',
      animateMs: '3600',
      curve: MotionCurve.easeInOutCubic,
    );
    expect(one(a), {'type': 'setVariable', 'variable': 't', 'value': '1', 'animateMs': '3600', 'curve': 'easeInOutCubic'});
    // v1's default (0) sets at once: nothing written.
    expect(one(SetVariableAction(variable: VariableData(id: 'v', name: 't'), newValue: 'x')).containsKey('animateMs'), isFalse);
    expect(SetVariableAction.fromJson({'type': 'setVariable', 'variable': {'id': 'v', 'name': 't'}, 'newValue': '1', 'animateMs': 250}).animateMs, '250');
  });

  test('animate variable, haptic and run script are v2 actions, nothing unmapped', () {
    final report = MigrationReport();
    expect(
      one(AnimateVariableAction(variable: 't', mode: AnimateVariableMode.seek, from: '0', to: '0.5', durationMs: 900,
          duration: r'${= ms}', curve: MotionCurve.easeOut), report),
      {'type': 'animateVariable', 'variable': 't', 'mode': 'seek', 'from': '0', 'to': '0.5', 'durationMs': 900,
       'duration': r'${= ms}', 'curve': 'easeOut'},
    );
    expect(one(AnimateVariableAction(variable: 't'), report), {'type': 'animateVariable', 'variable': 't'});
    expect(one(HapticAction(kind: HapticKind.heavy, when: r'${= settings.haptics}'), report), {
      'type': 'haptic',
      'kind': 'heavy',
      'when': {'left': r'${= settings.haptics}', 'op': 'isTrue'},
    });
    expect(one(HapticAction(), report), {'type': 'haptic'});
    expect(
      one(RunScriptAction(scriptId: 's1', arguments: {'years': '30'}, resultVariable: 'pay', onError: [DelayAction(milliseconds: 5)]),
          report),
      {
        'type': 'runScript', 'script': 's1', 'arguments': {'years': '30'}, 'resultVariable': 'pay',
        'onError': [{'type': 'delay', 'ms': 5}],
      },
    );
    expect(report.unmapped, isEmpty);
  });

  test('scroll to an axis; step a drag track', () {
    expect(one(ScrollToAction(nodeId: 'map', axis: 'horizontal')), {'type': 'scrollTo', 'node': 'map', 'axis': 'horizontal'});
    expect(one(ControlDragAction(nodeId: 'dial', command: DragCommand.step, steps: r'${= -2}')),
        {'type': 'controlDrag', 'node': 'dial', 'command': 'step', 'steps': r'${= -2}'});
    expect(ControlDragAction.fromJson({'type': 'controlDrag', 'command': 'step', 'steps': 3}).steps, '3');
  });

  test('a for each keeps its items and actions', () {
    expect(one(ForEachAction(items: r'${rows}', actions: [CopyToClipboardAction(text: r'${loop.item}')])), {
      'type': 'forEach',
      'items': r'${rows}',
      'actions': [{'type': 'copyToClipboard', 'text': r'${loop.item}'}],
    });
  });

  test('toast cosmetics go in its look', () {
    final look = one(ShowToastAction(
      message: 'Saved',
      actionBackgroundColor: ColorRGBA.white,
      actionBorder: const BorderSideModel(color: ColorRGBA.black, width: 2),
      actionCornerRadius: 6,
      actionShadows: [Effect(id: 'e1', type: EffectType.dropShadow, color: ColorRGBA.black, offset: const Vec(3, 3), radius: 0, spread: 0)],
      iconShadows: [Effect(id: 'e2', type: EffectType.dropShadow, color: ColorRGBA.white, offset: const Vec(0, 0), radius: 8, spread: 0)],
      rotation: -1.5,
      enterCurve: 'easeOutBack',
      enterOffset: 1,
    ))['look'] as Map;
    expect(look['actionBackgroundColor'], '#FFFFFFFF');
    expect(look['actionBorder'], {'color': '#FF000000', 'width': 2});
    expect(look['actionCornerRadius'], 6);
    expect(look['actionShadows'], hasLength(1));
    expect(look['iconShadows'], hasLength(1));
    expect((look['rotation'], look['enterCurve'], look['enterOffset']), (-1.5, 'easeOutBack', 1));
    // Defaults write nothing.
    expect(one(ShowToastAction(message: 'x')).containsKey('look'), isFalse);
  });

  test('confirm cosmetics go in its look; the title defaults to empty', () {
    final out = one(ConfirmAction(
      confirmBorder: const BorderSideModel(color: ColorRGBA.black),
      cancelBorder: const BorderSideModel(color: ColorRGBA.white, width: 2),
      icon: MultiSourceIconModel.icon(show: true, icon: MaterialIcon(codepoint: 0xe000, name: 'lamp', style: MaterialIconStyle.values.first)),
      iconSize: 30,
      iconColor: ColorRGBA.black,
      iconDiscColor: ColorRGBA.white,
      iconDiscSize: 60,
      iconDiscBorder: const BorderSideModel(color: ColorRGBA.black),
      centered: true,
      expandButtons: true,
      width: 340,
      maxWidth: 380,
      insets: const EdgeInsetsModel.all(20),
      padding: const EdgeInsetsModel.only(left: 24, top: 26, right: 24, bottom: 22),
      buttonHeight: 48,
    ));
    expect(out['title'], '');
    final look = out['look'] as Map;
    expect(look['confirmBorder'], {'color': '#FF000000'});
    expect(look['cancelBorder'], {'color': '#FFFFFFFF', 'width': 2});
    expect((look['icon'] as Map)['name'], 'lamp');
    expect((look['iconSize'], look['iconDiscSize'], look['iconColor'], look['iconDiscColor']), (30, 60, '#FF000000', '#FFFFFFFF'));
    expect(look['iconDiscBorder'], {'color': '#FF000000'});
    expect((look['centered'], look['expandButtons']), (true, true));
    expect((look['width'], look['maxWidth'], look['buttonHeight']), (340, 380, 48));
    expect(look['insets'], [20, 20, 20, 20]);
    expect(look['padding'], [24, 26, 24, 22]);
    expect(one(ConfirmAction()).containsKey('look'), isFalse);
  });

  test('route transitions on navigation and dialogs', () {
    const t = RouteTransition(
      preset: RouteTransitionPreset.iosModal,
      enter: TransitionSide(
        motion: MotionModel(shiftY: 1, opacity: 0),
        reveal: TransitionReveal(origin: RevealOrigin.node, shape: RevealShape.rect),
        curve: MotionCurve.easeOutCubic,
        delayMs: 20,
        durationMs: 300,
      ),
      durationMs: 450,
      barrierColor: ColorRGBA(r: 0, g: 0, b: 0, a: 0.2),
      opaque: false,
      swipeBack: RouteSwipeBack.never,
      dismiss: RouteDismiss(direction: DragDirection.right, spring: TransitionSpring(stiffness: 200)),
    );
    final expected = {
      'preset': 'iosModal',
      'enter': {
        'motion': {'shiftY': 1, 'opacity': 0},
        'reveal': {'shape': 'rect', 'origin': 'node'},
        'curve': 'easeOutCubic',
        'delayMs': 20,
        'durationMs': 300,
      },
      'durationMs': 450,
      'barrierColor': '#33000000',
      'opaque': false,
      'swipeBack': 'never',
      'dismiss': {
        'direction': 'right',
        'spring': {'stiffness': 200},
      },
    };
    expect(one(NavigationAction(destinationId: 'b', routeTransition: t))['routeTransition'], expected);
    expect(one(ShowDialogAction(destinationId: 'd', routeTransition: const RouteTransition.preset(RouteTransitionPreset.zoom)))
        ['routeTransition'], {'preset': 'zoom'});
  });

  test('layout variables persist; scripts move to the document, page scripts last', () {
    final report = MigrationReport();
    final logic = migrateLayoutLogic(
      variables: {
        'id': 'l1',
        'variables': {
          'c': {
            'v1': {'id': 'v1', 'name': 'draft', 'type': 'text', 'value': 'hi', 'extra': {'persist': true}},
          },
        },
        'scripts': {
          'page_variables': {
            's2': {'id': 's2', 'name': 'pay', 'source': 'return 2;', 'pageId': 'p1'},
          },
          'app_variables': {
            's1': {
              'id': 's1', 'name': 'pay', 'source': 'return 1;', 'capabilities': ['variables.read', 'teleport'],
              'params': [{'name': 'n', 'defaultValue': 3}], 'timeoutMs': 500,
              'tests': [{'name': 't', 'args': {'n': 1}, 'expect': 1}],
            },
          },
        },
      },
      report: report,
    );
    expect((logic['variables'] as Map)['c'], [
      {'id': 'v1', 'name': 'draft', 'value': 'hi', 'persist': true},
    ]);
    expect(logic['scripts'], [
      {
        'id': 's1', 'name': 'pay', 'params': [{'name': 'n', 'defaultValue': 3}], 'source': 'return 1;',
        'capabilities': ['variables.read'], 'timeoutMs': 500, 'tests': [{'name': 't', 'args': {'n': 1}, 'expect': 1}],
      },
      {'id': 's2', 'name': 'pay', 'source': 'return 2;', 'pageId': 'p1'},
    ]);
    expect(report.undecodable, isEmpty);
  });

  test('the publish model keeps its app identity, normalized', () {
    final bundle = migratePublishModel({
      'projectId': 'p',
      'appIdentity': {
        'title': 'Hive',
        'themeColor': 0xFFFFAA00,
        'pages': {'p1': {'title': 'Log'}},
        'ogTitle': 'Bees',
      },
    });
    final identity = (bundle['model'] as Map)['appIdentity'] as Map;
    expect(identity['name'], 'Hive');
    expect(identity['themeColor'], '#FFAA00');
    expect(identity['pages'], {'p1': {'title': 'Log'}});
    expect((identity['social'] as Map)['title'], 'Bees');
  });
}
