import '../migrate.dart';
import 'collections.dart';
import 'indicators.dart';
import 'inputs.dart';
import 'material.dart';
import 'media.dart';

/// Every per-type migration, by v1 node type.
final Map<String, TypeMigration> typeMigrations = {
  ...collectionsMigrations,
  ...inputsMigrations,
  ...materialMigrations,
  ...indicatorsMigrations,
  ...mediaMigrations,
};
