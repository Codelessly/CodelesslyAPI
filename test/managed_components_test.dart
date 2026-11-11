import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// A small managed component: a column with a title, a header slot and a
/// button whose click runs an auth action, then the `onSuccess` event.
ManagedComponentVersion version(int n, String semver, {String title = 'Sign in', String minSdk = ''}) {
  final definition = {
    'id': 'sign_in',
    'name': 'Sign in',
    'document': {
      'roots': ['root'],
      'nodes': {
        'root': {
          'type': 'column',
          'children': ['header', 'title', 'button'],
          'layout': {'width': 320},
        },
        'header': {
          'type': 'column',
          'children': ['logo'],
        },
        'logo': {
          'type': 'text',
          'props': {'text': 'Logo'},
        },
        'title': {
          'type': 'text',
          'props': {'text': title},
          'bind': {'decoration.fills.f1': r'${theme.primary}'},
        },
        'button': {
          'type': 'text',
          'props': {'text': 'Go'},
          'actions': [
            {
              'trigger': {'type': 'click'},
              'actions': [
                {'type': 'auth', 'operation': 'signIn', 'errorVariable': 'signInError'},
                {
                  'type': 'if',
                  'condition': {'op': 'isTrue', 'left': 'x'},
                  'then': [
                    {'type': kComponentEventAction, 'event': 'onSuccess'},
                  ],
                },
                {'type': kComponentEventAction, 'event': 'onSuccess'},
              ],
            },
          ],
        },
      },
    },
  };
  final contract = {
    'settings': [
      {
        'key': 'title',
        'label': 'Title',
        'type': 'string',
        'value': title,
        'targets': [
          {'node': 'title', 'path': 'props.text'},
        ],
      },
      {
        'type': 'group',
        'label': 'Links',
        'settings': [
          {
            'key': 'showButton',
            'label': 'Show button',
            'type': 'bool',
            'value': true,
            'targets': [
              {'node': 'button', 'path': 'visible'},
            ],
          },
        ],
      },
    ],
    'slots': [
      {'key': 'header', 'label': 'Header', 'node': 'header'},
    ],
    'events': [
      {'key': 'onSuccess', 'label': 'On success'},
      {'key': 'onError', 'label': 'On error'},
    ],
    'tokens': ['primary'],
    'variables': [
      {'name': 'signInError', 'type': 'text', 'value': ''},
    ],
  };
  return ManagedComponentVersion.fromJson({
    'id': 'sign_in',
    'version': n,
    'semver': semver,
    'minSdk': minSdk,
    'payload': jsonEncode({'definition': definition, 'contract': contract}),
    'digest': 'd$n',
  })!;
}

ManagedComponentMaster master({
  Map<String, Object?> channels = const {
    'stable': {'1': 2, '2': 3},
  },
  List<Object?> rollouts = const [],
  List<int> blocked = const [],
  Map<String, Object?>? versions,
}) => ManagedComponentMaster.fromJson({
  'name': 'Sign in',
  'versions':
      versions ??
      {
        '1': {'semver': '1.0.0'},
        '2': {'semver': '1.1.0'},
        '3': {'semver': '2.0.0'},
        '4': {'semver': '1.2.0', 'minSdk': '99.0.0'},
      },
  'channels': channels,
  'rollouts': rollouts,
  'blocked': blocked,
}, id: 'sign_in')!;

ComponentLink link(int version, String semver, {int? pin, ManagedChannel channel = ManagedChannel.stable}) =>
    ComponentLink(
      id: 'sign_in',
      version: version,
      managed: ManagedComponentRef(semver: semver, pin: pin, channel: channel),
    );

void main() {
  group('JSON', () {
    test('a managed instance link round-trips; a project link is unchanged', () {
      final json = {
        'id': 'sign_in',
        'version': 2,
        'managed': {
          'channel': 'beta',
          'pin': 2,
          'semver': '1.1.0',
          'digest': 'abc',
          'values': {'title': 'Welcome'},
          'slots': {
            'header': ['n7'],
          },
          'events': {
            'onSuccess': [
              {'type': 'setVariable', 'variable': 'done', 'value': 'true'},
            ],
          },
          'tokens': {'primary': '#FF0000FF'},
          'future': 1,
        },
      };
      final l = ComponentLink.fromJson(json)!;
      expect(l.isManaged, isTrue);
      expect(l.managed!.channel, ManagedChannel.beta);
      expect(l.managed!.pin, 2);
      expect(l.managed!.major, 1);
      expect(l.managed!.values, {'title': 'Welcome'});
      expect(l.managed!.slots['header'], ['n7']);
      expect(l.managed!.events['onSuccess']!.single.type, 'setVariable');
      expect(l.managed!.extra, {'future': 1});
      expect(l.toJson(), json);
      expect(ComponentLink.fromJson(l.toJson()), l);

      // Sparse: defaults are left out.
      expect(const ManagedComponentRef().toJson(), isEmpty);
      // A project component's link has no `managed`.
      expect(ComponentLink.fromJson({'id': 'cmp1', 'version': 3})!.toJson(), {'id': 'cmp1', 'version': 3});
      expect(ComponentLink.fromJson({'id': 'cmp1'})!.isManaged, isFalse);
    });

    test('ref edits: values, events, slots, pin; remapped slots', () {
      var r = const ManagedComponentRef();
      r = r.withValue('title', 'Hi').withEvent('onSuccess', [componentEventAction('x')]).withSlot('header', ['a']);
      expect(r.values, {'title': 'Hi'});
      expect(r.withValue('title', null).values, isEmpty);
      expect(r.withEvent('onSuccess', const []).events, isEmpty);
      expect(r.withSlot('header', const []).slots, isEmpty);
      expect(r.copyWith(pin: () => 3).pin, 3);
      expect(r.copyWith(pin: () => 3).copyWith(pin: () => null).pin, isNull);
      expect(r.remapped({'a': 'b'}).slots['header'], ['b']);
    });

    test('a setting has a stable key, falling back to its label slug', () {
      final s = ComponentSetting.fromJson({'key': 'btn', 'label': 'Button label', 'type': 'string'})!;
      expect(s.effectiveKey, 'btn');
      expect(s.toJson()['key'], 'btn');
      expect(ComponentSetting.fromJson({'label': ' Button label! '})!.effectiveKey, 'button_label');
      expect(ComponentSetting.fromJson({'label': 'x'})!.toJson().containsKey('key'), isFalse);
    });

    test('a version reads its payload text; the contract round-trips', () {
      final v = version(2, '1.1.0', minSdk: '22.0.0');
      expect(v.id, 'sign_in');
      expect(v.version, 2);
      expect(v.major, 1);
      expect(v.minSdk, '22.0.0');
      expect(v.definition.rootId, 'root');
      expect(v.contract.flatSettings.map((s) => s.effectiveKey), ['title', 'showButton']);
      expect(v.contract.setting('showButton')!.type, 'bool');
      expect(v.contract.slots.single.node, 'header');
      expect(v.contract.events.map((e) => e.key), ['onSuccess', 'onError']);
      expect(v.contract.tokens, ['primary']);
      expect(v.contract.variables.single.name, 'signInError');
      expect(ManagedComponentContract.fromJson(v.contract.toJson()), v.contract);
      // Stored: the same payload text (its digest stays valid).
      expect(v.toJson()['payload'], v.payload);
      final again = ManagedComponentVersion.fromJson(v.toJson())!;
      expect(again.contract, v.contract);
      // Inline definition and contract decode too.
      final inline = ManagedComponentVersion.fromJson({
        'id': 'sign_in',
        'version': 1,
        'semver': '1.0.0',
        ...(jsonDecode(v.payload!) as Map<String, Object?>),
      })!;
      expect(inline.definition.rootId, 'root');
      // Unreadable: no root, a bad payload, no version.
      expect(ManagedComponentVersion.fromJson({'id': 'x', 'version': 1, 'payload': '{'}), isNull);
      expect(ManagedComponentVersion.fromJson({'id': 'x', 'version': 1}), isNull);
      expect(ManagedComponentVersion.fromJson({'id': 'x', 'payload': v.payload}), isNull);
    });

    test('a master round-trips', () {
      final m = master(
        rollouts: [
          {'channel': 'stable', 'version': 4, 'percent': 10},
        ],
        blocked: [1],
      );
      expect(m.versions[3]!.major, 2);
      expect(m.channels[ManagedChannel.stable], {1: 2, 2: 3});
      expect(m.rollouts.single.percent, 10);
      expect(m.blocked, {1});
      expect(m.latest, 4);
      final again = ManagedComponentMaster.fromJson(m.toJson())!;
      expect(again.toJson(), m.toJson());
    });

    test('semver', () {
      expect(Semver.tryParse('1.2.3'), const Semver(1, 2, 3));
      expect(Semver.tryParse('2'), const Semver(2));
      expect(Semver.tryParse('1.2.3-beta.1'), const Semver(1, 2, 3));
      expect(Semver.tryParse('x'), isNull);
      expect(Semver.tryParse(''), isNull);
      expect(const Semver(1, 10).compareTo(const Semver(1, 9)), greaterThan(0));
      expect(const Semver(1, 9) < const Semver(1, 10), isTrue);
      expect(sdkSatisfies('22.0.0', '21.9.9'), isTrue);
      expect(sdkSatisfies('22.0.0', '22.1.0'), isFalse);
      expect(sdkSatisfies(null, '22.1.0'), isTrue);
    });
  });

  group('resolution', () {
    test('the rollout bucket is deterministic and per project', () {
      expect(managedRolloutBucket('p1', 'sign_in'), managedRolloutBucket('p1', 'sign_in'));
      expect(managedRolloutBucket('p1', 'sign_in'), inInclusiveRange(0, 99));
      final buckets = {for (var i = 0; i < 200; i++) managedRolloutBucket('p$i', 'sign_in')};
      expect(buckets.length, greaterThan(50));
    });

    test('a newer minor on the channel applies; a new major does not', () {
      final m = master();
      expect(managedUpdateTarget(link(1, '1.0.0'), m), 2);
      expect(managedUpdateTarget(link(2, '1.1.0'), m), isNull);
      // Stable offers 3 (2.0.0) for major 2 only: a major 1 instance stays.
      expect(m.newerMajor(1), 3);
      expect(m.newerMajor(2), isNull);
      // Pinned: never.
      expect(managedUpdateTarget(link(1, '1.0.0', pin: 1), m), isNull);
    });

    test('blocked versions are skipped; a blocked snapshot rolls back', () {
      final m = master(blocked: [2]);
      expect(m.resolve(major: 1), 1);
      expect(managedUpdateTarget(link(1, '1.0.0'), m), isNull);
      expect(managedUpdateTarget(link(2, '1.1.0'), m), 1);
      // Rolled back without blocking: the snapshot stays.
      final back = master(
        channels: {
          'stable': {'1': 1},
        },
      );
      expect(managedUpdateTarget(link(2, '1.1.0'), back), isNull);
    });

    test('minSdk gates a version', () {
      final m = master(
        channels: {
          'stable': {'1': 4},
        },
      );
      expect(m.resolve(major: 1, sdkVersion: '22.0.0'), 2);
      expect(m.resolve(major: 1, sdkVersion: '99.1.0'), 4);
      expect(m.resolve(major: 1), 4);
    });

    test('rollouts reach projects by bucket; beta takes stable', () {
      final m = master(
        rollouts: [
          {'channel': 'stable', 'version': 4, 'percent': 50},
        ],
      );
      String projectIn(bool inside) {
        for (var i = 0; ; i++) {
          if ((managedRolloutBucket('p$i', 'sign_in') < 50) == inside) return 'p$i';
        }
      }

      expect(m.resolve(major: 1, projectId: projectIn(true)), 4);
      expect(m.resolve(major: 1, projectId: projectIn(false)), 2);
      final none = master(
        rollouts: [
          {'channel': 'stable', 'version': 4, 'percent': 0},
        ],
      );
      expect(none.resolve(major: 1, projectId: projectIn(true)), 2);

      final beta = master(
        channels: {
          'stable': {'1': 2},
          'beta': {'1': 1},
        },
      );
      expect(beta.resolve(major: 1, channel: ManagedChannel.beta), 2);
      expect(managedUpdateTarget(link(1, '1.0.0', channel: ManagedChannel.beta), beta), 2);
    });
  });

  group('building an instance', () {
    test('ids derive from the top node; settings, tokens, slots and events apply', () {
      final v = version(2, '1.1.0');
      final ref = const ManagedComponentRef()
          .withValue('title', 'Welcome back')
          .withValue('showButton', false)
          .withSlot('header', ['mine'])
          .withEvent('onSuccess', [
            ActionDef.fromJson({'type': 'setVariable', 'variable': 'done', 'value': 'yes'})!,
          ])
          .copyWith(tokens: {'primary': '#FFFF0000'});
      final b = buildManagedInstance(
        version: v,
        topId: 'inst',
        ref: ref,
        layout: Layout.fromJson({'x': 10, 'y': 20, 'width': 300}),
      );
      final byId = {for (final n in b.nodes) n.id: n};
      expect(b.nodes.first.id, 'inst');
      expect(byId.keys, containsAll(['inst', 'inst__header', 'inst__title', 'inst__button']));
      // The slot's default content went; its node holds the instance's.
      expect(byId.containsKey('inst__logo'), isFalse);
      expect(byId['inst__header']!.children, ['mine']);
      expect(byId['inst']!.children, ['inst__header', 'inst__title', 'inst__button']);
      expect(byId['inst__title']!.props.toJson(byId['inst__title']!.spec)['text'], 'Welcome back');
      expect(byId['inst__button']!.visible, isFalse);
      // The theme binding became the instance's token.
      expect(byId['inst__title']!.bind, isEmpty);
      // Events spliced in, nested ones too; placeholders gone.
      final chain = byId['inst__button']!.actions.single.actions;
      expect(chain.map((a) => a.type), ['auth', 'if', 'setVariable']);
      expect(chain[1].nested.single.type, 'setVariable');
      expect(chain.any((a) => componentEventOf(a) != null), isFalse);
      // The top is linked to the version, at the instance's place.
      final top = byId['inst']!;
      expect(top.layout, Layout.fromJson({'x': 10, 'y': 20, 'width': 300}));
      expect(top.component!.version, 2);
      expect(top.component!.managed!.semver, '1.1.0');
      expect(top.component!.managed!.digest, 'd2');
      expect(top.component!.managed!.values['title'], 'Welcome back');
      expect(b.variables.single.name, 'signInError');
    });

    test('node references are renamed; words in props and map keys are not', () {
      final v = ManagedComponentVersion.fromJson({
        'id': 'c',
        'version': 1,
        'semver': '1.0.0',
        'definition': {
          'document': {
            'roots': ['root'],
            'nodes': {
              'root': {
                'type': 'column',
                'children': ['email'],
                'actions': [
                  {
                    'trigger': {'type': 'click'},
                    'actions': [
                      {'type': 'auth', 'operation': 'signIn', 'email': 'a@b.c', 'password': 'x'},
                      {'type': 'submitForm', 'emailField': 'email'},
                    ],
                  },
                ],
              },
              'email': {
                'type': 'textField',
                'props': {
                  'autofillHints': ['email'],
                },
              },
            },
          },
        },
      })!;
      final b = buildManagedInstance(version: v, topId: 't');
      final top = b.nodes.first.toJson();
      expect(top['children'], ['t__email']);
      final chain = (top['actions'] as List).single['actions'] as List;
      expect(chain[0], containsPair('email', 'a@b.c'));
      expect(chain[0], containsPair('password', 'x'));
      expect(chain[1], containsPair('emailField', 't__email'));
      expect(b.nodes.last.toJson()['props'], {
        'autofillHints': ['email'],
      });
    });

    test('without customization: version defaults, events removed', () {
      final b = buildManagedInstance(
        version: version(1, '1.0.0', title: 'Hello'),
        topId: 't',
      );
      final byId = {for (final n in b.nodes) n.id: n};
      expect(byId['t__header']!.children, ['t__logo']);
      expect(byId['t__title']!.props.toJson(byId['t__title']!.spec)['text'], 'Hello');
      expect(byId['t__title']!.bind, isEmpty);
      expect(byId['t__button']!.actions.single.actions.map((a) => a.type), ['auth', 'if']);
      expect(byId['t']!.layout, Layout.fromJson({'width': 320}));
    });

    test('settings survive an update to a newer version', () {
      final ref = const ManagedComponentRef().withValue('title', 'Mine');
      final v1 = buildManagedInstance(
        version: version(1, '1.0.0', title: 'Old'),
        topId: 't',
        ref: ref,
      );
      final v2 = buildManagedInstance(
        version: version(2, '1.1.0', title: 'New default'),
        topId: 't',
        ref: v1.nodes.first.component!.managed!,
      );
      final title = v2.nodes.firstWhere((n) => n.id == 't__title');
      expect(title.props.toJson(title.spec)['text'], 'Mine');
      expect(v2.nodes.first.component!.version, 2);
    });

    test('replacing an instance in a document keeps its slot content', () {
      final ref = const ManagedComponentRef().withSlot('header', ['mine']);
      final first = buildManagedInstance(version: version(1, '1.0.0'), topId: 't', ref: ref);
      var doc = LayoutDocument(
        roots: ['canvas'],
        nodes: {
          'canvas': const Node(id: 'canvas', type: 'canvas', children: ['t']),
          for (final n in first.nodes) n.id: n,
          'mine': const Node(id: 'mine', type: 'column', children: ['mine2']),
          'mine2': const Node(id: 'mine2', type: 'text'),
        },
      );
      final next = buildManagedInstance(version: version(2, '1.1.0'), topId: 't', ref: doc['t']!.component!.managed!);
      doc = replaceManagedInstance(doc, 't', next);
      expect(doc['t']!.component!.version, 2);
      expect(doc['mine'], isNotNull);
      expect(doc['mine2'], isNotNull);
      expect(doc['t__header']!.children, ['mine']);
      expect(doc.parentOf('t'), 'canvas');
      expect(managedInstancesOf(doc).map((n) => n.id), ['t']);
    });

    test('a publish records each instance\'s snapshot', () {
      final b = buildManagedInstance(version: version(2, '1.1.0'), topId: 't');
      final layout = PublishLayout(
        document: LayoutDocument(id: 'l', roots: ['t'], nodes: {for (final n in b.nodes) n.id: n}),
      ).withManagedSnapshots();
      expect(layout.extra['managed'], {
        't': {'id': 'sign_in', 'version': 2, 'semver': '1.1.0', 'channel': 'stable', 'digest': 'd2'},
      });
      final again = PublishLayout.fromJson(layout.toJson());
      expect(again.managedSnapshots['t']!.version, 2);
      expect(PublishLayout(document: LayoutDocument()).withManagedSnapshots().extra, isEmpty);
    });
  });
}
