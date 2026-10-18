import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'cloud_files_action.g.dart';

/// What a [CloudFilesAction] does.
enum CloudFilesOperation {
  /// Lets the user pick files and uploads them.
  upload,

  /// Deletes the file at [CloudFilesAction.path].
  delete;

  /// A readable name for this operation.
  String get label => switch (this) {
    upload => 'Upload Files',
    delete => 'Delete File',
  };
}

/// Which files the picker offers for [CloudFilesOperation.upload].
enum CloudFilesType {
  /// Images only.
  image,

  /// Any file.
  any,
}

/// Uploads files the user picks to the project's cloud storage, or deletes
/// one.
///
/// Files are stored under the project's own folder, so [path] is relative to
/// it. For an upload, [path] is the folder (e.g. `albums/${route.albumId}`)
/// and each file is stored there under a new id with its extension. For a
/// delete, [path] is the file's path as an upload reported it.
///
/// After each file is uploaded, [actions] run with `${result}` set to the
/// file: `${result.url}` (download URL), `${result.path}`, `${result.id}`,
/// `${result.name}`, `${result.extension}`, `${result.contentType}`,
/// `${result.index}` and `${result.total}`.
///
/// [progressVariable], when set, is a map variable that receives
/// `{"uploading": bool, "current": int, "total": int}` while files upload.
@JsonSerializable()
class CloudFilesAction extends ActionModel with Equatable, SerializableMixin {
  /// What to do.
  final CloudFilesOperation operation;

  /// The folder to upload to, or the file to delete, relative to the
  /// project's storage folder. May contain variable paths.
  final String path;

  /// Which files the picker offers.
  final CloudFilesType fileType;

  /// Whether the user may pick more than one file.
  final bool allowMultiple;

  /// Largest file accepted, in megabytes. Larger files are skipped.
  final num maxSizeMB;

  /// Map variable that receives the upload progress.
  final VariableData? progressVariable;

  /// Actions to run after each file uploads, with `${result}` set to it.
  final List<ActionModel> actions;

  /// Creates a [CloudFilesAction].
  CloudFilesAction({
    this.operation = CloudFilesOperation.upload,
    this.path = '',
    this.fileType = CloudFilesType.image,
    this.allowMultiple = true,
    this.maxSizeMB = 10,
    this.progressVariable,
    List<ActionModel>? actions,
    super.nonBlocking,
    super.enabled,
  }) : actions = actions ?? [],
       super(type: ActionType.cloudFiles);

  /// Duplicates this action with the given values replaced.
  CloudFilesAction copyWith({
    CloudFilesOperation? operation,
    String? path,
    CloudFilesType? fileType,
    bool? allowMultiple,
    num? maxSizeMB,
    VariableData? progressVariable,
    List<ActionModel>? actions,
  }) => CloudFilesAction(
    operation: operation ?? this.operation,
    path: path ?? this.path,
    fileType: fileType ?? this.fileType,
    allowMultiple: allowMultiple ?? this.allowMultiple,
    maxSizeMB: maxSizeMB ?? this.maxSizeMB,
    progressVariable: progressVariable ?? this.progressVariable,
    actions: actions ?? this.actions,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [
    operation,
    path,
    fileType,
    allowMultiple,
    maxSizeMB,
    progressVariable,
    actions,
  ];

  /// Creates an instance from a JSON object.
  factory CloudFilesAction.fromJson(Map json) =>
      _$CloudFilesActionFromJson(json);

  @override
  Map toJson() =>
      _$CloudFilesActionOmitDefaults(this, _$CloudFilesActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitCloudFilesAction(this);
}
