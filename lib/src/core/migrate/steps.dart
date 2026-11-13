// The steps of the schema 2 → 3 migration, in the order they run. Each is
// small, named and tested on its own (test/migrate_test.dart).
import 'migrate.dart';

/// The steps of `migrate2to3`, in order.
final List<MigrationStep> migrationSteps2to3 = [];
