import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('heroTag', () {
    RectangleNode card() => RectangleNode(
      id: 'card',
      name: 'Card',
      basicBoxLocal: NodeBox(0, 0, 200, 120),
    );

    test('defaults to none and stays out of JSON', () {
      final RectangleNode node = card();
      expect(node.heroTag, isNull);
      expect(node.heroFlight, isNull);
      final Map json = node.toJson();
      expect(json.containsKey('heroTag'), isFalse);
      expect(json.containsKey('heroFlight'), isFalse);
      final RectangleNode read = RectangleNode.fromJson(json);
      expect(read.heroTag, isNull);
      expect(read.heroFlight, isNull);
    });

    test('round-trips with its flight and binding', () {
      final RectangleNode node = card()
        ..heroTag = 'pass-1'
        ..heroFlight = HeroFlight.morphCorners
        ..variables['heroTag'] = r'pass-${item.id}';
      final Map json = node.toJson();
      expect(json['heroTag'], 'pass-1');
      expect(json['heroFlight'], 'morphCorners');
      final RectangleNode read = RectangleNode.fromJson(json);
      expect(read.heroTag, 'pass-1');
      expect(read.heroFlight, HeroFlight.morphCorners);
      expect(read.variables['heroTag'], r'pass-${item.id}');
    });

    test('reads from hand-written JSON of any node type', () {
      for (final String type in ['frame', 'rectangle', 'text']) {
        final BaseNode node = NodeJsonConverter().fromJson({
          'type': type,
          'id': 'x',
          'name': 'n',
          'basicBoxLocal': [0, 0, 10, 10],
          if (type == 'text') 'data': 'Hi',
          'heroTag': 'pass-x',
          'heroFlight': 'standard',
        })!;
        expect(node.heroTag, 'pass-x', reason: type);
        expect(node.heroFlight, HeroFlight.standard, reason: type);
        expect(node.toJson()['heroTag'], 'pass-x', reason: type);
      }
    });

    test('a row turned into a column keeps it', () {
      final RowColumnNode row = RowColumnNode(
        id: 'row',
        name: 'Row',
        basicBoxLocal: NodeBox(0, 0, 100, 40),
        children: const [],
        rowColumnType: RowColumnType.row,
      )..heroTag = 'chip';
      expect(ColumnNode.fromRowColumn(row).heroTag, 'chip');
    });
  });

  group('NavigationAction transition', () {
    test('defaults to the platform transition and stays out of JSON', () {
      final NavigationAction action = NavigationAction(destinationId: 'd');
      expect(action.transition, PageTransition.platform);
      expect(action.transitionMs, isNull);
      expect(action.reverseTransitionMs, isNull);
      final Map json = action.toJson();
      expect(json.containsKey('transition'), isFalse);
      expect(json.containsKey('transitionMs'), isFalse);
      expect(json.containsKey('reverseTransitionMs'), isFalse);
      final NavigationAction read = NavigationAction.fromJson({
        'type': 'navigation',
        'destinationId': 'd',
      });
      expect(read.transition, PageTransition.platform);
      expect(read, action);
    });

    test('round-trips its transition and durations', () {
      final NavigationAction action = NavigationAction(
        destinationId: 'detail',
        transition: PageTransition.fadeUp,
        transitionMs: 520,
        reverseTransitionMs: 420,
      );
      final Map json = action.toJson();
      expect(json['transition'], 'fadeUp');
      expect(json['transitionMs'], 520);
      expect(json['reverseTransitionMs'], 420);
      final ActionModel read = ActionModel.fromJson(json);
      expect(read, isA<NavigationAction>());
      expect(read, action);
    });

    test('durations default per transition and reverse to forward', () {
      expect(
        NavigationAction(transition: PageTransition.fadeUp)
            .resolvedTransitionMs,
        520,
      );
      expect(
        NavigationAction(transition: PageTransition.none).resolvedTransitionMs,
        0,
      );
      final NavigationAction fade = NavigationAction(
        transition: PageTransition.fade,
        transitionMs: 180,
      );
      expect(fade.resolvedTransitionMs, 180);
      expect(fade.resolvedReverseTransitionMs, 180);
      expect(
        fade.copyWith(reverseTransitionMs: 90).resolvedReverseTransitionMs,
        90,
      );
      for (final PageTransition transition in PageTransition.values) {
        expect(PageTransition.values.byName(transition.name), transition);
        expect(transition.prettify, isNotEmpty);
      }
    });
  });
}
