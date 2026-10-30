import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('ScrollToAction', () {
    test('reads its defaults from minimal JSON', () {
      final ActionModel read = ActionModel.fromJson({
        'type': 'scrollTo',
        'nodeId': 'pricing',
      });
      expect(read, isA<ScrollToAction>());
      final ScrollToAction action = read as ScrollToAction;
      expect(action.type, ActionType.scrollTo);
      expect(action.nodeId, 'pricing');
      expect(action.durationMs, 600);
      expect(action.curve, MotionCurve.easeInOut);
      expect(action.offset, 0);
      expect(ActionType.scrollTo.prettify, 'Scroll To');
    });

    test('round-trips through JSON and leaves defaults out', () {
      final ScrollToAction action = ScrollToAction(
        nodeId: 'docs',
        durationMs: 450,
        curve: MotionCurve.easeOutCubic,
        offset: 72,
      );
      final Map json = action.toJson();
      expect(json, {
        'type': 'scrollTo',
        'nodeId': 'docs',
        'durationMs': 450,
        'curve': 'easeOutCubic',
        'offset': 72.0,
      });
      expect(ActionModel.fromJson(json), action);
      expect(ScrollToAction(nodeId: 'a').toJson(), {
        'type': 'scrollTo',
        'nodeId': 'a',
      });
    });

    test('runs inside a reaction', () {
      final Reaction reaction = Reaction.fromJson({
        'id': 'r',
        'name': 'Go to pricing',
        'trigger': {'type': 'click'},
        'action': {'type': 'scrollTo', 'nodeId': 'pricing', 'offset': 64},
      });
      expect((reaction.action as ScrollToAction).offset, 64);
    });
  });

  group('viewport triggers', () {
    test('read and write their visible fraction', () {
      final TriggerModel enter = TriggerModel.fromJson({
        'type': 'enterViewport',
      });
      expect(enter.type, TriggerType.enterViewport);
      expect(enter.visibleFraction, 0.15);
      expect(enter.toJson(), {'type': 'enterViewport'});

      final TriggerModel exit = TriggerModel(
        type: TriggerType.exitViewport,
        visibleFraction: 0,
      );
      expect(exit.toJson(), {'type': 'exitViewport', 'visibleFraction': 0.0});
      expect(TriggerModel.fromJson(exit.toJson()), exit);
      expect(TriggerType.exitViewport.prettify, 'Exit Viewport');
    });

    test('are offered on frames, rows, texts, icons, buttons and shapes', () {
      final NodeBox box = NodeBox(0, 0, 10, 10);
      for (final ReactionMixin node in <ReactionMixin>[
        FrameNode(id: 'f', name: 'f', basicBoxLocal: box, children: []),
        RectangleNode(id: 'r', name: 'r', basicBoxLocal: box),
        TextNode(id: 't', name: 't', basicBoxLocal: box, data: 'x'),
      ]) {
        expect(node.triggerTypes, containsAll(TriggerType.viewport));
      }
    });
  });

  group('scroll reveal motion', () {
    test('round-trips and defaults', () {
      const MotionModel motion = MotionModel(
        revealOnScroll: true,
        revealFraction: 0.3,
        durationMs: 500,
        enterFrom: MotionModel(translateY: 24, opacity: 0),
      );
      final Map json = motion.toJson();
      expect(json['revealOnScroll'], isTrue);
      expect(json['revealFraction'], 0.3);
      expect(MotionModel.fromJson(json), motion);

      final MotionModel defaults = MotionModel.fromJson({
        'revealOnScroll': true,
      });
      expect(defaults.revealFraction, 0.15);
      expect(MotionModel.none.toJson().containsKey('revealOnScroll'), isFalse);
      expect(MotionModel.none.toJson().containsKey('revealFraction'), isFalse);
    });

    test('a reveal is an entrance, fading in when it starts nowhere else', () {
      const MotionModel reveal = MotionModel(revealOnScroll: true);
      expect(reveal.hasEntrance, isTrue);
      expect(reveal.entranceStart.opacity, 0);
      const MotionModel from = MotionModel(
        revealOnScroll: true,
        enterFrom: MotionModel(translateY: 40),
      );
      expect(from.entranceStart.translateY, 40);
      expect(from.entranceStart.opacity, 1);
      expect(MotionModel.delayMsProperty, 'delayMs');
    });
  });

  group('page view animation', () {
    test('defaults and round-trip', () {
      final PageViewProperties defaults = PageViewProperties.fromJson({});
      expect(defaults.animationDurationMs, 400);
      expect(defaults.animationCurve, MotionCurve.easeInOut);
      expect(defaults.toJson().containsKey('animationDurationMs'), isFalse);

      final PageViewProperties props = PageViewProperties(
        animationDurationMs: 250,
        animationCurve: MotionCurve.easeOutCubic,
        viewportFraction: 0.5,
        padEnds: false,
      );
      final PageViewProperties read = PageViewProperties.fromJson(
        props.toJson(),
      );
      expect(read.animationDurationMs, 250);
      expect(read.animationCurve, MotionCurve.easeOutCubic);
      expect(read.viewportFraction, 0.5);
      expect(read.padEnds, isFalse);
    });
  });

  group('code text', () {
    test('a text node keeps its language and theme through JSON', () {
      final TextNode node = TextNode(
        id: 'code',
        name: 'Code',
        basicBoxLocal: NodeBox(0, 0, 200, 40),
        data: 'const x = 1;',
        codeLanguage: SyntaxLanguage.typescript,
        codeTheme: CodeThemeModel(keyword: ColorRGBA.fromHex('#FF0000')),
      );
      final Map json = node.toJson();
      expect(json['codeLanguage'], 'typescript');
      expect(json['codeTheme'], {'keyword': '#FFFF0000'});
      final TextNode read = TextNode.fromJson(json);
      expect(read.codeLanguage, SyntaxLanguage.typescript);
      expect(read.codeTheme, node.codeTheme);
      expect(read.codeTheme!.resolved.string, CodeThemeModel.defaults.string);
    });

    test('a plain text leaves the code fields out', () {
      final Map json = TextNode(
        id: 't',
        name: 'T',
        basicBoxLocal: NodeBox(0, 0, 10, 10),
        data: 'hi',
      ).toJson();
      expect(json.containsKey('codeLanguage'), isFalse);
      expect(json.containsKey('codeTheme'), isFalse);
      expect(
        TextNode.fromJson({...json, 'codeLanguage': 'go'}).codeLanguage,
        SyntaxLanguage.go,
      );
    });

    test('language names parse loosely', () {
      expect(SyntaxLanguage.tryParse('JS'), SyntaxLanguage.javascript);
      expect(SyntaxLanguage.tryParse(' python '), SyntaxLanguage.python);
      expect(SyntaxLanguage.tryParse('sh'), SyntaxLanguage.bash);
      expect(SyntaxLanguage.tryParse('golang'), SyntaxLanguage.go);
      expect(SyntaxLanguage.tryParse('rust'), isNull);
      expect(SyntaxLanguage.tryParse(''), SyntaxLanguage.none);
    });
  });
}
