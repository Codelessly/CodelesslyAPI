import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  group('RouteTransition', () {
    test('round-trips every field', () {
      const RouteTransition t = RouteTransition(
        preset: RouteTransitionPreset.sharedAxisX,
        enter: TransitionSide(
          motion: MotionModel(
            rotateY: 45,
            perspective: 2,
            originX: -1,
            shiftX: 0.5,
            opacity: 0,
            blur: 6,
          ),
          reveal: TransitionReveal(
            shape: RevealShape.rect,
            origin: RevealOrigin.point,
            x: 0.5,
            y: -1,
            startRadius: 12,
          ),
          curve: MotionCurve.easeOutBack,
          delayMs: 40,
          durationMs: 200,
        ),
        exit: TransitionSide(motion: MotionModel(scale: 1.1)),
        popEnter: TransitionSide(motion: MotionModel(translateX: -20)),
        popExit: TransitionSide(motion: MotionModel(translateY: 100)),
        durationMs: 420,
        reverseDurationMs: 260,
        barrierColor: ColorRGBA(r: 0.2, g: 0.4, b: 0.6, a: 0.4),
        opaque: false,
        swipeBack: RouteSwipeBack.always,
        dismiss: RouteDismiss(
          direction: DragDirection.right,
          distance: 0.4,
          velocity: 500,
          spring: TransitionSpring(stiffness: 200, damping: 20, mass: 2),
        ),
      );
      final Map json = t.toJson();
      expect(RouteTransition.fromJson(json), t);
      expect(json['preset'], 'sharedAxisX');
      expect(json['enter']['motion']['rotateY'], 45);
      expect(json['dismiss']['direction'], 'right');
    });

    test('omits defaults', () {
      expect(const RouteTransition().toJson(), isEmpty);
      expect(const TransitionSide().toJson(), isEmpty);
      expect(
        const RouteTransition.preset(RouteTransitionPreset.cube).toJson(),
        {'preset': 'cube'},
      );
    });

    test('reads a bare preset name', () {
      expect(
        RouteTransition.fromJson('fadeThrough'),
        const RouteTransition(preset: RouteTransitionPreset.fadeThrough),
      );
    });

    test('every preset resolves to concrete sides and timing', () {
      for (final RouteTransitionPreset p in RouteTransitionPreset.values) {
        final RouteTransition r = RouteTransition.preset(p).resolved;
        expect(r.enter, isNotNull, reason: p.name);
        expect(r.exit, isNotNull, reason: p.name);
        expect(r.durationMs, greaterThan(0), reason: p.name);
        expect(r.opaque, isNotNull, reason: p.name);
        expect(r.swipeBack, isNotNull, reason: p.name);
        expect(r.preset, p);
        // Resolved transitions survive JSON.
        expect(RouteTransition.fromJson(r.toJson()), r, reason: p.name);
        expect(p.prettify, isNotEmpty);
      }
    });

    test('sides given next to a preset override it', () {
      const TransitionSide mine = TransitionSide(
        motion: MotionModel(opacity: 0.5),
      );
      final RouteTransition r = const RouteTransition(
        preset: RouteTransitionPreset.zoom,
        enter: mine,
        durationMs: 999,
      ).resolved;
      expect(r.enter, mine);
      expect(
        r.exit,
        RouteTransition.presetTransition(RouteTransitionPreset.zoom).exit,
      );
      expect(r.durationMs, 999);
      expect(r.reverseDurationMs, 999);
    });

    test('preset timing and modal defaults', () {
      final RouteTransition modal = const RouteTransition.preset(
        RouteTransitionPreset.iosModal,
      );
      expect(modal.resolved.opaque, isFalse);
      expect(modal.resolved.dismiss?.direction, DragDirection.down);
      expect(modal.resolvedDurationMs, 400);
      expect(
        const RouteTransition.preset(
          RouteTransitionPreset.iosPush,
        ).resolved.swipeBack,
        RouteSwipeBack.always,
      );
      expect(const RouteTransition().resolvedDurationMs, 300);
      expect(
        const RouteTransition(durationMs: 500).resolvedReverseDurationMs,
        500,
      );
    });

    test('a side times itself inside the route', () {
      const TransitionSide s = TransitionSide(delayMs: 90, durationMs: 120);
      expect(s.interval(300), (0.3, 0.7));
      expect(const TransitionSide().interval(300), (0.0, 1.0));
      expect(const TransitionSide(delayMs: 500).interval(300), (1.0, 1.0));
      expect(TransitionSide.still.isStill, isTrue);
    });

    test('3D presets use MotionModel tilts, not new fields', () {
      final RouteTransition cube = const RouteTransition.preset(
        RouteTransitionPreset.cube,
      ).resolved;
      expect(cube.enter!.motion.rotateY, 90);
      expect(cube.enter!.motion.originX, -1);
      expect(cube.exit!.motion.rotateY, -90);
      expect(cube.exit!.motion.originX, 1);
    });
  });

  group('NavigationAction.routeTransition', () {
    test('absent by default; old JSON unchanged', () {
      final Map old = {
        'type': 'navigation',
        'navigationType': 'push',
        'destinationId': 'b',
        'transition': 'slideLeft',
        'transitionMs': 200,
      };
      final NavigationAction a = NavigationAction.fromJson(old);
      expect(a.routeTransition, isNull);
      expect(a.transition, PageTransition.slideLeft);
      expect(a.toJson().containsKey('routeTransition'), isFalse);
    });

    test('round-trips', () {
      final NavigationAction a = NavigationAction(
        destinationId: 'b',
        routeTransition: const RouteTransition(
          preset: RouteTransitionPreset.circularReveal,
        ),
      );
      final NavigationAction read = NavigationAction.fromJson(a.toJson());
      expect(read.routeTransition, a.routeTransition);
      expect(read, a);
      expect(
        NavigationAction.fromJson({
          'type': 'navigation',
          'destinationId': 'b',
          'routeTransition': 'cube',
        }).routeTransition?.preset,
        RouteTransitionPreset.cube,
      );
    });

    test('every PageTransition still reads and describes itself', () {
      for (final PageTransition t in PageTransition.values) {
        final NavigationAction a = NavigationAction.fromJson({
          'type': 'navigation',
          'destinationId': 'b',
          'transition': t.name,
        });
        expect(a.transition, t);
        if (t == PageTransition.platform) {
          expect(t.asRouteTransition, isNull);
        } else {
          final RouteTransition r = t.asRouteTransition!;
          expect(r.resolvedDurationMs, t.defaultDurationMs);
        }
      }
    });
  });

  group('ShowDialogAction.routeTransition', () {
    test('round-trips and is absent by default', () {
      final ShowDialogAction plain = ShowDialogAction(destinationId: 'd');
      expect(plain.toJson().containsKey('routeTransition'), isFalse);
      final ShowDialogAction a = plain.copyWith(
        routeTransition: const RouteTransition(
          preset: RouteTransitionPreset.iosModal,
          barrierColor: ColorRGBA(r: 0, g: 0, b: 0, a: 0.6),
        ),
      );
      final ShowDialogAction read = ShowDialogAction.fromJson(a.toJson());
      expect(read.routeTransition, a.routeTransition);
    });
  });

  group('node fields', () {
    test('heroFlight values, placeholder, flip and tilt round-trip', () {
      for (final HeroFlight f in HeroFlight.values) {
        final RectangleNode node =
            RectangleNode(
                id: 'r',
                name: 'R',
                basicBoxLocal: NodeBox(0, 0, 10, 10),
              )
              ..heroTag = 'photo-1'
              ..heroFlight = f
              ..heroPlaceholder = HeroPlaceholder.source
              ..flip = const FlipModel(
                axis: FlipAxis.x,
                flipped: true,
                dragToFlip: true,
                variable: 'showBack',
              )
              ..tilt = const TiltModel(
                max: MotionModel(rotateX: 6, rotateY: 12, perspective: 2),
                hover: false,
              );
        final Map json = node.toJson();
        final RectangleNode read = RectangleNode.fromJson(json);
        expect(read.heroFlight, f);
        expect(read.heroPlaceholder, HeroPlaceholder.source);
        expect(read.flip, node.flip);
        expect(read.tilt, node.tilt);
        expect(f.prettify, isNotEmpty);
      }
    });

    test('absent by default and kept out of JSON', () {
      final Map json = RectangleNode(
        id: 'r',
        name: 'R',
        basicBoxLocal: NodeBox(0, 0, 10, 10),
      ).toJson();
      expect(json.containsKey('flip'), isFalse);
      expect(json.containsKey('tilt'), isFalse);
      expect(json.containsKey('heroPlaceholder'), isFalse);
      expect(const FlipModel().toJson(), isEmpty);
      expect(const TiltModel().toJson(), isEmpty);
    });

    test('the flip and tilt survive a row/column copy', () {
      final BaseNode node = NodeJsonConverter().fromJson({
        'type': 'row',
        'id': 'row',
        'name': 'Row',
        'basicBoxLocal': {'x': 0, 'y': 0, 'width': 100, 'height': 40},
        'flip': {'axis': 'x'},
        'tilt': {'hover': false},
        'heroPlaceholder': 'source',
      })!;
      expect(node.flip?.axis, FlipAxis.x);
      expect(node.tilt?.hover, isFalse);
      expect(node.heroPlaceholder, HeroPlaceholder.source);
    });

    test('a page view keeps its page motion', () {
      final PageViewProperties p = PageViewProperties(
        pageMotion: const MotionModel(rotateY: -50, scale: 0.8),
      );
      final PageViewProperties read = PageViewProperties.fromJson(p.toJson());
      expect(read.pageMotion, p.pageMotion);
      expect(PageViewProperties().toJson().containsKey('pageMotion'), isFalse);
    });
  });
}
