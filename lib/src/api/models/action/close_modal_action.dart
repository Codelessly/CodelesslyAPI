import '../models.dart';

/// Closes the active modal dialog without navigating or opening a new one.
///
/// [params] are handed back to the action chain that showed the dialog: the
/// actions after its `showDialog` read them as `${result.<name>}` (e.g. a
/// parent gate closing with `{"passed": true}`). Values may use `${...}`.
class CloseModalAction extends ActionModel {
  /// Values returned to the chain that showed the dialog.
  final Map<String, dynamic> params;

  /// Creates a close-modal action.
  CloseModalAction({this.params = const {}})
    : super(type: ActionType.closeModal);

  /// Reads the close-modal wire format: `type` and optional `params`.
  factory CloseModalAction.fromJson(Map json) {
    if (json['type'] != 'closeModal' ||
        json.keys.any((key) => key != 'type' && key != 'params')) {
      throw const FormatException(
        'CloseModalAction expects type: closeModal and optional params',
      );
    }
    final Object? params = json['params'];
    if (params != null && params is! Map) {
      throw const FormatException('CloseModalAction params must be a map');
    }
    return CloseModalAction(
      params: params == null
          ? const {}
          : Map<String, dynamic>.from(params as Map),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'closeModal',
    if (params.isNotEmpty) 'params': params,
  };

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitCloseModalAction(this);
}
