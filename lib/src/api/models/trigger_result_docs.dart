import 'trigger.dart';

/// What each trigger's actions read in `${result}`: the contract the SDK
/// keeps, which the Editor shows next to a reaction and the MCP returns
/// from `triggers.describe`. See `CodelesslyEditor/docs/gestures_api.md`.
extension TriggerResultDocs on TriggerType {
  /// The `${result.*}` fields this trigger's actions read, as one line of
  /// text; empty for a trigger that passes no result.
  String get resultDoc => triggerResultDocs[this] ?? '';
}

/// [TriggerResultDocs.resultDoc] for every trigger that passes a result.
const Map<TriggerType, String> triggerResultDocs = {
  TriggerType.click: '',
  TriggerType.changed:
      'On a text field: the text as \${result}. On a drag track: '
      'value. On a transform gesture: x, y (px from layout), scale, '
      'rotation (degrees), scaleX, scaleY, pointerCount, gesture (pan, pinch, '
      'wheel, doubleTap, handle, fling, settle or variable).',
  TriggerType.changeEnd:
      'On a slider or drag track: value. On a transform gesture: the pose '
      'as for changed, plus velocityX and velocityY; fires once when the '
      'gesture and its settle animation end.',
  TriggerType.drag:
      'dx, dy (from rest for a drag model, from pointer down for a plain '
      'reaction), deltaX, deltaY (this move), x, y (local), globalX, '
      'globalY, width, height (the node), pointerCount, shift, alt, meta.',
  TriggerType.dragEnd:
      'dx, dy, velocityX, velocityY (px/s), dismissed, direction, blocked, '
      'pointerCount; with drag physics also targetX, targetY (where it '
      'settles) and snapIndex (-1 for none). On a drag track: value.',
  TriggerType.swipeLeft: 'direction (left).',
  TriggerType.swipeRight: 'direction (right).',
  TriggerType.swipeUp: 'direction (up).',
  TriggerType.swipeDown: 'direction (down).',
  TriggerType.pinch:
      'scale (since the previous step), totalScale (since it started), '
      'rotation (degrees since the previous step), totalRotation, x, y (the '
      'focal point, local), deltaX, deltaY (how far it moved), pointerCount.',
  TriggerType.wheel:
      'deltaX, deltaY, x, y (local), ctrl (Control or Command held: a '
      'browser trackpad pinch), shift, alt, meta, trackpad.',
  TriggerType.doubleTap:
      'x, y (local). On a transform gesture with double tap zoom also scale, '
      'the scale it zooms to.',
  TriggerType.pointerDown:
      'x, y (local), globalX, globalY, button (primary, secondary, middle), '
      'shift, alt, meta.',
  TriggerType.pointerUp:
      'x, y (local), globalX, globalY, button, shift, alt, meta.',
  TriggerType.scroll: 'offset, max, fraction (0 to 1).',
  TriggerType.secondaryClick: 'x, y (global).',
  TriggerType.reorder: 'from, to (row indexes).',
  TriggerType.dragStart:
      'data, group, count, key, beforeId, before, index, accepted (also as '
      '\${drag}).',
  TriggerType.dragCancel: 'data, group, count, key (also as \${drag}).',
  TriggerType.dragCompleted: 'data, group, count, key (also as \${drag}).',
  TriggerType.drop:
      'data, group, count, key, beforeId, before, index, accepted.',
  TriggerType.dragEnter: 'data, group, count, key, index.',
  TriggerType.dragExit: 'data, group, count, key.',
  TriggerType.dragHover: 'data, group, count, key, index.',
  TriggerType.dropFull:
      'data, group, count, key, beforeId, before, index; the target is '
      r'full (its fullIf holds) and ${drag.full} is true.',
  TriggerType.dropRejected:
      'data, group, count, key, beforeId, before, index, accepted (false).',
  TriggerType.keyDown: 'key, shift, alt, meta, typing.',
  TriggerType.keyUp: 'key, shift, alt, meta, typing.',
  TriggerType.clock: 'tick, at, waitMs.',
  TriggerType.longPress: '',
  TriggerType.hold: 'none; \${hold} is the 0 to 1 progress while held.',
};
