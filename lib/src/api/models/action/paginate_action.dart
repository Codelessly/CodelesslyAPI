import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../mixins.dart';
import '../models.dart';

part 'paginate_action.g.dart';

/// What a [PaginateAction] does to a pagination controller.
enum PaginateCommand {
  /// Shows (or, when it scrolls, loads) the next page.
  next,

  /// Shows the page before the current one, or in a list that loads in
  /// both directions, loads the page before the first one loaded.
  previous,

  /// Shows page [PaginateAction.page].
  goTo,

  /// Shows the first page.
  first,

  /// Shows the last page, once the number of pages is known.
  last,

  /// Forgets the loaded pages and loads the first page again (pull to
  /// refresh).
  refresh,

  /// Loads again the page that failed to load.
  retry,

  /// Changes how many items a page holds to [PaginateAction.pageSize],
  /// keeping the first item shown on screen.
  setPageSize;

  /// Displayable name.
  String get prettify => switch (this) {
    next => 'Next page',
    previous => 'Previous page',
    goTo => 'Go to page',
    first => 'First page',
    last => 'Last page',
    refresh => 'Refresh',
    retry => 'Retry',
    setPageSize => 'Set page size',
  };
}

/// Moves a pagination controller (a list's [PaginationModel]) by its
/// name: next, previous, go to a page, refresh, retry...
@JsonSerializable()
class PaginateAction extends ActionModel with Equatable, SerializableMixin {
  /// The [PaginationModel.name] of the controller.
  final String controller;

  /// What to do.
  final PaginateCommand command;

  /// The page to go to for [PaginateCommand.goTo], from 1: a number or a
  /// `${...}` path such as `${value}`.
  final String page;

  /// The page size for [PaginateCommand.setPageSize]: a number or a
  /// `${...}` path.
  final String pageSize;

  /// Creates a [PaginateAction].
  PaginateAction({
    this.controller = '',
    this.command = PaginateCommand.next,
    this.page = '1',
    this.pageSize = '20',
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.paginate);

  /// Duplicates this action with the given values replaced.
  PaginateAction copyWith({
    String? controller,
    PaginateCommand? command,
    String? page,
    String? pageSize,
  }) => PaginateAction(
    controller: controller ?? this.controller,
    command: command ?? this.command,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  @override
  List<Object?> get props => [controller, command, page, pageSize];

  /// Creates an instance from a JSON object.
  factory PaginateAction.fromJson(Map json) => _$PaginateActionFromJson(json);

  @override
  Map toJson() =>
      _$PaginateActionOmitDefaults(this, _$PaginateActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitPaginateAction(this);
}
