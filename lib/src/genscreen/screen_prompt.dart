/// The prompts the generator sends to a model: a system prompt that carries
/// the design kit and the plan reference (stable per kit, so it caches), a
/// user prompt per screen, and a fix prompt that hands back validation,
/// render and critique findings.
library;

import 'dart:convert';

import 'design_kit.dart';
import 'design_md_writer.dart';
import 'icon_vocabulary.dart';
import 'screen_plan.dart';

/// The plan reference the model reads: every component, action and rule.
const String planReference = r'''
# Screen plan reference

Answer with ONE JSON object (no prose, no code fence) shaped like this:

{
  "title": "Album details",                 // screen title
  "summary": "one sentence",                // what the screen does
  "pattern": "detail",                      // detail|list|form|auth|settings|dashboard|onboarding|checkout|search|profile|feed|gallery|custom
  "appBar": {"title": "Album", "leading": "back", "actions": [{"icon": "share", "label": "Share", "action": {...}}]},
  "nav": {"items": [{"icon": "home", "label": "Home", "active": true}, {"icon": "search", "label": "Search", "action": {...}}]},
  "data": {"album": {"title": "...", "cover": "https://..."}, "tracks": [{"title": "..."}]},
  "variables": [{"name": "email", "type": "text", "value": ""}],
  "sections": [{"id": "hero", "title": "optional heading", "area": "main", "layout": "stack", "children": [ components ]}],
  "states": {
    "loading": {"style": "skeleton"},
    "empty": {"icon": "inbox", "title": "No tracks yet", "message": "...", "action": {"label": "Browse", "action": {...}}},
    "error": {"icon": "error_outline", "title": "Couldn't load", "message": "...", "action": {"label": "Try again", "action": {"type": "retry"}}}
  }
}

## Rules
- Use ONLY the kit's token names for color (`color`), text style (`style`), spacing (`gap`, `size`) and radius (`radius`). Never write hex colors, px sizes or font names.
- Don't name a `data` key or variable after a runtime name: data, product, paywall, entitlements, index, value, item, parent, storage, route, auth, result, screen, hold, drag, track, speech, initial, status (use `productInfo`, `orderStatus`...).
- `data` holds realistic sample values (real-sounding names, prices, dates; image URLs from https://picsum.photos/seed/<word>/<w>/<h>). Bind text to it with `${album.title}`; inside a list or grid item use `${item.field}`.
- Every button, icon button, nav item and tappable row/card has an `action`. Every input, switch, checkbox, segmented control and tab bar has `bind`: a variable declared in `variables` (or a key of `data`).
- `states.loading` and `states.error` are required. `states.empty` is required when the screen shows a `list` or `grid`; its message says what to do next.
- `area`: `main` (default), `aside` (side column on tablet/desktop, stacked in plan order on mobile) or `full` (spans both columns above them). Put a detail screen's hero/summary in `aside` and its long content in `main`, a dashboard's KPIs in `full`.
- `layout` of a section: `stack` (default: one column), `row` (side by side), `grid`/`cards` (children in columns: `"columns": {"mobile": 1, "desktop": 3}`).
- The app bar's title is short (1-3 words). Mobile screens get a bottom `nav` only if the app has top-level destinations (home, search, library, profile...); detail/form screens use `"leading": "back"` instead.
- Keep copy in the kit's voice. Sentence case unless the kit says otherwise. No lorem ipsum.
- Prefer kit components over generic groups. Don't nest cards. One primary button per section.

## Components (`type` and fields; * = required)
- text: text*, style (display|headline|title|subtitle|body|label|caption), color, align (left|center|right), maxLines
- heading: title*, subtitle, eyebrow, align, size (large for hero titles)
- image: src (URL or binding), kind (hero|cover), aspect ("16:9"), radius
- avatar: src or initials, size (large)
- icon: icon*, color, size
- button: label*, action*, variant (primary|secondary|outline|ghost|destructive), icon, fullWidth, size (small)
- iconButton: icon*, label (for screen readers), action*, variant
- buttonRow: buttons* (button components), align (start|center|end)
- input: label*, bind*, kind (text|email|password|number|phone|search|multiline), hint, helper, icon
- switchRow: title*, bind*, subtitle, icon, action (runs on change)
- checkbox: label*, bind*
- segmented: options* (strings), bind*
- tabs: tabs* (strings), bind*
- chips: items* (strings, {"label","selected","icon","action"}, or a list binding), bind
- listRow: title*, subtitle, leading ({"icon"}|{"image": url}|{"avatar": url}|{"initials"}|{"text"}), trailing ("chevron"|"text"|{"text"}|{"badge","tone"}|{"icon","action"}), action
- list: items* ("${tracks}" or an array), item* (one component, usually listRow, using ${item.x}), gap
- grid: items*, item* (usually card), columns ({"mobile":2,"desktop":4}), itemHeight
- card: title, subtitle, eyebrow, body, image, aspect, price, meta, button ({label, action, variant}), children, action
- stat: label*, value*, delta ("+12%"), tone (success|error|neutral)
- keyValue: label*, value*, emphasis (bold total row)
- banner: title*, message, tone (info|success|warning|error), icon, action ({"label","action"})
- badge: text*, tone
- divider
- progress: value* (0-1 or a binding), label, caption, color
- rating: value* (0-5 or a binding), label
- group: children*, direction (row|column), gap, align, justify, wrap, surface (true = card background), action
- spacer: size (spacing token)
- deck: items* (a list binding; each item needs an "id"), front* (components for the card's front, using ${item.x}), back (components for the back; tapping the card flips it in 3D), swipeRight (action when the top card is swiped right), swipeLeft (action when swiped left); a deck bound to a variable advances by itself: swiping right removes the top card, left moves it to the back, flipVariable (boolean variable the flip reads, default "flipped"), labels ({"right": "Known", "left": "Review"}: stamps that fade in while dragging)
Any component may have `visible`: a formula such as "${= cart.length > 0}".

## Actions (`type` and fields)
- navigate: to (screen name), params
- back
- set: variable, value (text or formula "${= count + 1}")
- toggle: variable (boolean)
- toast: message
- link: url
- submit: message (shows loading, then the message)
- retry (reloads: loading, then content)
- speak: text, language ("en-US")
- call: name, params (an app function). Every app has `listen` {language: "en-US", expected: "the text to say"}: it records the learner once and fills ${speech.listening}, ${speech.heard} (what was heard), ${speech.score} (0-100 against expected), ${speech.error}; ${speech.canListen} says whether this device can listen. ${speech.speaking} is true while a speak action talks.
- swipe: direction (right|left): flings the deck's top card that way, as if swiped (Known / Review buttons)
- generate: prompt (generates and opens another screen at runtime)
- save: key, value, valueType (text|integer|decimal|boolean|list|map): keeps a value on the device; read it back anywhere as ${storage.key}
Any action may have `then`: another action (or a list) to run after it.
''';

/// Builds the prompts for one kit.
class ScreenPrompt {
  /// The kit the screens use.
  final DesignKit kit;

  /// Creates a [ScreenPrompt].
  const ScreenPrompt(this.kit);

  /// The system prompt: role, the kit verbatim, the plan reference and the
  /// icon vocabulary. Stable for a kit, so it is the cached prefix.
  String system() {
    final List<String> icons = iconVocabulary.keys
        .where((String k) => !k.endsWith('_outlined'))
        .toList();
    return '''
You are a senior product designer who builds app screens for Codelessly. You
turn a one-line request into a screen plan: JSON that a compiler turns into a
responsive Codelessly screen (mobile, tablet and desktop) with loading, empty
and error states. Your screens look like they were made by the brand's own
team: they follow the design kit below exactly, use its voice, and feel like a
real, finished product (real content, sensible hierarchy, no filler).

<design_kit name="${kit.name}" version="${kit.version}">
${const DesignMdWriter().write(kit)}
</design_kit>

Token names you may use:
- color: ${kit.colors.keys.join(', ')}
- style: ${kit.typography.keys.join(', ')}
- spacing: ${kit.spacing.keys.join(', ')}
- radius: ${kit.radius.keys.join(', ')}

$planReference

## Icons
Material icon names, snake_case. Use only these: ${icons.join(', ')}.
''';
  }

  /// The request for one screen.
  String user(
    String prompt, {
    Map<String, Object?>? dataSchema,
    Iterable<String> screens = const <String>[],
  }) {
    final StringBuffer out = StringBuffer()
      ..writeln('Screen: $prompt');
    if (screens.isNotEmpty) {
      out.writeln(
        'Other screens of this app (navigate to them by name): ${screens.join(', ')}.',
      );
    }
    if (dataSchema != null) {
      out
        ..writeln('Bind the screen to data of this shape (keep these keys; fill `data` with realistic values):')
        ..writeln(const JsonEncoder.withIndent('  ').convert(dataSchema));
    }
    out.writeln('Answer with the plan JSON only.');
    return out.toString();
  }

  /// A follow-up asking for a corrected plan: validation [issues], findings
  /// from rendering it (overflows, clipped text), and a critique of the
  /// screenshots.
  String fix({
    List<PlanIssue> issues = const <PlanIssue>[],
    List<String> renderFindings = const <String>[],
    String critique = '',
  }) {
    final StringBuffer out = StringBuffer()
      ..writeln('Your plan needs changes. Fix every point and answer with the complete corrected plan JSON only.');
    if (issues.isNotEmpty) {
      out.writeln('\nValidation:');
      for (final PlanIssue i in issues) {
        out.writeln('- $i');
      }
    }
    if (renderFindings.isNotEmpty) {
      out.writeln('\nWhen rendered:');
      for (final String f in renderFindings) {
        out.writeln('- $f');
      }
    }
    if (critique.trim().isNotEmpty) {
      out
        ..writeln('\nDesign review of the screenshots:')
        ..writeln(critique.trim());
    }
    return out.toString();
  }

  /// The system prompt of the screenshot reviewer.
  String critiqueSystem() => '''
You review generated app screens against the "${kit.name}" design kit. You get
screenshots of one screen at mobile (390), tablet (834) and desktop (1440)
widths. List concrete problems only: layout that looks broken or unbalanced
at a width, content that is cut off or overlapping, missing hierarchy, copy
that breaks the kit's voice, controls that look disabled or unlabeled,
anything that looks unfinished. Ignore grey image placeholders (photos load
at runtime). Answer with JSON: {"pass": true|false, "score": 1-5, "problems": ["..."]}.

Kit summary: ${kit.description}
Brand: ${kit.brand['personality'] ?? ''}; voice: ${kit.brand['voice'] ?? ''}
''';
}

/// The cache key of a generated screen: the normalized prompt, the kit's
/// fingerprint (version + content hash) and the data schema.
String screenCacheKey(
  String prompt,
  DesignKit kit, {
  Map<String, Object?>? dataSchema,
}) {
  final String normalized = prompt.trim().toLowerCase().replaceAll(
    RegExp(r'\s+'),
    ' ',
  );
  final String schema = dataSchema == null ? '' : jsonEncode(dataSchema);
  return '${kit.name.toLowerCase()}@${kit.fingerprint}/${fnvHex('$normalized|$schema')}';
}

/// Pulls the plan JSON out of a model's answer (tolerates a code fence or a
/// sentence around it). Throws [FormatException] when there is none.
Map<String, dynamic> extractPlanJson(String answer) {
  String text = answer.trim();
  final Match? fence = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(text);
  if (fence != null) text = fence[1]!.trim();
  final int start = text.indexOf('{');
  final int end = text.lastIndexOf('}');
  if (start < 0 || end <= start) {
    throw const FormatException('No JSON object in the answer.');
  }
  final Object? decoded = jsonDecode(text.substring(start, end + 1));
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('The answer is not a JSON object.');
  }
  return decoded;
}
