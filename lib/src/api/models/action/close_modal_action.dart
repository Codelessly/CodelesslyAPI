import '../models.dart';

/// Closes the active modal dialog without navigating or opening a new one.
class CloseModalAction extends ActionModel {
  /// Creates a close-modal action.
  CloseModalAction() : super(type: ActionType.closeModal);

  /// Reads the parameterless close-modal wire format.
  factory CloseModalAction.fromJson(Map json) {
    if (json.length != 1 || json['type'] != 'closeModal') {
      throw const FormatException(
        'CloseModalAction expects only type: closeModal',
      );
    }
    return CloseModalAction();
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'closeModal'};

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitCloseModalAction(this);
}
