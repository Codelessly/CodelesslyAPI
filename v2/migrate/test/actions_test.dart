import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_migrate/codelessly_migrate.dart';
import 'package:test/test.dart';

/// Real project pages, when the editor's repo is checked out.
final fixtures = [
  Directory('../../../CodelesslyEditor/test/fixtures/legacy_pages'),
  Directory('/home/user/CodelesslyEditor/test/fixtures/legacy_pages'),
].where((d) => d.existsSync()).firstOrNull;

/// The v2 action types (API v2 `ActionDef.types`).
const v2Types = {
  'navigate', 'openModal', 'closeModal', 'openLink', 'submitForm', 'setValue', 'setVariant', 'setVariable', //
  'callFunction', 'callApi', 'setStorage', 'cloudDocuments', 'loadCloudData', 'auth', 'if', 'forEach', 'cloudFiles',
  'showToast', 'confirm', 'delay', 'cloudData', 'cloudBatch', 'copyToClipboard', 'editText', 'paywall', 'focus',
  'controlDrag', 'speak', 'scrollTo', 'playSound', 'playAnimation', 'animateVariable', 'haptic', 'runScript',
};

Json one(ActionModel a, {Map<String, BaseNode> nodes = const {}}) => ActionMigration(nodes: nodes).action(a);

Iterable<Json> allActions(Iterable<Object?> list) sync* {
  for (final a in list) {
    if (a is! Map) continue;
    final m = a.cast<String, Object?>();
    yield m;
    for (final k in const ['then', 'else', 'onSuccess', 'onError', 'actions', 'cancelActions', 'steps']) {
      if (m[k] is List) yield* allActions(m[k] as List);
    }
  }
}

void main() {
  group('triggers', () {
    final m = ActionMigration();
    test('keep their type and settings, sparsely', () {
      expect(m.trigger(TriggerModel(type: TriggerType.click)), {'type': 'click'});
      expect(m.trigger(TriggerModel(type: TriggerType.changed, debounceMs: 300)), {'type': 'changed', 'debounceMs': 300});
      expect(m.trigger(TriggerModel(type: TriggerType.hold, duration: 800)), {'type': 'hold', 'holdMs': 800});
      expect(m.trigger(TriggerModel(type: TriggerType.enterViewport, visibleFraction: 0.5)),
          {'type': 'enterViewport', 'visibleFraction': 0.5});
      expect(m.trigger(TriggerModel(type: TriggerType.valueChanged, variable: 'count')),
          {'type': 'valueChanged', 'variable': 'count'});
      expect(m.trigger(TriggerModel(type: TriggerType.keyDown, key: 'Meta+Enter', when: r'${= open}')),
          {'type': 'keyDown', 'key': 'Meta+Enter', 'when': r'${= open}'});
    });

    test('interval is a timer, key press a key down', () {
      expect(m.trigger(TriggerModel(type: TriggerType.interval, intervalMillis: 50)), {'type': 'timer', 'intervalMs': 100});
      expect(m.trigger(TriggerModel(type: TriggerType.timer, intervalMs: 250)), {'type': 'timer', 'intervalMs': 250});
      expect(m.trigger(TriggerModel(type: TriggerType.keyPress, key: 'A')), {'type': 'keyDown', 'key': 'A'});
    });

    test('a reaction is its trigger and a chain of its action', () {
      final r = Reaction(
        id: 'r1',
        name: 'Go',
        trigger: TriggerModel(type: TriggerType.click),
        action: NavigationAction(destinationId: 'b', navigationType: NavigationType.replace, params: {'id': r'${item.id}'}),
      );
      expect(m.reactions([r.toJson()]), [
        {
          'id': 'r1',
          'name': 'Go',
          'trigger': {'type': 'click'},
          'actions': [
            {'type': 'navigate', 'mode': 'replace', 'to': 'b', 'params': {'id': r'${item.id}'}},
          ],
        },
      ]);
    });

    test('a reaction v1 cannot decode is reported, not kept', () {
      final report = MigrationReport();
      expect(ActionMigration(report: report).reactions([{'trigger': {'type': 'click'}}]), isEmpty);
      expect(report.undecodable, hasLength(1));
    });
  });

  group('actions', () {
    test('navigation, modals and links', () {
      expect(one(NavigationAction(navigationType: NavigationType.pop)), {'type': 'navigate', 'mode': 'pop'});
      expect(
        one(NavigationAction(
          navigationType: NavigationType.reset,
          destinationId: 'home',
          baseDestinationId: 'start',
          transition: PageTransition.fade,
          transitionMs: 200,
        )),
        {'type': 'navigate', 'mode': 'reset', 'to': 'home', 'base': 'start', 'transition': 'fade', 'transitionMs': 200},
      );
      expect(
        one(ShowDialogAction(destinationId: 'd', presentation: DialogPresentation.bottomSheet, barrierDismissible: false, showDragHandle: true)),
        {'type': 'openModal', 'to': 'd', 'presentation': 'bottomSheet', 'barrierDismissible': false, 'showDragHandle': true},
      );
      expect(one(CloseModalAction(params: {'ok': true})), {'type': 'closeModal', 'result': {'ok': true}});
      expect(one(LinkAction(url: 'https://x', nonBlocking: true)), {'type': 'openLink', 'url': 'https://x', 'nonBlocking': true});
    });

    test('set variable: the operation of its type', () {
      VariableData v(VariableType t) => VariableData(id: 'v', name: 'v', type: t);
      expect(one(SetVariableAction(variable: v(VariableType.integer), newValue: '1', numberOperation: NumberOperation.add)),
          {'type': 'setVariable', 'variable': 'v', 'op': 'add', 'value': '1'});
      expect(one(SetVariableAction(variable: v(VariableType.boolean), toggled: true)),
          {'type': 'setVariable', 'variable': 'v', 'op': 'toggle'});
      expect(one(SetVariableAction(variable: v(VariableType.list), newValue: 'x', listOperation: ListOperation.insert, index: '2')),
          {'type': 'setVariable', 'variable': 'v', 'op': 'insert', 'value': 'x', 'index': '2'});
      expect(one(SetVariableAction(variable: v(VariableType.list), listOperation: ListOperation.removeAt, index: r'${i}')),
          {'type': 'setVariable', 'variable': 'v', 'op': 'removeAt', 'index': r'${i}'});
      expect(one(SetVariableAction(variable: v(VariableType.list), newValue: '[1]', listOperation: ListOperation.replace)),
          {'type': 'setVariable', 'variable': 'v', 'value': '[1]'});
      expect(one(SetVariableAction(variable: v(VariableType.map), newValue: '5', mapOperation: MapOperation.update, mapKey: 'k')),
          {'type': 'setVariable', 'variable': 'v', 'op': 'update', 'value': '5', 'mapKey': 'k'});
      expect(one(SetVariableAction(variable: v(VariableType.map), mapOperation: MapOperation.remove, mapKey: 'k')),
          {'type': 'setVariable', 'variable': 'v', 'op': 'remove', 'mapKey': 'k'});
      expect(one(SetVariableAction(variable: v(VariableType.text), newValue: r'Hi ${name}')),
          {'type': 'setVariable', 'variable': 'v', 'value': r'Hi ${name}'});
    });

    test('set value: binding paths of the node, and its variant', () {
      final checkbox = CheckboxNode(id: 'c', name: 'c', basicBoxLocal: NodeBox(0, 0, 20, 20), properties: CheckboxProperties());
      expect(
        one(SetValueAction(nodeID: 'c', values: [const BoolValue(name: 'value', mode: SetValueMode.toggle)]), nodes: {'c': checkbox}),
        {'type': 'setValue', 'node': 'c', 'values': [{'path': 'props.value', 'mode': 'toggle'}]},
      );
      expect(
        one(SetValueAction(nodeID: 'c', values: [const BoolValue(name: 'value', value: true)]), nodes: {'c': checkbox}),
        {'type': 'setValue', 'node': 'c', 'values': [{'path': 'props.value', 'value': true}]},
      );
      expect(one(SetVariantAction(nodeID: 'v', variantID: 'b')), {'type': 'setVariant', 'node': 'v', 'variant': 'b'});
    });

    test('flow: if, for each, delay, api branches', () {
      final ifElse = one(ConditionalAction(
        expression: Expression(
          leftPart: VariablePart(valueString: r'${count}'),
          operator: ConditionOperation.greaterThan,
          rightPart: RawValuePart('3'),
        ),
        actions: [LinkAction(url: 'a')],
        elseActions: [DelayAction(milliseconds: 10)],
      ));
      expect(ifElse, {
        'type': 'if',
        'condition': {'left': r'${count}', 'op': 'greaterThan', 'right': '3'},
        'then': [{'type': 'openLink', 'url': 'a'}],
        'else': [{'type': 'delay', 'ms': 10}],
      });
      expect(one(ForEachAction(items: 'rows', actions: [CopyToClipboardAction(text: r'${result.item}')])), {
        'type': 'forEach',
        'items': 'rows',
        'actions': [{'type': 'copyToClipboard', 'text': r'${result.item}'}],
      });
      expect(one(DelayAction(milliseconds: 900, duration: r'${= slow ? 4000 : 900}')),
          {'type': 'delay', 'ms': 900, 'duration': r'${= slow ? 4000 : 900}'});
      expect(
        one(ApiCallAction(apiId: 'tides', parameters: {'day': r'${day}'}, onSuccess: [LinkAction(url: 'ok')], onError: [LinkAction(url: 'no')])),
        {
          'type': 'callApi',
          'api': 'tides',
          'params': {'day': r'${day}'},
          'onSuccess': [{'type': 'openLink', 'url': 'ok'}],
          'onError': [{'type': 'openLink', 'url': 'no'}],
        },
      );
      expect(one(CallFunctionAction(name: 'f', params: {'a': 1}, enabled: false)),
          {'type': 'callFunction', 'name': 'f', 'params': {'a': 1}, 'enabled': false});
    });

    test('storage and cloud data', () {
      expect(one(SetStorageAction(key: 'n', variableType: VariableType.integer, newValue: '2', numberOperation: NumberOperation.subtract)),
          {'type': 'setStorage', 'key': 'n', 'valueType': 'integer', 'op': 'subtract', 'value': '2'});
      expect(one(SetStorageAction(key: 'n', operation: StorageOperation.remove)), {'type': 'setStorage', 'operation': 'remove', 'key': 'n'});
      expect(one(SetStorageAction(operation: StorageOperation.clear)), {'type': 'setStorage', 'operation': 'clear'});
      expect(
        one(SetCloudStorageAction(subAction: const AddDocumentSubAction(path: 'tasks', autoGenerateId: true, newValue: '{"a": 1}'))),
        {'type': 'cloudDocuments', 'operation': 'add', 'path': 'tasks', 'autoId': true, 'document': '{"a": 1}'},
      );
      expect(
        one(SetCloudStorageAction(subAction: const RemoveDocumentSubAction(path: 'tasks', documentId: r'${item.id}'))),
        {'type': 'cloudDocuments', 'operation': 'remove', 'path': 'tasks', 'id': r'${item.id}'},
      );
      expect(
        one(LoadFromCloudStorageAction(path: 'tasks', variable: VariableData(id: 'v', name: 'tasks'), loadSingleDocument: false, limit: 5)),
        {
          'type': 'loadCloudData',
          'variable': 'tasks',
          'single': false,
          'query': {'enabled': true, 'collectionPath': 'tasks', 'limit': 5},
        },
      );
      expect(
        one(CloudDataAction(
          operation: CloudDataOperation.update,
          collection: 'tasks',
          documentId: 'x',
          fields: [const CloudFieldWrite(field: 'n', value: '1', operation: CloudFieldOperation.increment)],
          resultVariable: VariableData(id: 'r', name: 'res'),
        )),
        {
          'type': 'cloudData',
          'operation': 'update',
          'collection': 'tasks',
          'id': 'x',
          'fields': [{'field': 'n', 'value': '1', 'operation': 'increment'}],
          'resultVariable': 'res',
        },
      );
    });

    test('feedback, auth and nodes', () {
      expect(one(ShowToastAction(message: 'Saved', style: ToastStyle.success, actionLabel: 'Undo', actions: [LinkAction(url: 'u')])), {
        'type': 'showToast',
        'message': 'Saved',
        'style': 'success',
        'actionLabel': 'Undo',
        'actions': [{'type': 'openLink', 'url': 'u'}],
      });
      expect(one(ConfirmAction(title: 'Delete?', destructive: true, actions: [LinkAction(url: 'y')])), {
        'type': 'confirm',
        'title': 'Delete?',
        'destructive': true,
        'actions': [{'type': 'openLink', 'url': 'y'}],
      });
      expect(one(AuthAction(operation: AuthOperation.signIn, email: r'${email}', password: r'${pw}')),
          {'type': 'auth', 'operation': 'signIn', 'email': r'${email}', 'password': r'${pw}'});
      expect(one(FocusAction(nodeId: 'f', selectAll: true)), {'type': 'focus', 'node': 'f', 'selectAll': true});
      expect(one(PlaySoundAction(sound: 'bell')), {'type': 'playSound', 'sound': 'bell'});
      expect(one(PaywallAction(PaywallOperation.purchase, slot: 'annual')), {'type': 'paywall', 'operation': 'purchase', 'slot': 'annual'});
    });
  });

  test('a document migrates its nodes\' reactions', () {
    final v2 = migrateDocument({
      'rootNode': {'children': ['c']},
      'c': {
        'id': 'c', 'type': 'canvas', 'name': 'C', 'parentID': 'root', 'basicBoxLocal': [0, 0, 100, 100], //
        'properties': {'bodyId': 'b'}, 'children': ['b'],
      },
      'b': {
        'id': 'b', 'type': 'frame', 'name': 'B', 'parentID': 'c', 'basicBoxLocal': [0, 0, 100, 100], 'children': <String>[], //
        'reactions': [
          Reaction(trigger: TriggerModel(type: TriggerType.click), action: LinkAction(url: 'https://x')).toJson(),
        ],
      },
    });
    final actions = ((v2['nodes'] as Map)['b'] as Map)['actions'] as List;
    expect((actions.single as Map)['actions'], [{'type': 'openLink', 'url': 'https://x'}]);
  });

  test('every fixture reaction migrates to a v2 action type', () {
    if (fixtures == null) return markTestSkipped('fixtures not checked out');
    final report = MigrationReport();
    final types = <String, int>{};
    var reactions = 0;
    for (final f in fixtures!.listSync().whereType<File>().where((f) => f.path.endsWith('.json.gz'))) {
      final json = jsonDecode(utf8.decode(gzip.decode(f.readAsBytesSync()))) as Map<String, dynamic>;
      final v2 = migrateDocument(((json['document'] as Map?) ?? json).cast(), report: report);
      for (final n in (v2['nodes'] as Map).values) {
        for (final r in ((n as Map)['actions'] as List?) ?? const []) {
          reactions++;
          for (final a in allActions((r as Map)['actions'] as List)) {
            types.update('${a['type']}', (v) => v + 1, ifAbsent: () => 1);
          }
        }
      }
    }
    expect(reactions, greaterThan(100));
    expect(types.keys.where((t) => !v2Types.contains(t)), isEmpty, reason: '$types');
    expect(report.unmapped.keys.where((k) => k.startsWith('action.')), isEmpty);
    expect(report.undecodable.keys.where((k) => k.startsWith('reaction') || k.startsWith('action')), isEmpty);
  });
}
