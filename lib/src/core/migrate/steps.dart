// The steps of the schema 2 → 3 migration, in the order they run. Each is
// small, named and tested on its own (test/migrate_steps_test.dart).
import 'migrate.dart';
import 'steps_actions.dart';
import 'steps_behaviors.dart';
import 'steps_deprecated.dart';
import 'steps_pose.dart';
import 'steps_states.dart';
import 'steps_text.dart';

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
  // First: the patch steps after it find the targets by id.
  stateTargetsStep,
  ..._legacyNodeSteps,
  ..._deprecatedNodeSteps,
  patchesStep([..._legacyNodeSteps, ..._deprecatedNodeSteps]),
  ..._flutterDefaultSteps,
];

/// The steps for schema 3 reading a field as Flutter does where schema 2
/// did not: each writes out (or drops) what schema 2 did, so the document
/// renders the same.
final List<MigrationStep> _flutterDefaultSteps = [
  textPaddingStep,
  textLineHeightStep,
];
