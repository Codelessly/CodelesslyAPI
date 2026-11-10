import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../json_defaults.dart';
import '../mixins.dart';

part 'list_sections.g.dart';

/// Groups the items of a data list into sections, each under a header:
/// contacts under A, B, C..., messages under their day.
///
/// Consecutive items with the same [groupBy] value form a section (sort
/// the data by it first). The header node ([headerNodeId], a child of the
/// list after the item template) is built for each section with `${item}`
/// set to `{key, count, index}`: the section's value, how many items it
/// has and its position among the sections.
@JsonSerializable()
class ListSectionsModel with Equatable, SerializableMixin {
  /// What groups the items, evaluated for each item: a path in the item
  /// (`group`, `date.day`) or a `${...}` binding or formula, e.g.
  /// `${= upper(left(item.name, 1))}` for the first letter.
  final String groupBy;

  /// The node drawn as each section's header.
  final String headerNodeId;

  /// Whether the current section's header stays pinned at the top of the
  /// list until the next header pushes it out.
  final bool sticky;

  /// Whether an index of the sections' keys runs along the list's edge
  /// (A–Z): tapping or dragging over a key jumps to its section.
  final bool indexBar;

  /// Creates a [ListSectionsModel].
  const ListSectionsModel({
    this.groupBy = '',
    this.headerNodeId = '',
    this.sticky = true,
    this.indexBar = false,
  });

  /// Whether the list has sections.
  bool get isActive => groupBy.trim().isNotEmpty && headerNodeId.isNotEmpty;

  /// Duplicates this instance with the given data overrides.
  ListSectionsModel copyWith({
    String? groupBy,
    String? headerNodeId,
    bool? sticky,
    bool? indexBar,
  }) => ListSectionsModel(
    groupBy: groupBy ?? this.groupBy,
    headerNodeId: headerNodeId ?? this.headerNodeId,
    sticky: sticky ?? this.sticky,
    indexBar: indexBar ?? this.indexBar,
  );

  @override
  List<Object?> get props => [groupBy, headerNodeId, sticky, indexBar];

  /// Creates a [ListSectionsModel] from a JSON object.
  factory ListSectionsModel.fromJson(Map json) =>
      _$ListSectionsModelFromJson(json);

  @override
  Map toJson() =>
      _$ListSectionsModelOmitDefaults(this, _$ListSectionsModelToJson(this));
}
