import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// One JSON per action type, with its fields set.
final samples = <Json>[
  {'type': 'navigate', 'mode': 'reset', 'to': 'home', 'params': {'id': r'${item.id}'}, 'base': 'start', 'transition': 'fade', 'transitionMs': 200,
   'routeTransition': {'preset': 'cube', 'exit': {'motion': {'opacity': 0}, 'reveal': {'shape': 'rect', 'origin': 'node'}, 'delayMs': 20, 'durationMs': 90}, 'barrierColor': '#33000000', 'opaque': false, 'swipeBack': 'never',
                       'dismiss': {'direction': 'right', 'distance': 0.4, 'spring': {'stiffness': 200}}}},
  {'type': 'openModal', 'to': 'd', 'presentation': 'popover', 'anchor': 'trigger', 'placement': 'aboveEnd', 'barrierColor': '#80000000', 'insets': [8, 8, 8, 8], 'sheetBelow': 'tablet', 'routeTransition': {'preset': 'iosModal'}},
  {'type': 'closeModal', 'result': {'ok': true}},
  {'type': 'openLink', 'url': 'https://x'},
  {'type': 'submitForm', 'service': 'mailchimp', 'emailField': 'e', 'apiKey': 'k', 'listId': 'l'},
  {'type': 'setValue', 'node': 'c', 'values': [{'path': 'props.value', 'mode': 'toggle'}, {'path': 'visible', 'value': false}]},
  {'type': 'setVariant', 'node': 'v', 'variant': 'b'},
  {'type': 'setVariable', 'variable': 'rows', 'op': 'insert', 'value': r'${item}', 'index': '0', 'animateMs': '3600', 'curve': 'easeOutCubic'},
  {'type': 'callFunction', 'name': 'f', 'params': {'a': 1}},
  {'type': 'callApi', 'api': 'tides', 'params': {'day': r'${day}'}, 'onSuccess': [{'type': 'openLink', 'url': 'a'}], 'onError': [{'type': 'delay', 'ms': 5}]},
  {'type': 'setStorage', 'key': 'prefs.theme', 'valueType': 'map', 'op': 'update', 'value': 'dark', 'mapKey': 'mode', 'skipIfExists': true},
  {'type': 'cloudDocuments', 'operation': 'update', 'path': 'tasks', 'id': 'x', 'field': 'n', 'valueType': 'integer', 'op': 'add', 'value': '1'},
  {'type': 'loadCloudData', 'variable': 'tasks', 'single': false, 'query': {'enabled': true, 'collectionPath': 'tasks', 'limit': 5}},
  {'type': 'auth', 'operation': 'signUp', 'email': r'${email}', 'password': r'${pw}', 'errorVariable': 'err'},
  {'type': 'if', 'condition': {'left': r'${n}', 'op': 'greaterThan', 'right': '3'}, 'then': [{'type': 'openLink', 'url': 'a'}], 'else': [{'type': 'openLink', 'url': 'b'}]},
  {'type': 'forEach', 'items': 'rows', 'actions': [{'type': 'copyToClipboard', 'text': r'${result.item}'}]},
  {'type': 'cloudFiles', 'path': 'img', 'kind': 'any', 'allowMultiple': false, 'access': 'private', 'actions': [{'type': 'openLink', 'url': r'${result.url}'}]},
  {'type': 'downloadFile', 'fileName': 'rota.csv', 'text': r'${csv}', 'mimeType': 'text/csv'},
  {'type': 'showToast', 'message': 'Saved', 'title': 'Done', 'style': 'success', 'actionLabel': 'Undo', 'actions': [{'type': 'delay', 'ms': 1}], 'look': {'radius': 8}},
  {'type': 'confirm', 'title': 'Delete?', 'destructive': true, 'actions': [{'type': 'delay', 'ms': 1}], 'cancelActions': [{'type': 'delay', 'ms': 2}], 'dialog': 'd'},
  {'type': 'delay', 'ms': 900, 'duration': r'${= slow ? 4000 : 900}'},
  {'type': 'cloudData', 'operation': 'query', 'collection': 'tasks', 'whereFilters': [{'field': 'done', 'operator': 'equal', 'value': 'false'}], 'limit': 3, 'resultVariable': 'r'},
  {'type': 'cloudBatch', 'steps': [{'type': 'cloudData', 'operation': 'delete', 'collection': 'tasks', 'id': 'x'}], 'transaction': true},
  {'type': 'copyToClipboard', 'text': 'hi'},
  {'type': 'editText', 'node': 'f', 'operation': 'wrap', 'before': '**'},
  {'type': 'paywall', 'operation': 'purchase', 'slot': 'annual'},
  {'type': 'focus', 'node': 'f', 'selectAll': true},
  {'type': 'controlDrag', 'node': 'card', 'command': 'step', 'direction': 'left', 'steps': '-2'},
  {'type': 'speak', 'text': 'Hello', 'rate': '0.8'},
  {'type': 'scrollTo', 'node': 's', 'durationMs': 0, 'alignment': 0.5, 'axis': 'horizontal'},
  {'type': 'playSound', 'sound': 'bell', 'at': r'${result.at}'},
  {'type': 'playAnimation', 'node': 'n', 'animation': 'confetti'},
  {'type': 'animateVariable', 'variable': 't', 'mode': 'seek', 'from': '0', 'to': '0.5', 'durationMs': 3600, 'duration': r'${= slow ? 6000 : 3600}', 'curve': 'easeInOut'},
  {'type': 'haptic', 'kind': 'heavy', 'when': {'left': r'${= settings.haptics}', 'op': 'isTrue'}},
  {'type': 'runScript', 'script': 's1', 'arguments': {'principal': r'${loan.amount}', 'years': '30'}, 'resultVariable': 'payment', 'onError': [{'type': 'delay', 'ms': 1}]},
  {'type': 'paginate', 'controller': 'contacts', 'command': 'goTo', 'page': r'${value}', 'pageSize': '50'},
  {'type': 'playSound', 'operation': 'start', 'voiceId': r'${result.pointer}', 'frequency': '261.6256', 'volume': '0.1'},
  {'type': 'playSound', 'operation': 'stop', 'voiceId': r'${result.pointer}'},
  {'type': 'playSound', 'operation': 'stopAll'},

  {'type': 'print', 'node': 'badge'},
];

void main() {
  runScriptArgsAliasTests();
  test('every action type round-trips exactly', () {
    expect(samples.map((s) => s['type']).toSet(), ActionDef.types.toSet());
    for (final s in samples) {
      final a = ActionDef.fromJson(s)!;
      expect(a, isNot(isA<UnknownAction>()), reason: '${s['type']}');
      expect(a.toJson(), s, reason: '${s['type']}');
      expect(ActionDef.fromJson(jsonDecode(jsonEncode(a.toJson()))), a);
    }
  });

  test('typed fields', () {
    final nav = ActionDef.fromJson(samples[0])! as NavigateAction;
    expect((nav.mode, nav.to, nav.base, nav.transition), (NavigationMode.reset, 'home', 'start', PageTransition.fade));
    final set = ActionDef.fromJson(samples[7])! as SetVariableAction;
    expect((set.variable, set.write.op, set.write.index), ('rows', WriteOp.insert, '0'));
    final api = ActionDef.fromJson(samples[9])! as CallApiAction;
    expect(api.onSuccess.single, isA<OpenLinkAction>());
    expect(api.nested, hasLength(2));
    final branch = ActionDef.fromJson(samples[14])! as IfAction;
    expect(branch.condition, isA<Comparison>());
    expect(branch.selfAndNested.map((a) => a.type), ['if', 'openLink', 'openLink']);
  });

  test('an adaptive modal is a sheet below a project breakpoint', () {
    const d = OpenModalAction(presentation: ModalPresentation.adaptive);
    expect(d.sheetBelowWidthIn(Breakpoints.defaults), 600, reason: 'empty: the second breakpoint');
    expect(const OpenModalAction(sheetBelow: 'desktop').sheetBelowWidthIn(Breakpoints.defaults), 1024);
    expect(const OpenModalAction(sheetBelow: 'gone').sheetBelowWidthIn(Breakpoints.defaults), 600);
    final moved = Breakpoints.defaults.update('tablet', (b) => b.copyWith(minWidth: 700));
    expect(const OpenModalAction(sheetBelow: 'tablet').sheetBelowWidthIn(moved), 700, reason: 'by reference');
    expect(d.sheetBelowWidthIn(Breakpoints([const Breakpoint(id: 'only')])), 0, reason: 'one breakpoint: never');
    expect(OpenModalFields.all.map((f) => f.key), contains('sheetBelow'));
    expect(OpenModalFields.all.map((f) => f.key), isNot(contains('sheetBelowWidth')));
  });

  test('every action can be off, non blocking, or conditional', () {
    final a = ActionDef.fromJson({
      'type': 'openLink', 'url': 'x', 'enabled': false, 'nonBlocking': true, //
      'when': {'left': r'${ok}', 'op': 'isTrue'},
    })!;
    expect((a.enabled, a.nonBlocking), (false, true));
    expect(a.when, isA<Comparison>());
    expect(ActionDef.fromJson(a.toJson()), a);
  });

  test('decoding is total: unknown types round-trip, junk is dropped', () {
    final u = ActionDef.fromJson({'type': 'teleport', 'to': 'mars', 'nonBlocking': true})!;
    expect(u, isA<UnknownAction>());
    expect(u.toJson(), {'type': 'teleport', 'to': 'mars', 'nonBlocking': true});
    expect(ActionDef.fromJson('x'), isNull);
    expect(ActionDef.fromJson({'url': 'x'}), isNull);
    expect(ActionDef.listFromJson([1, null, {'type': 'delay', 'ms': 'soon'}]).single, const DelayAction());
    expect(const DelayAction().toJson(), {'type': 'delay', 'ms': 500});
  });

  test('triggers and reactions', () {
    expect(Trigger.fromJson({'type': 'click'}), const Trigger(TriggerType.click));
    expect(Trigger.fromJson('load'), const Trigger(TriggerType.load));
    expect(Trigger.fromJson({'type': 'nope'}), isNull);
    final t = Trigger.fromJson({'type': 'timer', 'intervalMs': 5, 'debounceMs': 10})!;
    expect((t.effectiveIntervalMs, t.debounceMs), (Trigger.minIntervalMs, 10));
    expect(const Trigger(TriggerType.click).toJson(), {'type': 'click'});
    final r = Reaction.fromJson({
      'id': 'r', 'trigger': {'type': 'changed', 'debounceMs': 300}, //
      'actions': [samples[7], samples[14]],
    })!;
    expect(r.type, TriggerType.changed);
    expect(r.allActions.map((a) => a.type), ['setVariable', 'if', 'openLink', 'openLink']);
    expect(Reaction.fromJson(r.toJson()), r);
    expect(Reaction.listFromJson([{'actions': []}, r.toJson()]), [r]);
  });

  test('key combinations', () {
    final c = KeyCombo.tryParse('Meta+Shift+Enter')!;
    expect((c.key, c.meta, c.shift, c.alt), ('enter', true, true, false));
    expect(c.matches('Enter', meta: true, shift: true), isTrue);
    expect(c.matches('Enter', meta: true), isFalse);
    expect(KeyCombo.tryParse('Esc')!.matches('Escape'), isTrue);
    expect(KeyCombo.tryParse('?')!.matches('?', shift: true), isTrue);
    expect(KeyCombo.tryParse('Hyper+A'), isNull);
    expect(KeyCombo.tryParse('Meta++'), const KeyCombo('+', meta: true));
  });

  test('a node holds typed reactions', () {
    final n = Node.fromJson({
      'type': 'box',
      'actions': [
        {'trigger': {'type': 'click'}, 'actions': [{'type': 'setVariable', 'variable': 'n', 'op': 'add', 'value': '1'}]},
      ],
    }, id: 'b')!;
    expect(n.actions.single.actions.single, isA<SetVariableAction>());
    expect(Node.fromJson(n.toJson(), id: 'b'), n);
  });
}

// The editor API documented runScript's arguments as `args`; both read, and
// arguments that aren't text keep their JSON.
void runScriptArgsAliasTests() {
  test('runScript reads `args` as its arguments, and JSON values as JSON', () {
    final a = ActionDef.fromJson({
      'type': 'runScript',
      'script': 'plotter',
      'args': {'op': 'model', 'input': r'${= {a: 1}}', 'n': 3, 'opts': {'x': 1}},
    }) as RunScriptAction;
    expect(a.arguments, {'op': 'model', 'input': r'${= {a: 1}}', 'n': '3', 'opts': '{"x":1}'});
    expect(a.toJson()['arguments'], a.arguments);
    expect((ActionDef.fromJson(a.toJson()) as RunScriptAction).arguments, a.arguments);
  });
}
