// The steps of the schema 2 → 3 migration, in the order they run. Each is
// small, named and tested on its own (test/migrate_steps_test.dart).
import 'migrate.dart';
import 'steps_actions.dart';
import 'steps_behaviors.dart';

/// The node steps, in order: the legacy readers of schema 2, moved out of
/// the model.
final List<MigrationStep> _legacyNodeSteps = [
  motionLegacyStep,
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

/// The steps of `migrate2to3`, in order.
final List<MigrationStep> migrationSteps2to3 = [
  ..._legacyNodeSteps,
  patchesStep(_legacyNodeSteps),
];
