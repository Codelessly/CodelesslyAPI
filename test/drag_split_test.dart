// The legacy `drag` key split into `track`, `dismissible`, `pan` and
// `reorderHandle` (docs/design/04-drag-and-track.md): old JSON in, the new
// model out, written only in the new shape; legacy binding paths rewritten.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

import 'legacy_support.dart';

Node _node(Json j) => legacyNode(j);

void main() {
  test('an older drag with a track becomes the track, switched by the drag\'s enabled', () {
    final n = _node({
      'drag': {
        'enabled': false,
        'release': 'dismiss',
        'track': {'variable': 'volume', 'shape': 'arc', 'max': 10},
      },
      'bind': {'drag.track.value': r'${level}', 'drag.enabled': r'${on}', 'drag.track.x2': '40'},
    });
    final b = n.behaviors;
    expect(b.track, const Track(enabled: false, variable: 'volume', shape: TrackShape.arc, max: 10));
    expect(b.dismissible, isNull);
    expect(b.pan, isNull);
    expect(n.bind, {'track.value': r'${level}', 'track.enabled': r'${on}', 'track.x2': '40'});
    final out = n.toJson();
    expect(out.containsKey('drag'), isFalse);
    expect(out['track'], {'enabled': false, 'variable': 'volume', 'shape': 'arc', 'max': 10});
    expect(_node(out), n);
  });

  test('an older reordering drag becomes a reorder handle', () {
    final n = _node({
      'drag': {'reorder': true},
    });
    expect(n.behaviors.reorderHandle, isTrue);
    expect(n.behaviors.pan, isNull);
    expect(n.toJson()['reorderHandle'], isTrue);
    expect(n.toJson().containsKey('drag'), isFalse);
  });

  test('an older dismissing drag becomes a dismissible with its old defaults written out', () {
    final n = _node({
      'drag': {
        'release': 'dismiss',
        'directions': ['left', 'right', 'up'],
        'rotateFactor': 15,
        'originY': 1.6,
        'resistance': 0.7,
        'verticalThreshold': 0.25,
      },
    });
    final d = n.behaviors.dismissible!;
    expect(d.directions, [DragDirection.left, DragDirection.right, DragDirection.up]);
    expect(d.thresholdFor(DragDirection.left), 0.35);
    expect(d.thresholdFor(DragDirection.up), 0.25);
    expect(d.flingVelocity, 800);
    expect(d.movementDuration, 320);
    expect(d.curve, AnimationCurve.easeIn);
    expect(d.effectiveReturnDuration, 450);
    expect(d.effectiveReturnCurve, AnimationCurve.spring);
    expect(d.returnSpring, isNull);
    expect(n.toJson()['dismissible'], {
      'directions': ['left', 'right', 'up'],
      'dismissThresholds': {'left': 0.35, 'right': 0.35, 'up': 0.25, 'down': 0.25},
      'flingVelocity': 800,
      'resistance': 0.7,
      'movementDuration': 320,
      'curve': 'easeIn',
      'returnDuration': 450,
      'returnCurve': 'spring',
    });
    // The deprecated tilt is dropped in schema 3, kept unread as legacy.*.
    expect(n.extra, {'legacy.dismissible.rotateFactor': 15, 'legacy.dismissible.originY': 1.6});
    expect(_node(n.toJson()), n);
    // Every direction by default; physics is the return spring.
    final all = _node({
      'drag': {
        'release': 'dismiss',
        'physics': {'bounce': 0.3, 'duration': 400},
        'velocityThreshold': 600,
        'flyOut': 260,
      },
    }).behaviors.dismissible!;
    expect(all.directions, DragDirection.values);
    expect(all.returnSpring, const Spring(duration: 400, bounce: 0.3));
    expect(all.flingVelocity, 600);
    expect(all.movementDuration, 260);
  });

  test('a new dismissible takes Flutter\'s defaults and names', () {
    final d = DismissibleBehavior.fromJson(<String, Object?>{})!;
    expect(d.directions, [DragDirection.left, DragDirection.right]);
    expect(d.thresholdFor(DragDirection.right), 0.4);
    expect(d.flingVelocity, 700);
    expect(d.movementDuration, 200);
    expect(d.toJson(), isEmpty);
    expect(DismissibleBehavior.fromJson({'direction': 'vertical'})!.directions, [DragDirection.up, DragDirection.down]);
    expect(DismissibleBehavior.fromJson({'direction': 'endToStart'})!.directions, [DragDirection.left]);
    final j = {
      'directions': ['up'],
      'dismissThresholds': {'up': 0.25},
      'returnSpring': {'duration': 450, 'bounce': 0.25},
    };
    expect(DismissibleBehavior.fromJson(j)!.toJson(), j);
  });

  test('any other older drag becomes a pan', () {
    final n = _node({
      'drag': {
        'axis': 'vertical',
        'release': 'stay',
        'minY': -560,
        'maxY': 0,
        'restY': -40,
        'snapBack': 300,
        'yVariable': 'sheetY',
        'physics': {
          'snap': {
            'points': [
              [0, 0],
              [0, -560],
            ],
          },
        },
      },
    });
    final p = n.behaviors.pan!;
    expect(p.axis, DragAxis.vertical);
    expect(p.release, PanRelease.stay);
    expect(p.y, -40);
    expect(p.returnDuration, 300);
    expect(p.yVariable, 'sheetY');
    expect(p.physics!.snap!.points.last, const Offset(0, -560));
    final out = n.toJson()['pan'] as Map;
    expect(out['y'], -40);
    expect(out['returnDuration'], 300);
    expect(out.containsKey('restY'), isFalse);
    expect(out.containsKey('snapBack'), isFalse);
    expect(_node(n.toJson()), n);
    // The plain drag: springs back.
    expect(_node({'drag': <String, Object?>{}}).behaviors.pan, const Pan());
  });

  test('bindings into an older drag move to the behavior it became', () {
    final card = _node({
      'drag': {'release': 'dismiss'},
      'bind': {
        'drag.enabled': r'${ok}',
        'drag.restX': r'${peek}',
        'drag.distanceThreshold': '0.2',
        'drag.flyOut': '200',
        'drag.unknown': '1',
      },
    });
    expect(card.bind, {
      'dismissible.enabled': r'${ok}',
      'dismissible.dismissThresholds.left': '0.2',
      'dismissible.dismissThresholds.right': '0.2',
      'dismissible.dismissThresholds.up': '0.2',
      'dismissible.dismissThresholds.down': '0.2',
      'dismissible.movementDuration': '200',
      'drag.unknown': '1',
    });
    // A dismissible's rest (deprecated) is dropped with its binding.
    expect(card.extra['legacy.dismissible.restX'], {'value': null, 'bind': r'${peek}'});
    final applied = BindPaths.apply(card, 'dismissible.dismissThresholds.up', 0.1);
    expect(applied.behaviors.dismissible!.thresholdFor(DragDirection.up), 0.1);
    final sheet = _node({
      'drag': {'release': 'stay'},
      'bind': {'drag.restX': r'${x}', 'drag.enabled': r'${on}', 'drag.physics.friction': '0.5'},
    });
    expect(sheet.bind, {'pan.x': r'${x}', 'pan.enabled': r'${on}', 'pan.physics.friction': '0.5'});
    expect(BindPaths.apply(sheet, 'pan.x', 12).behaviors.pan!.x, 12);
  });

  test('the new keys are declared and the legacy one is migrated, not kept', () {
    expect(Behaviors.keys, containsAll(['track', 'dismissible', 'pan', 'reorderHandle']));
    expect(Behaviors.keys, isNot(contains('drag')));
    expect(_node({'drag': <String, Object?>{}}).extra, isEmpty);
  });

  test("a draggable takes Flutter's names and has one return spring", () {
    final d = legacyDraggable({
      'group': 'cards',
      'whileDragging': 'hidden',
      'feedbackNodeId': 'ghost',
      'feedbackAnchor': 'center',
      'spring': {'stiffness': 300},
    })!;
    expect(d.childWhenDragging, DragSourceStyle.hidden);
    expect(d.feedback, 'ghost');
    expect(d.dragAnchor, DragAnchor.center);
    expect(d.returnSpring, const Spring.physical(stiffness: 300, damping: 14));
    expect(d.toJson(), {
      'group': 'cards',
      'childWhenDragging': 'hidden',
      'feedback': 'ghost',
      'dragAnchor': 'center',
      'returnSpring': {'stiffness': 300},
    });
    expect(legacyDraggable(d.toJson()), d);
    // No return spring: `returnSpring: false`, written back as false.
    final none = legacyDraggable({'returnSpring': false})!;
    expect(none.returnSpring, isNull);
    expect(none.toJson(), {'returnSpring': false});
    expect(legacyDraggable(none.toJson()), none);
    // The legacy physics overrides the bool, its spring is the return.
    expect(
      legacyDraggable({
        'returnSpring': false,
        'physics': {'bounce': 0.2, 'duration': 300},
      })!.returnSpring,
      const Spring(duration: 300, bounce: 0.2),
    );
    // The default: the old 260 / 14 spring (existing documents rely on it).
    expect(legacyDraggable(<String, Object?>{})!.returnSpring, DragSource.defaultSpring);
    expect(legacyDraggable({'feedbackAnchor': 'grab'})!.dragAnchor, DragAnchor.child);
    expect(legacyDraggable({'dragAnchorStrategy': 'pointer'})!.dragAnchor, DragAnchor.center);
  });

  test('an older drag control action reads as the typed action of its command', () {
    ActionDef read(Json j) => legacyAction({'type': 'controlDrag', 'node': 'k', ...j});
    expect(read({'command': 'step', 'steps': '-2', 'direction': 'left'}), const ControlTrackAction(node: 'k', steps: '-2'));
    expect(read({}), const ControlDismissibleAction(node: 'k'));
    expect(read({'command': 'fling', 'direction': 'up'}),
        const ControlDismissibleAction(node: 'k', direction: DragDirection.up));
    expect(read({'command': 'returnFrom', 'direction': 'left'}),
        const ControlDismissibleAction(node: 'k', command: DismissCommand.returnFrom, direction: DragDirection.left));
    expect(read({'command': 'shake'}), const ControlDismissibleAction(node: 'k', command: DismissCommand.shake));
    expect(read({'command': 'reset'}), const ControlTransformAction(node: 'k'));
    expect(read({'command': 'zoom', 'value': '1.5'}),
        const ControlTransformAction(node: 'k', command: TransformCommand.scaleBy, value: '1.5'));
    final pose = read({
      'command': 'pose',
      'value': {'x': 0, 'scale': 2},
    });
    expect(pose, const ControlTransformAction(node: 'k', command: TransformCommand.animateTo, value: '{"x":0,"scale":2}'));
    // Written only as the new type.
    expect(pose.toJson()['type'], 'controlTransform');
    expect(ActionDef.fromJson(pose.toJson()), pose);
  });

  test('a track\'s special-case keys read into general ones', () {
    // A combination dial (safecracker): endless, momentum, a gain round its arc.
    final dial = legacyTrack({
      'shape': 'arc', 'variable': 'dial', 'max': 40, 'step': 1, 'startAngle': 0, 'endAngle': 360, //
      'endless': true, 'momentum': true, 'friction': 2.6, 'gain': 0.5, 'jumpOnTap': true, 'wheel': false,
    })!;
    expect(dial.clamp, isFalse);
    expect(dial.sweepAngle, 360);
    expect(dial.endAngle, 360);
    expect(dial.momentum, isTrue);
    expect(dial.physics!.friction, 0.9257);
    expect(dial.frictionRate, closeTo(2.6, 0.001));
    expect(dial.allowedInteraction, TrackInteraction.tapAndSlide);
    expect(dial.wheelStep, 0);
    expect(dial.wheel, isFalse);
    expect(dial.toJson(), {
      'variable': 'dial', 'max': 40, 'step': 1, 'clamp': false, 'allowedInteraction': 'tapAndSlide', 'wheelStep': 0, //
      'shape': 'arc', 'startAngle': 0, 'sweepAngle': 360, 'physics': {'friction': 0.9257},
    });
    // endless on a line did nothing: still clamped.
    expect(legacyTrack({'endless': true})!.clamp, isTrue);
    // A vertical knob's gain is a pixel rate.
    final knob = legacyTrack({'input': 'vertical', 'pixelsPerRange': 300, 'gain': 2, 'keyboard': false})!;
    expect(knob.pixelsPerRange, 150);
    expect(knob.effectiveKeyStep, isNull);
    // A path with its legacy view box and orientation.
    final p = legacyTrack({
      'shape': 'path', 'path': 'M0 0 L100 0', 'viewBoxWidth': 600, 'viewBoxHeight': 320, //
      'orientToPath': true, 'orientUpright': true,
    })!;
    expect(p.path, const PathFollow(path: 'M0 0 L100 0', viewBox: [600, 320], orient: PathOrient.upright));
    expect(p.toJson(), {
      'path': {'path': 'M0 0 L100 0', 'viewBox': [600, 320], 'orient': 'upright'},
    });
    expect(legacyTrack(p.toJson()), p);
  });

  test('a track that only shows its variable binds its value to it', () {
    final n = _node({
      'drag': {
        'track': {'variable': 'playhead', 'write': false, 'x2': 200, 'y2': 0},
      },
    });
    expect(n.behaviors.track!.variable, '');
    expect(n.bind, {'track.value': r'${playhead}'});
    expect(n.toJson()['track'], {'x2': 200, 'y2': 0});
    // A bound value already given is kept.
    final bound = _node({
      'drag': {
        'track': {'variable': 'v', 'write': false},
      },
      'bind': {'drag.track.value': r'${= v * 2}'},
    });
    expect(bound.bind, {'track.value': r'${= v * 2}'});
  });

  test("the guide's gesture samples read and write back as shown", () {
    final text = File('docs/guide/10-gestures.md').readAsStringSync();
    final blocks = RegExp(r'```json( legacy)?\n([\s\S]*?)```').allMatches(text).toList();
    expect(blocks.length, greaterThanOrEqualTo(15));
    // A legacy (schema-2) sample is migrated first.
    Json written(Json j, {bool legacy = false}) {
      if (j['type'] is String && j.length > 1 && !j.containsKey('bind')) {
        return (legacy ? legacyAction(j) : ActionDef.fromJson(j, catalog: standardCatalog)!).toJson();
      }
      return (legacy ? legacyNode(j) : Node.fromJson({'type': 'box', ...j}, id: 'n', catalog: standardCatalog)!).toJson()
        ..remove('id')
        ..remove('type')
        ..remove('layout');
    }

    for (var i = 0; i < blocks.length; i++) {
      final json = jsonDecode(blocks[i][2]!) as Json;
      if (blocks[i][1] != null) {
        expect(written(json, legacy: true), jsonDecode(blocks[i + 1][2]!), reason: blocks[i][2]);
        continue;
      }
      expect(written(json), json, reason: blocks[i][2]);
      expect(written(json), isNot(contains('drag')));
    }
  });
}
