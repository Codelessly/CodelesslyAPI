// The steps of the schema 2 → 3 migration, in the order they run. Each is
// small, named and tested on its own (test/migrate_steps_test.dart).
import 'migrate.dart';
import 'steps_actions.dart';
import 'steps_behaviors.dart';
import 'steps_deprecated.dart';
import 'steps_pose.dart';

/// The node steps, in order: the legacy readers of schema 2, moved out of
/// the model.
final List<MigrationStep> _legacyNodeSteps = [
  motionLegacyStep,
  poseLegacyStep,
  dragSplitStep,
  trackLegacyStep,
  zoomableStep,
  draggableLegacyStep,
  physicsSpringStep,
  transitionsLegacyStep,
  gradientUnitsStep,
  playAnimationStep,
  animateVariableStep,
  setVariableGlideStep,
  controlDragStep,
  clockTriggerStep,
];

/// The node steps that drop the deprecated one-app fields, after the
/// legacy keys are in the schema-3 shape.
final List<MigrationStep> _deprecatedNodeSteps = [
  trackOneAppStep,
  dismissibleOneAppStep,
  panOneAppStep,
  pathOneAppStep,
  transitionArcStep,
  dropTargetOneAppStep,
  gestureOneAppStep,
  openModalOneAppStep,
];

/// The steps of `migrate2to3`, in order.
final List<MigrationStep> migrationSteps2to3 = [
  ..._legacyNodeSteps,
  ..._deprecatedNodeSteps,
  patchesStep([..._legacyNodeSteps, ..._deprecatedNodeSteps]),
];
