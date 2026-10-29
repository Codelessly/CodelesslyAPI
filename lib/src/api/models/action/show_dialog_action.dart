import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../models.dart';

part 'show_dialog_action.g.dart';

/// Where a [ShowDialogAction] shows its canvas.
enum DialogAnchor {
  /// Centered on the screen.
  none,

  /// Next to the node that ran the action, like a popover or menu, at the
  /// action's [ShowDialogAction.placement].
  trigger;

  /// Displayable name.
  String get prettify => switch (this) {
    DialogAnchor.none => 'Center of screen',
    DialogAnchor.trigger => 'Anchor to trigger',
  };
}

/// The side of the trigger an anchored [ShowDialogAction] opens on, and how
/// it lines up with the trigger along that side.
///
/// Start and end follow the reading direction for [below] and [above]
/// placements (start is the left edge in a left-to-right app) and are the top
/// and bottom edges for [right] and [left] placements. When the dialog does
/// not fit on its side, it opens on the opposite side if there is more room
/// there.
enum DialogPlacement {
  /// Below the trigger, start edges lined up.
  belowStart,

  /// Below the trigger, centered on it.
  belowCenter,

  /// Below the trigger, end edges lined up.
  belowEnd,

  /// Above the trigger, start edges lined up.
  aboveStart,

  /// Above the trigger, centered on it.
  aboveCenter,

  /// Above the trigger, end edges lined up.
  aboveEnd,

  /// Right of the trigger, top edges lined up.
  rightStart,

  /// Right of the trigger, centered on it.
  rightCenter,

  /// Right of the trigger, bottom edges lined up.
  rightEnd,

  /// Left of the trigger, top edges lined up.
  leftStart,

  /// Left of the trigger, centered on it.
  leftCenter,

  /// Left of the trigger, bottom edges lined up.
  leftEnd,

  /// PR42 centered placement, persisted under `placement`.
  center,

  /// PR42 bottom sheet placement.
  bottomSheet,

  /// PR42 adaptive placement.
  adaptive,

  /// PR42 anchored placement below the trigger.
  anchored;

  /// Whether the dialog opens below or above the trigger, rather than beside
  /// it.
  bool get isVertical => index <= DialogPlacement.aboveEnd.index;

  /// Displayable name.
  String get prettify => switch (this) {
    DialogPlacement.belowStart => 'Below, start',
    DialogPlacement.belowCenter => 'Below, center',
    DialogPlacement.belowEnd => 'Below, end',
    DialogPlacement.aboveStart => 'Above, start',
    DialogPlacement.aboveCenter => 'Above, center',
    DialogPlacement.aboveEnd => 'Above, end',
    DialogPlacement.rightStart => 'Right, top',
    DialogPlacement.rightCenter => 'Right, center',
    DialogPlacement.rightEnd => 'Right, bottom',
    DialogPlacement.leftStart => 'Left, top',
    DialogPlacement.leftCenter => 'Left, center',
    DialogPlacement.leftEnd => 'Left, bottom',
    DialogPlacement.center => 'Center',
    DialogPlacement.bottomSheet => 'Bottom sheet',
    DialogPlacement.adaptive => 'Sheet on mobile',
    DialogPlacement.anchored => 'Below trigger',
  };
}

/// Shows a canvas as a dialog, sheet, or popover ([presentation]).
/// A dialog may be centered or anchored to the triggering node ([anchor]).
/// It closes when its barrier is tapped (if [barrierDismissible]) or with a
/// "Navigate back" action inside it.
@JsonSerializable()
class ShowDialogAction extends ActionModel with Equatable, SerializableMixin {
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

  /// How the canvas opens: dialog, bottom sheet, adaptive, side sheet,
  /// full screen, or a trigger-anchored popover.
  @JsonKey(unknownEnumValue: DialogPresentation.dialog)
  final DialogPresentation presentation;

  /// Where a dialog sits on the screen, e.g. top right for a menu. Center by
  /// default. Bottom sheets always sit at the bottom and side sheets at the
  /// right edge.
  final AlignmentModel alignment;

  /// Width of a [DialogPresentation.sideSheet], in logical pixels. Null takes
  /// the destination canvas's width.
  final double? sheetWidth;

  /// Whether a bottom sheet shows a grab handle at its top.
  final bool showDragHandle;

  /// Where the dialog shows: centered, or next to the node that ran the
  /// action.
  @JsonKey(unknownEnumValue: DialogAnchor.none)
  final DialogAnchor anchor;

  /// The side of the trigger an anchored dialog opens on. Only used when
  /// [anchor] is [DialogAnchor.trigger].
  @JsonKey(unknownEnumValue: DialogPlacement.belowStart)
  final DialogPlacement placement;

  /// The space between the trigger and an anchored dialog, in logical
  /// pixels.
  final double anchorGap;

  /// How far an anchored dialog is shifted along the trigger's edge, in
  /// logical pixels: toward the end for [DialogPlacement.isVertical]
  /// placements (right in a left-to-right app), down for the others.
  final double anchorOffset;

  /// Space kept between the overlay and the screen edges: a dialog placed
  /// in a corner stays this far from it, a side sheet is inset by it.
  final EdgeInsetsModel insets;

  /// The most of the screen height a dialog or bottom sheet may take, as a
  /// share of it (e.g. 0.9); content scrolls beyond. The existing default
  /// is 1 (no additional cap), including when omitted from legacy JSON.
  final double maxHeightFactor;

  /// For a bottom sheet: fill its available height with the canvas, so the
  /// canvas scrolls its content. Otherwise the sheet wraps the canvas and
  /// scrolls as one, subject to [maxHeightFactor].
  final bool fullHeight;

  /// Creates a new [ShowDialogAction].
  ShowDialogAction({
    required this.destinationId,
    Map<String, String>? params,
    this.barrierColor = ColorRGBA.black54,
    this.barrierDismissible = true,
    this.showCloseButton = false,
    this.presentation = DialogPresentation.dialog,
    this.alignment = AlignmentModel.center,
    this.sheetWidth,
    this.showDragHandle = false,
    this.anchor = DialogAnchor.none,
    this.placement = DialogPlacement.belowStart,
    this.anchorGap = 4,
    this.anchorOffset = 0,
    this.insets = EdgeInsetsModel.zero,
    this.maxHeightFactor = 1,
    this.fullHeight = false,
    super.nonBlocking,
    super.enabled,
  }) : params = {...params ?? {}},
       super(type: ActionType.showDialog);

  @override
  List<Object?> get props => [
    destinationId,
    params,
    barrierDismissible,
    barrierColor,
    showCloseButton,
    presentation,
    alignment,
    sheetWidth,
    showDragHandle,
    anchor,
    placement,
    anchorGap,
    anchorOffset,
    insets,
    maxHeightFactor,
    fullHeight,
  ];

  /// Whether the dialog opens next to the node that ran the action.
  bool get isAnchored =>
      presentation == DialogPresentation.popover ||
      anchor == DialogAnchor.trigger;

  /// Duplicates this [ShowDialogAction] with given data overrides.
  ShowDialogAction copyWith({
    String? destinationId,
    Map<String, String>? params,
    bool? barrierDismissible,
    ColorRGBA? barrierColor,
    bool? showCloseButton,
    DialogPresentation? presentation,
    AlignmentModel? alignment,
    double? sheetWidth,
    bool clearSheetWidth = false,
    bool? showDragHandle,
    DialogAnchor? anchor,
    DialogPlacement? placement,
    double? anchorGap,
    double? anchorOffset,
    EdgeInsetsModel? insets,
    double? maxHeightFactor,
    bool? fullHeight,
  }) => ShowDialogAction(
    destinationId: destinationId ?? this.destinationId,
    params: {...this.params, ...params ?? {}},
    barrierDismissible: barrierDismissible ?? this.barrierDismissible,
    barrierColor: barrierColor ?? this.barrierColor,
    showCloseButton: showCloseButton ?? this.showCloseButton,
    presentation: presentation ?? this.presentation,
    alignment: alignment ?? this.alignment,
    sheetWidth: clearSheetWidth ? null : sheetWidth ?? this.sheetWidth,
    showDragHandle: showDragHandle ?? this.showDragHandle,
    anchor: anchor ?? this.anchor,
    placement: placement ?? this.placement,
    anchorGap: anchorGap ?? this.anchorGap,
    anchorOffset: anchorOffset ?? this.anchorOffset,
    insets: insets ?? this.insets,
    maxHeightFactor: maxHeightFactor ?? this.maxHeightFactor,
    fullHeight: fullHeight ?? this.fullHeight,
    nonBlocking: nonBlocking,
    enabled: enabled,
  );

  /// Creates a new [ShowDialogAction] instance from a JSON data.
  factory ShowDialogAction.fromJson(Map json) {
    final placement = json['placement'];
    // Legacy PR47 encoded a popover solely as presentation. Normalize it
    // without replacing an explicitly supplied anchor or placement.
    if (json['presentation'] == 'popover') {
      if (json['anchor'] != null && json['anchor'] != 'trigger') {
        throw FormatException('Popover conflicts with explicit anchor: $json');
      }
      if (json['placement'] == 'center' ||
          json['placement'] == 'bottomSheet' ||
          json['placement'] == 'adaptive') {
        throw FormatException('Popover conflicts with modal placement: $json');
      }
      json = {...json, 'anchor': 'trigger'};
    }
    if (placement == 'center' ||
        placement == 'bottomSheet' ||
        placement == 'adaptive' ||
        placement == 'anchored') {
      final expectedPresentation = switch (placement) {
        'bottomSheet' => 'bottomSheet',
        'adaptive' => 'adaptive',
        'anchored' when json['presentation'] == 'popover' => 'popover',
        _ => 'dialog',
      };
      if ((json['presentation'] != null &&
              json['presentation'] != expectedPresentation) ||
          (json['anchor'] != null &&
              json['anchor'] !=
                  (placement == 'anchored' ? 'trigger' : 'none'))) {
        throw FormatException(
          'Conflicting dialog placement and presentation: $json',
        );
      }
      // PR42 used placement for the overlay mode. In the combined wire
      // contract presentation controls its mode, while placement locates an
      // anchored dialog relative to its trigger.
      return _$ShowDialogActionFromJson({
        ...json,
        'presentation': expectedPresentation,
        'anchor':
            json['anchor'] ?? (placement == 'anchored' ? 'trigger' : 'none'),
        'placement': 'belowStart',
      });
    }
    return _$ShowDialogActionFromJson(json);
  }

  @override
  Map toJson() {
    final json = _$ShowDialogActionOmitDefaults(
      this,
      _$ShowDialogActionToJson(this),
    );
    // The combined writer uses presentation for the overlay mode and anchor
    // for the trigger location. PR42's modal placements remain accepted as constructor
    // inputs, but are never emitted as ambiguous placement wire values.
    if (placement == DialogPlacement.center ||
        placement == DialogPlacement.bottomSheet ||
        placement == DialogPlacement.adaptive ||
        placement == DialogPlacement.anchored) {
      json['presentation'] = switch (placement) {
        DialogPlacement.bottomSheet => 'bottomSheet',
        DialogPlacement.adaptive => 'adaptive',
        DialogPlacement.anchored
            when presentation == DialogPresentation.popover =>
          'popover',
        _ => 'dialog',
      };
      if (placement == DialogPlacement.anchored) json['anchor'] = 'trigger';
      json.remove('placement');
    }
    return json;
  }

  @override
  R? accept<R>(ActionVisitor<R> visitor) => visitor.visitShowDialogAction(this);
}

/// How a [ShowDialogAction] presents its canvas.
enum DialogPresentation {
  /// A dialog, centered unless the action gives an alignment.
  dialog,

  /// A modal sheet that slides up from the bottom edge.
  bottomSheet,

  /// A bottom sheet on phones (narrower than 600 px), a dialog otherwise.
  adaptive,

  /// A sheet that slides in from the right edge, inset from the screen.
  /// [ShowDialogAction.sheetWidth] sets its width when provided.
  sideSheet,

  /// Covers the whole screen, like a photo viewer.
  fullScreen,

  /// A trigger-anchored, non-modal popover.
  popover;

  /// Displayable name.
  String get prettify => switch (this) {
    DialogPresentation.dialog => 'Dialog',
    DialogPresentation.bottomSheet => 'Bottom Sheet',
    DialogPresentation.adaptive => 'Adaptive',
    DialogPresentation.sideSheet => 'Side Sheet',
    DialogPresentation.fullScreen => 'Full Screen',
    DialogPresentation.popover => 'Popover',
  };
}
