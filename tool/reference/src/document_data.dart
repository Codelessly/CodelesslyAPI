// Plain facts about the document format that the reference prints and no
// declaration in lib/ carries: the value types' JSON forms, the names the
// runtime gives every expression, the page variables scope and a canvas's
// route keys. Private to the generator.

/// The JSON forms each value type reads, as a reader would write them.
const Map<String, String> valueForms = {
  'Color': '"#AARRGGBB" or "#RRGGBB" (hex, alpha first)',
  'EdgeInsets': 'a number (all sides) or [left, top, right, bottom]',
  'BorderRadius': 'a number (every corner), [x, y] (every corner elliptical) or [topLeft, topRight, bottomRight, bottomLeft] (each a number or [x, y])',
  'Alignment': '[x, y] from -1 to 1, or a name: topLeft, topCenter, topRight, centerLeft, center, centerRight, bottomLeft, bottomCenter, bottomRight',
  'Offset': '[dx, dy]',
  'BoxConstraints': '{"minWidth", "maxWidth", "minHeight", "maxHeight"} (each optional, numbers >= 0)',
  'AxisSize': 'a number (fixed) or {"fill"|"flexible"|"hug"|"fixed": number}',
  'AxisPosition': 'a number (distance from the start) or {"start": d}, {"end": d}, {"start": a, "end": b}, {"align": -1..1}, {"relative": d}',
  'FontWeight': '100, 200 ... 900',
  'FontFeature': 'an OpenType tag ("tnum", "ss01") or "tag=value" ("liga=0")',
  'Rect': '[left, top, width, height]',
  'IconData': 'a Material icon name ("check_circle", "lock_open_rounded"), an image URL, or {"type": "MATERIAL_ICON", "name", "style"}',
  'Size': '[width, height]',
};

/// Names the runtime provides to every expression (besides the screen's
/// variables): the app's data, route params, device storage, the screen's
/// size class, the theme, a list's item, the previous action's result,
/// a loop's item, auth, drag and drop, frame timings, node scopes (a track,
/// a dismissible, a pan, a transform gesture, flip card, tilt, view progress,
/// sticky header, form), scripts and speech.
const Set<String> runtimeScopes = {
  'data', 'route', 'storage', 'screen', 'device', 'theme', 'item', 'index', 'parent', 'result', 'loop', 'auth', //
  'drag', 'perf', 'track', 'dismiss', 'pan', 'transform', 'flip', 'tilt', 'view', 'sticky', 'script', 'speech', 'pageOffset', 'form',
};

/// The variables scope shared by every canvas of a page.
const String pageVariablesScope = 'page_variables';

/// The keys a canvas node reads beyond node fields: its URL path, and how it
/// opens from a link (`ScreenRoute`: `under`, `translucent`).
const Set<String> canvasRouteKeys = {'path', 'under', 'translucent'};
