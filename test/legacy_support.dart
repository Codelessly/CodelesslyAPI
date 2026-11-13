// Schema-2 JSON as schema 3 reads it: through the migration (migrate2to3),
// for the tests written against the schema-2 decoders' legacy reading.
import 'package:codelessly_api/codelessly_api.dart';

/// A schema-2 node [j] (a box with id `n` unless it says otherwise), migrated
/// and decoded.
Node legacyNode(Json j, {Catalog? catalog}) =>
    Node.fromJson(migrateNode2to3({'id': 'n', 'type': 'box', ...j}), catalog: catalog ?? standardCatalog)!;

/// A schema-2 node's behaviors.
Behaviors legacyBehaviors(Json j) => legacyNode(j).behaviors;

/// A schema-2 `motion` object.
Motion? legacyMotion(Json motion) => legacyBehaviors({'motion': motion}).motion;

/// A schema-2 `track` object.
Track? legacyTrack(Json track) => legacyBehaviors({'track': track}).track;

/// A schema-2 `draggable` object.
DragSource? legacyDraggable(Json d) => legacyBehaviors({'draggable': d}).draggable;

/// A schema-2 `transitions` value.
List<Transition> legacyTransitions(Object? t) => legacyBehaviors({'transitions': t}).transitions;

/// A schema-2 `physics` object (as a pan's).
GesturePhysics? legacyPhysics(Json p) => legacyBehaviors({'pan': {'physics': p}}).pan?.physics;

/// A schema-2 action.
ActionDef legacyAction(Json a) => legacyNode({
      'actions': [
        {'trigger': {'type': 'click'}, 'actions': [a]},
      ],
    }).actions.single.actions.single;

/// A schema-2 trigger.
Trigger legacyTrigger(Json t) => legacyNode({
      'actions': [
        {'trigger': t, 'actions': <Object?>[]},
      ],
    }).actions.single.trigger;

/// A schema-2 paint.
Paint legacyPaint(Json p) => legacyNode({
      'decoration': {
        'fills': [p],
      },
    }).decoration.fills.single;

/// A schema-2 `loops[index]` entry, as the animation `loop<index>` it became.
NodeAnimation? legacyLoop(Json loop, int index) => legacyBehaviors({
      'loops': [...List<Object?>.filled(index, null), loop],
    }).animations.where((a) => a.id == 'loop$index').firstOrNull;

/// A schema-2 `effectAnimations[index]` entry, as the animation it became.
NodeAnimation? legacyEffect(Json effect, int index) => legacyBehaviors({
      'effectAnimations': [...List<Object?>.filled(index, null), effect],
    }).animations.lastOrNull;

/// What schema 2's `zoomable: true` became.
const zoomableGesture = TransformGesture(target: TransformTarget.content, pan: TransformPan.whenZoomed);

/// [Node.fromJson] of schema-2 node JSON (migrated first; a schema-3 node
/// is unchanged by it).
Node? migratedNode(Object? json, {String? id, Catalog? catalog}) =>
    Node.fromJson(json is Map ? migrateNode2to3(readMap(json)!, id: id ?? '') : json, id: id, catalog: catalog);

/// [Behaviors.fromJson] of schema-2 node JSON.
Behaviors migratedBehaviors(Json m) => Behaviors.fromJson(migrateNode2to3(m));
