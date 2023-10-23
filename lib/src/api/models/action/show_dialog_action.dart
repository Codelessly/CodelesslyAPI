// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../models.dart';

part 'show_dialog_action.g.dart';

/// An action that navigates to a new page.
@JsonSerializable()
class ShowDialogAction extends ActionModel
    with EquatableMixin, SerializableMixin {
  /// Destination canvas node's ID.
  final String destinationId;

  /// Parameters to pass to the destination page.
  final Map<String, dynamic> params;

  /// Whether the dialog is dismissible by tapping outside the dialog.
  final bool barrierDismissible;

  /// Color of the barrier that is shown behind the dialog.
  final ColorRGBA? barrierColor;

  /// Whether to show a close button on the dialog.
  final bool showCloseButton;

  /// Creates a new [ShowDialogAction].
  ShowDialogAction({
    required this.destinationId,
    Map<String, String>? params,
    this.barrierColor = ColorRGBA.black54,
    this.barrierDismissible = true,
    this.showCloseButton = false,
  })  : params = {...params ?? {}},
        super(type: ActionType.showDialog);

  @override
  List<Object?> get props => [
        destinationId,
        params,
        barrierDismissible,
        barrierColor,
        showCloseButton,
      ];

  /// Duplicates this [ShowDialogAction] with given data overrides.
  ShowDialogAction copyWith({
    String? destinationId,
    Map<String, String>? params,
    bool? barrierDismissible,
    ColorRGBA? barrierColor,
    bool? showCloseButton,
  }) =>
      ShowDialogAction(
        destinationId: destinationId ?? this.destinationId,
        params: {...this.params, ...params ?? {}},
        barrierDismissible: barrierDismissible ?? this.barrierDismissible,
        barrierColor: barrierColor ?? this.barrierColor,
        showCloseButton: showCloseButton ?? this.showCloseButton,
      );

  /// Creates a new [ShowDialogAction] instance from a JSON data.
  factory ShowDialogAction.fromJson(Map json) =>
      _$ShowDialogActionFromJson(json);

  @override
  Map toJson() => _$ShowDialogActionToJson(this);

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitShowDialogAction(this);
}
