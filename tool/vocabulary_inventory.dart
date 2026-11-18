// Every word the notation's expander accepts, by kind, from the code's own
// declarations (track B, step B1: docs/design/23-base-and-dictionary.md).
//
//   dart run tool/vocabulary_inventory.dart --sdk <CodelesslySDK folder>
//       [--round10 <VOCABULARY-round-10.md>] [--out docs/design/base-inventory]
//
// Run from the package root of an LF copy (as the other tools are). Writes
// <out>/inventory.json and <out>/INVENTORY.md. Nothing in them is typed by
// hand but what [_handKept] lists (where the code has no declaration to read),
// and those rows say so.
//
// The kinds (design note 23, section 2):
//   a  base       a node type, property, event, action, formula function,
//                 value or grammar word the renderer and the parser implement
//   b  rewrite    a word the expander rewrites into other lines in Dart code
//   c  alias      another name of a word (an alias table, a universal word's
//                 other spelling, a key a type spells otherwise), and the
//                 universal words
//   d  component  a design system's component or defined word (data already)
//   e  short      a short name of a node type the parser finishes with code
//                 of its own (`Avatar`, `Grid`, `NumberInput`)
//
// Counts: the first corpus (the SDK's tool/vocabulary/corpus*/*/answers),
// the round 10 harvest (its "Every word beyond the core" table, which lists
// only the words beyond the core, and the quoted notation in the harvest),
// and the notation reference's examples (its ```notation blocks). Taught: in
// the prompt the open vocabulary gives (`--open`, 1440 wide) and in the full
// prompt (1440 wide); documented: named in docs/reference/notation/*.md.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/notation/formula_names.dart' show notationFormulaFunctionNames;
import 'package:codelessly_api/src/core/notation/keys.dart' show notationKeyNames, notationShortKeys, notationTypeKeys, notationTextStyleKeys, notationFieldStyleKeys;
import 'package:codelessly_api/src/core/notation/media_words.dart' show mediaSizes;
import 'package:codelessly_api/src/core/notation/notation.dart' show notationAnimations, badgeVariants, notationEventNames, notationEventName, notationStateNames;
import 'package:codelessly_api/src/core/notation/page_words.dart' show PageWords;
import 'package:codelessly_api/src/core/notation/vocabulary.dart' show lineRewrites, parameterSynonyms;

import 'dictionary/closure.dart' show canonical, expandPage;

const _notationDir = 'lib/src/core/notation';

/// Where the code has nothing to read: each entry says why.
const _handKept = <String, String>{
  'rewriteFunctions': 'The function and file that rewrites each page word (kind b): read from the code by hand, '
      'since a word set does not say which branch of PageWords._rewrite reads it.',
  'contextual': 'The rewrites of base words in a context (a Text with a look, a Badge with a width, a Row that turns at '
      'a width, an Input in a bar, a gallery opening the page viewer, `sticky=true`, an Avatar\'s `src=`): branches of '
      'PageWords._rewrite and _plain with no word set of their own.',
  'statements': 'The statement words a line may start with that are no node (`state`, `each`, `if` …): define.dart\'s '
      '_statements, read from the source, with `define`, `primitive`, `component` and `project` added from the grammar.',
};

void main(List<String> args) {
  String? opt(String name) {
    final i = args.indexOf(name);
    return i < 0 || i + 1 >= args.length ? null : args[i + 1];
  }

  final sdk = opt('--sdk');
  if (sdk == null) {
    stderr.writeln('usage: dart run tool/vocabulary_inventory.dart --sdk <CodelesslySDK> [--round10 <md>] [--out <dir>]');
    exit(2);
  }
  final out = opt('--out') ?? 'docs/design/base-inventory';
  final round10 = opt('--round10');
  final inv = _Inventory(sdk);
  inv.collect();
  inv.count(round10);
  inv.probe();
  Directory(out).createSync(recursive: true);
  File('$out/inventory.json').writeAsStringSync('${const JsonEncoder.withIndent(' ').convert(inv.toJson())}\n');
  File('$out/INVENTORY.md').writeAsStringSync(inv.markdown(round10 != null));
  stdout.writeln('${inv.words.length} words: ${[for (final k in _kinds.keys) '$k ${inv.words.values.where((w) => w.kind == k).length}'].join(', ')}');
}

const _kinds = {
  'a': 'base: implemented by the renderer and the parser',
  'b': 'rewrite: written out into other lines by Dart code in the expander',
  'c': 'alias or universal word: another name, or a word every line takes',
  'd': 'design system: a component or a defined word (data)',
  'e': 'short name: a node type the parser finishes with code of its own',
};

/// One word of the inventory.
final class _Word {
  _Word(this.word, this.kind, this.category, this.source);

  final String word;
  String kind, category;

  /// Where it is declared (`page_words.dart PageWords._bars`).
  String source;

  /// Kinds b, c, e: what it stands for (the alias's target, the rewrite's
  /// function, the base node types its expansion is made of).
  String standsFor = '';
  List<String> expandsTo = const [];

  /// How its line is matched in the counts (`type`, `key`, `flag`, `event`,
  /// `verb`, `fn`, `value`): the tallies it is the sum of.
  List<String> tallies = const [];

  int corpusUses = 0, corpusAnswers = 0, referenceUses = 0, r10Runs = 0, r10Uses = 0, r10Text = 0;
  bool r10Listed = false, taughtOpen = false, taughtFull = false, documented = false;
  bool handKept = false;

  /// The canonical expansion of its probes (kinds b, c, e and node types):
  /// two words with the same one are synonyms.
  String? probe;

  bool get written => corpusUses + referenceUses + r10Uses + r10Text > 0;

  Map<String, Object?> toJson() => {
        'word': word,
        'kind': kind,
        'category': category,
        'source': source,
        if (standsFor.isNotEmpty) 'standsFor': standsFor,
        if (expandsTo.isNotEmpty) 'expandsTo': expandsTo,
        'corpus': {'uses': corpusUses, 'answers': corpusAnswers},
        'round10': {'listed': r10Listed, 'runs': r10Runs, 'uses': r10Uses, 'quoted': r10Text},
        'reference': referenceUses,
        'taught': {'open': taughtOpen, 'full': taughtFull},
        'documented': documented,
        if (handKept) 'handKept': true,
      };
}

final class _Inventory {
  _Inventory(this.sdk);

  final String sdk;
  final words = <String, _Word>{};
  final synonyms = <List<String>>[];
  final problems = <String>[];
  int corpusFiles = 0, referenceBlocks = 0;

  String _src(String file) => File('$_notationDir/$file').readAsStringSync().replaceAll('\r\n', '\n');

  /// The quoted strings of the Dart literal assigned to [name] in [file]
  /// (a `const name = {…}` set or map; a map's keys when [keys]).
  Set<String> _literal(String file, String name, {bool keys = false}) {
    final text = _src(file);
    final m = RegExp('(?:const|final)\\s+(?:[A-Za-z<>, ?]+\\s+)?${RegExp.escape(name)}\\s*=\\s*(?:<[^>]*>)?\\{').firstMatch(text);
    if (m == null) throw StateError('$file: no declaration of $name (the inventory reads it: update the tool)');
    var depth = 1, i = m.end;
    while (depth > 0 && i < text.length) {
      final c = text[i];
      if (c == '{') depth++;
      if (c == '}') depth--;
      i++;
    }
    final body = text.substring(m.end, i - 1);
    final found = <String>{};
    final pattern = keys ? RegExp(r"'([^']+)'\s*:") : RegExp(r"'([^']+)'");
    for (final s in pattern.allMatches(body)) {
      found.add(s[1]!);
    }
    return found;
  }

  _Word add(String word, String kind, String category, String source, {List<String>? tallies, String standsFor = ''}) {
    final key = '$kind:$category:$word';
    final w = words.putIfAbsent(key, () => _Word(word, kind, category, source));
    w.tallies = tallies ?? w.tallies;
    if (standsFor.isNotEmpty && w.standsFor.isEmpty) w.standsFor = standsFor;
    return w;
  }

  static String _capital(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  void collect() {
    const catalog = standardCatalog;
    // --- a: node types -----------------------------------------------------
    for (final w in catalog.widgets) {
      add(_capital(w.type), 'a', 'node type', 'catalog ${Catalog.core.widget(w.type) != null ? 'core' : 'feature library'} (${w.type})', tallies: ['type:${_capital(w.type)}']);
    }
    // --- a: properties (every key notationKeyNames gives a type) -----------
    final keyTypes = <String, Set<String>>{};
    for (final w in catalog.widgets) {
      for (final k in notationKeyNames(w.type, catalog: catalog)) {
        keyTypes.putIfAbsent(k, () => {}).add(w.type);
      }
    }
    for (final e in keyTypes.entries) {
      add(e.key, 'a', 'property', 'keys.dart notationKeyNames (${e.value.length} types)', tallies: ['key:${e.key}', 'flag:${e.key}']);
    }
    for (final k in notationShortKeys.keys) {
      add(k, 'a', 'property', 'keys.dart notationShortKeys (${notationShortKeys[k]})', tallies: ['key:$k', 'flag:$k']);
    }
    // --- a: events ----------------------------------------------------------
    for (final t in TriggerType.values) {
      final name = notationEventName(t.name);
      add(name, 'a', 'event', 'triggers.dart TriggerType.${t.name}${notationEventNames.containsKey(t.name) ? ' (notation_events.dart notationEventNames)' : ''}', tallies: ['event:$name']);
    }
    // --- a: actions ---------------------------------------------------------
    for (final v in notationVerbs) {
      add(v, 'a', 'action verb', 'notation.dart notationVerbs', tallies: ['verb:$v']);
    }
    for (final a in catalog.actions) {
      add(a.type, 'a', 'action type', 'catalog action ${a.type}', tallies: ['verb:${a.type}']);
    }
    // --- a: formula functions ----------------------------------------------
    for (final f in notationFormulaFunctionNames) {
      add(f, 'a', 'formula function', 'formula_names.dart notationFormulaFunctionNames', tallies: ['fn:$f']);
    }
    // --- a: values ---------------------------------------------------------
    for (final a in notationAnimations.keys) {
      add(a, 'a', 'value: animate=', 'notation.dart notationAnimations (${notationAnimations[a]!['preset']})', tallies: ['anim:$a']);
    }
    for (final v in buttonVariants.keys) {
      add('Button.$v', 'a', 'value: variant', 'notation.dart buttonVariants (${buttonVariants[v]!.type})', tallies: ['variant:Button.$v']);
    }
    for (final v in badgeVariants.keys) {
      add('Badge.$v', 'a', 'value: variant', 'notation.dart badgeVariants', tallies: ['variant:Badge.$v']);
    }
    for (final v in defaultTextVariants.keys) {
      add('Text.$v', 'a', 'value: variant', 'notation.dart defaultTextVariants', tallies: ['variant:Text.$v']);
    }
    for (final m in [...mediaSizes.keys, 'mobile', 'portrait', 'landscape']) {
      add(m, 'a', 'value: media condition', 'media_words.dart mediaSizes${mediaSizes.containsKey(m) ? '' : ' (read in mediaCondition)'}', tallies: ['media:$m']);
    }
    for (final s in notationStateNames) {
      add(s, 'a', 'value: state', 'state_words.dart notationStateNames (WidgetState)', tallies: ['state:$s']);
    }
    for (final op in DrawOpSpecs.all) {
      add(op.op, 'a', 'draw op', 'custom_paint_fields.dart DrawOpSpecs', tallies: ['type:${op.op}']);
    }
    for (final r in const ['customPaint', 'foregroundPainter', 'animation', 'track', 'transition']) {
      add(r, 'a', 'record line', 'paint_words.dart _paintHead', tallies: ['type:$r']);
    }
    // --- a: grammar statements (hand-kept beside define.dart's set) ---------
    for (final s in {..._literal('define.dart', '_statements'), 'define', 'primitive', 'component'}) {
      add(s, 'a', 'grammar statement', 'define.dart _statements', tallies: ['type:$s']).handKept = !_literal('define.dart', '_statements').contains(s);
    }
    // --- b: page words ------------------------------------------------------
    final bars = _literal('page_words.dart', '_bars'), sides = _literal('page_words.dart', '_sides'), items = _literal('page_words.dart', '_items');
    final sections = _literal('page_words.dart', '_sections'), feet = _literal('page_words.dart', '_feet');
    final overlays = {'Dialog', 'Modal', 'Sheet', 'BottomSheet', 'Drawer', 'Menu', 'Dropdown', 'Popover', 'Popup', 'Lightbox'};
    String fn(String w) {
      if (bars.contains(w)) return 'PageWords._rewrite, the bar branch (page_words.dart): a website\'s Nav, an app\'s top bar, a row elsewhere';
      if (sides.contains(w)) return 'PageWords._rewrite, the sidebar branch (page_words.dart); the phone drawer: _Parser (notation.dart) from PageWords.sidebar';
      if (items.contains(w)) return 'PageWords._rewrite, the item branch (page_words.dart)';
      if (sections.contains(w)) return 'PageWords._rewrite, the group label branch (page_words.dart)';
      if (overlays.contains(w)) return w == 'Lightbox' ? 'PageWords.overlay and _lightbox (page_words.dart); _Parser._openBlock (notation.dart)' : 'PageWords.overlay (page_words.dart); _Parser._openBlock (notation.dart)';
      return switch (w) {
        'Page' => 'PageWords._rewrite, the Page branch (page_words.dart)',
        'App' || 'AppShell' || 'Window' => 'PageWords._rewrite, the App branches (page_words.dart); the drawer and the reflow: _Parser._feet, PageReflow (reflow.dart)',
        'Section' || 'Hero' => 'PageWords._rewrite, the Section branch (page_words.dart)',
        'Footer' => 'PageWords._rewrite: the Section branch on a page, the foot branch in an App, the sidebar foot (page_words.dart); _Parser._feet (notation.dart)',
        'Main' || 'Content' => 'PageWords._rewrite, the Main branch (page_words.dart)',
        'Pane' || 'Panel' => 'PageWords._rewrite, the Pane branch (page_words.dart)',
        'Brand' || 'Logo' => 'PageWords._rewrite, the Brand branch (page_words.dart)',
        'IconTile' => 'PageWords._rewrite, the IconTile branch (page_words.dart)',
        'Link' => 'PageWords._rewrite, the Link branch (page_words.dart)',
        'Heading' || 'Title' => 'PageWords._rewrite, the Heading branch (page_words.dart)',
        'Dots' => '_Parser.line and _dotsOf (notation.dart)',
        'SwipeAction' => '_Parser._lineAt (notation.dart): an action a ListRow reveals',
        'Wanted' => '_Parser._lineAt (notation.dart) and WantedBlock',
        'SidebarFooter' || 'NavFooter' => 'PageWords._rewrite, the sidebar foot branch (page_words.dart)',
        _ => 'PageWords (page_words.dart)',
      };
    }

    for (final w in {...PageWords.words, ...sections, ...feet}) {
      final cat = bars.contains(w)
          ? 'page word: bar'
          : sides.contains(w)
              ? 'page word: sidebar'
              : items.contains(w)
                  ? 'page word: item'
                  : sections.contains(w)
                      ? 'page word: group label'
                      : overlays.contains(w)
                          ? 'page word: overlay'
                          : 'page word';
      add(w, 'b', cat, 'page_words.dart PageWords.words${bars.contains(w) ? ' (_bars)' : sides.contains(w) ? ' (_sides)' : items.contains(w) ? ' (_items)' : sections.contains(w) ? ' (_sections)' : feet.contains(w) ? ' (_feet)' : ''}',
          tallies: ['type:$w'], standsFor: fn(w))
          .handKept = true;
    }
    for (final h in const ['H1', 'H2', 'H3', 'H4']) {
      add(h, 'b', 'page word', 'page_words.dart (RegExp ^H[1-4]\$)', tallies: ['type:$h'], standsFor: 'PageWords._rewrite, the Heading branch (page_words.dart)');
    }
    add('Table', 'b', 'page word: table', 'page_words.dart _rewrite (word == Table) and table_words.dart', tallies: ['type:Table'],
        standsFor: 'PageWords._tableLines, _cellLine, _tableClose (table_words.dart)');
    add('Canvas', 'b', 'page word: overlay', 'page_words.dart PageWords.overlay (Canvas#id)', tallies: ['type:Canvas'], standsFor: 'PageWords.overlay (page_words.dart): another canvas');
    for (final e in NotationVocabulary.core.types.entries) {
      if (e.value.line == null) continue;
      add(e.key, 'b', 'line rewrite', 'vocabulary.dart NotationVocabulary.core.types (line: ${e.value.line})', tallies: ['type:${e.key}'],
          standsFor: 'lineRewrites[\'${e.value.line}\'] (vocabulary.dart _${e.value.line}Line${e.value.line == 'confirmDialog' ? 's' : ''})');
    }
    if (!lineRewrites.keys.toSet().containsAll({'shortcut', 'computed', 'confirmDialog'})) problems.add('lineRewrites changed: ${lineRewrites.keys}');
    // Contextual rewrites of base words (hand-kept: no word set of their own).
    for (final c in const [
      ('Text (with a look)', 'a Text with fill, radius or a border is a Box around the Text', 'PageWords._rewrite and _textBox (page_words.dart)'),
      ('Badge (with w=)', 'a Badge with a width is a Row of that width around the Badge; its bound color is dropped', 'PageWords._rewrite (page_words.dart)'),
      ('Row/Column (turning at a width)', 'a Row or Column with phone.direction= (any width) is a Flex', 'PageWords._rewrite (page_words.dart, _turns)'),
      ('Input (in a bar)', 'an Input, Search or SearchField in a Nav, or labelled Search/Filter/Find: its label is its hint', 'PageWords._rewrite (page_words.dart)'),
      ('a gallery (photos=)', 'a design system\'s gallery with photos opens them in the page\'s lightbox', 'PageWords._gallery (page_words.dart)'),
      ('sticky=true', 'read as the flag sticky', 'PageWords._plain (page_words.dart)'),
      ('Avatar src=', 'read as image=', 'PageWords._plain (page_words.dart)'),
      ('Row sticky bottom (in App)', 'the foot of an app\'s window, as Footer', 'PageWords._rewrite, the foot branch (page_words.dart)'),
    ]) {
      add(c.$1, 'b', 'contextual rewrite', 'hand-kept', standsFor: '${c.$2}: ${c.$3}').handKept = true;
    }
    // --- c: aliases -----------------------------------------------------------
    const v = NotationVocabulary.core;
    for (final e in v.types.entries) {
      if (e.value.line != null) continue;
      add(e.key, 'c', 'alias: type', 'vocabulary.dart NotationVocabulary.core.types', tallies: ['type:${e.key}'],
          standsFor: '${e.value.to}${e.value.variant == null ? '' : '.${e.value.variant}'}${e.value.add == null ? '' : ' ${e.value.add}'}${e.value.requires.isEmpty ? '' : ' (with ${e.value.requires.join(', ')})'}${e.value.parameters.isEmpty ? '' : ' ${e.value.parameters}'}');
    }
    void table(String what, Map<String, Map<String, String>> m, String tally) {
      for (final t in m.entries) {
        for (final a in t.value.entries) {
          add(a.key, 'c', 'alias: $what', 'vocabulary.dart NotationVocabulary.core.$what[${t.key}]', tallies: ['$tally:${a.key}', if (tally == 'key') 'flag:${a.key}'], standsFor: '${a.value} (on ${t.key})');
        }
      }
    }

    table('parameters', v.parameters, 'key');
    table('flags', v.flags, 'flag');
    table('events', v.events, 'event');
    for (final e in notationVerbAliases.entries) {
      add(e.key, 'c', 'alias: verb', 'notation.dart notationVerbAliases', tallies: ['verb:${e.key}'], standsFor: e.value);
    }
    for (final e in _literal('notation_events.dart', '_eventAliases', keys: true)) {
      add(e, 'c', 'alias: event', 'notation_events.dart _eventAliases', tallies: ['event:$e'], standsFor: 'the trigger it names (${e == 'onContextMenu' ? 'secondaryClick' : 'click'})');
    }
    for (final e in {'onClick', 'onPressed', 'onChanged', 'onSubmitted', 'onSecondaryClick'}) {
      add(e, 'c', 'alias: event', 'notation_events.dart _blockEventFamilies', tallies: ['event:$e'], standsFor: 'the first of its family a block has');
    }
    for (final kin in parameterSynonyms) {
      for (final k in kin) {
        add(k, 'c', 'alias: parameter', 'vocabulary.dart parameterSynonyms', tallies: ['key:$k'], standsFor: 'the one of {${kin.join(', ')}} a word takes');
      }
    }
    for (final t in notationTypeKeys.entries) {
      for (final k in t.value.entries) {
        add(k.key, 'c', 'alias: parameter', 'keys.dart notationTypeKeys[${t.key}]', tallies: ['key:${k.key}'], standsFor: '${k.value.join(', ')} (on ${t.key})');
      }
    }
    for (final k in notationTextStyleKeys.entries) {
      add(k.key, 'c', 'alias: parameter', 'keys.dart notationTextStyleKeys', tallies: ['key:${k.key}', 'flag:${k.key}'], standsFor: 'props.style.${k.value} (on text)');
    }
    for (final k in notationFieldStyleKeys.entries) {
      add(k.key, 'c', 'alias: parameter', 'keys.dart notationFieldStyleKeys', tallies: ['key:${k.key}'], standsFor: 'props.style.${k.value} (on textField)');
    }
    for (final k in _literal('keys.dart', '_words')) {
      add(k, 'c', 'parser word', 'keys.dart _words', tallies: ['key:$k', 'flag:$k'], standsFor: 'a key the parser reads itself on any type');
    }
    for (final e in _literal('notation.dart', '_borderSides', keys: true)) {
      add(e, 'c', 'alias: parameter', 'notation.dart _borderSides', tallies: ['key:$e'], standsFor: 'a hairline on one side');
    }
    // --- c: universal words -----------------------------------------------------
    for (final e in notationUniversal.entries) {
      final k = e.value.kind;
      add(e.key, e.value.grammar ? 'a' : 'c', e.value.grammar ? 'grammar word (universal table)' : 'universal word', 'universal.dart notationUniversal',
          tallies: [if (k == UniversalKind.event) 'event:${e.key}' else ...['key:${e.key}', 'flag:${e.key}']],
          standsFor: e.value.of == null ? e.value.meaning : 'another name of ${e.value.of}');
    }
    // --- e: short names ---------------------------------------------------------------
    for (final e in notationTypes.entries) {
      add(e.key, 'e', 'short name', 'notation.dart notationTypes (${e.value.type})', tallies: ['type:${e.key}'], standsFor: e.value.type);
    }
    // --- d: design systems --------------------------------------------------------------
    final ds = Directory('$sdk/design_systems');
    for (final d in ds.listSync().whereType<Directory>().toList()..sort((a, b) => a.path.compareTo(b.path))) {
      final name = d.uri.pathSegments.where((s) => s.isNotEmpty).last;
      final comps = Directory('${d.path}/components');
      if (comps.existsSync()) {
        for (final f in comps.listSync().whereType<File>().where((f) => f.path.endsWith('.json'))) {
          final type = f.uri.pathSegments.last.replaceAll('.json', '');
          add(type, 'd', 'component', 'design_systems/$name/components', tallies: ['type:$type']).source =
              _merge(words['d:component:$type']?.source, name);
        }
      }
      final vocab = Directory('${d.path}/vocabulary');
      if (vocab.existsSync()) {
        final texts = {for (final f in vocab.listSync().whereType<File>().where((f) => f.path.endsWith('.txt'))) f.uri.pathSegments.last: f.readAsStringSync()};
        final read = readDefinitions(texts);
        for (final w in read.words.entries) {
          add(w.key, 'd', w.value.any((x) => x.primitive) ? 'defined word (primitive)' : 'defined word', 'design_systems/$name/vocabulary', tallies: ['type:${w.key}'],
              standsFor: [for (final x in w.value) x.label].join(', '));
        }
      }
      final json = File('${d.path}/vocabulary.json');
      if (json.existsSync()) {
        final table = NotationVocabulary.fromJson((jsonDecode(json.readAsStringSync()) as Map).cast<String, Object?>());
        for (final e in table.types.entries) {
          add(e.key, 'd', 'alias of a design system', 'design_systems/$name/vocabulary.json', tallies: ['type:${e.key}'], standsFor: '${e.value.to ?? e.value.line}');
        }
      }
    }
  }

  static String _merge(String? before, String ds) {
    if (before == null || !before.startsWith('design_systems/')) return 'design_systems/$ds/components';
    final names = RegExp(r'design_systems/\{?([^/}]+)\}?').firstMatch(before)![1]!.split(',').toSet()..add(ds);
    return 'design_systems/{${(names.toList()..sort()).join(',')}}/components';
  }

  // --- counting ----------------------------------------------------------------------

  /// What a text writes, tallied: `type:Word`, `variant:Word.v`, `key:k`,
  /// `flag:f`, `event:onX`, `verb:v`, `fn:f`, `anim:a`, `media:m`, `state:s`.
  static Map<String, int> tally(String text) {
    final t = <String, int>{};
    void inc(String k) => t[k] = (t[k] ?? 0) + 1;
    for (final raw in text.split(RegExp(r'\r?\n'))) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('//') || line.startsWith('###') || line.startsWith('```')) continue;
      final head = RegExp(r'^([A-Za-z][A-Za-z0-9]*)').stringMatch(line);
      if (head == null) continue;
      final parts = LineParts.of(line);
      if (parts == null) {
        inc('type:$head');
        continue;
      }
      inc('type:${parts.word}');
      for (final v in parts.variant.split('.').where((s) => s.isNotEmpty)) {
        inc('variant:${parts.word}.$v');
      }
      for (final part in parts.parts) {
        // A dotted key (`phone.pad=16`, `hovered.fill=…`) is a word to
        // LineParts: read as the pair it is.
        final dotted = part.kind == 'word' && RegExp(r'^[A-Za-z][A-Za-z0-9_.-]*\.[A-Za-z][A-Za-z0-9_-]*=').hasMatch(part.raw);
        final p = dotted ? LinePart.pair(part.raw.substring(0, part.raw.indexOf('=')), part.raw.substring(part.raw.indexOf('=') + 1)) : part;
        if (p.kind == 'pair') {
          final segs = p.key!.split('.');
          final key = segs.last;
          for (final s in segs.take(segs.length - 1)) {
            if (mediaSizes.containsKey(s) || const {'mobile', 'portrait', 'landscape'}.contains(s) || RegExp(r'^(min|max)\d').hasMatch(s)) inc('media:$s');
            if (notationStateNames.contains(s)) inc('state:$s');
          }
          if (RegExp(r'^on[A-Z]').hasMatch(key)) {
            inc('event:$key');
          } else {
            inc('key:$key');
          }
          if (key == 'animate') inc('anim:${p.value!.replaceAll('"', '')}');
          if ((key == 'hide' || key == 'show') && mediaSizes.containsKey(p.value)) inc('media:${p.value}');
        } else if (p.kind == 'word' && !p.raw.startsWith('@')) {
          // `phone.hidden`, `hovered.bold`: a condition, then the flag.
          final segs = p.raw.split('.');
          for (final s in segs.take(segs.length - 1)) {
            if (mediaSizes.containsKey(s) || const {'mobile', 'portrait', 'landscape'}.contains(s) || RegExp(r'^(min|max)\d').hasMatch(s)) inc('media:$s');
            if (notationStateNames.contains(s)) inc('state:$s');
          }
          inc('flag:${segs.last}');
        }
      }
      // Inside braces: formula calls and actions.
      for (final m in RegExp(r'(?<![A-Za-z0-9_.])([a-z][A-Za-z0-9]*)\(').allMatches(line)) {
        inc('fn:${m[1]}');
      }
      for (final m in RegExp(r'(?:=\{|;|\bthen\s*\{?|\?|:)\s*([a-z][A-Za-z]*)(?=[\s;}]|$)').allMatches(line)) {
        inc('verb:${m[1]}');
      }
    }
    return t;
  }

  /// The `### Name` screens of the first corpus's answers, and the notation
  /// blocks of the reference.
  void count(String? round10) {
    final corpus = <String, Map<String, int>>{};
    for (final top in ['corpus', 'corpus-define']) {
      final dir = Directory('$sdk/tool/vocabulary/$top');
      if (!dir.existsSync()) continue;
      for (final f in dir.listSync(recursive: true).whereType<File>()) {
        final p = f.path.replaceAll(r'\', '/');
        if (!p.endsWith('.txt') || !p.contains('/answers/')) continue;
        corpus[p] = tally(f.readAsStringSync());
      }
    }
    corpusFiles = corpus.length;
    final reference = <String, int>{};
    final referenceText = StringBuffer();
    for (final f in Directory('docs/reference/notation').listSync().whereType<File>().where((f) => f.path.endsWith('.md'))) {
      final text = f.readAsStringSync().replaceAll('\r\n', '\n');
      referenceText.writeln(text);
      for (final m in RegExp(r'```notation[^\n]*\n([\s\S]*?)```').allMatches(text)) {
        referenceBlocks++;
        for (final e in tally(m[1]!).entries) {
          reference[e.key] = (reference[e.key] ?? 0) + e.value;
        }
      }
    }
    final ref = referenceText.toString();
    final open = notationPrompt(options: const NotationOptions(width: 1440), open: true);
    final full = notationPrompt(options: const NotationOptions(width: 1440));
    // The round 10 harvest: its table of every word beyond the core.
    final r10 = <String, ({int runs, int uses})>{};
    var r10Quoted = <String, int>{};
    if (round10 != null) {
      final text = File(round10).readAsStringSync().replaceAll('\r\n', '\n');
      final at = text.indexOf('## Every word beyond the core');
      for (final line in text.substring(at < 0 ? text.length : at).split('\n')) {
        final cells = line.split('|').map((c) => c.trim()).toList();
        if (cells.length < 7 || cells[1] == 'kind' || cells[1].startsWith('-')) continue;
        final kind = cells[1], word = cells[2].replaceAll('`', '');
        final runs = int.tryParse(cells[3]) ?? 0, uses = int.tryParse(cells[5]) ?? 0;
        final short = word.contains('.') && kind != 'variant' ? word.substring(word.lastIndexOf('.') + 1) : word;
        final tag = switch (kind) {
          'type' => 'type:$short',
          'parameter' || 'key' => 'key:$short',
          'flag' => 'flag:$short',
          'event' => 'event:$short',
          'verb' => 'verb:$short',
          'function' => 'fn:$short',
          'variant' => 'variant:$word',
          _ => '$kind:$short',
        };
        final before = r10[tag];
        r10[tag] = (runs: before == null || before.runs < runs ? runs : before.runs, uses: (before?.uses ?? 0) + uses);
      }
      // The notation the harvest quotes (writers' definitions and shapes):
      // indented lines, and the lines of its code spans.
      r10Quoted = tally([
        for (final l in text.split('\n'))
          if (RegExp(r'^\s{2,}[A-Za-z]').hasMatch(l) && !l.trimLeft().startsWith('- ')) l,
      ].join('\n'));
    }
    // A word is named where it stands as a token; a formula function where
    // it is called (`round(`), an animate= value after `animate=` or in a
    // list of them, so that `if`, `day` or `zoom` in the prose is not one.
    bool named(String text, String word, String category) {
      final w = RegExp.escape(word.contains(' ') ? word.split(' ').first : word);
      return switch (category) {
        'formula function' => RegExp('(?<![A-Za-z0-9_.])$w\\(').hasMatch(text),
        'value: animate=' => RegExp('animate[=:]$w(?![A-Za-z0-9_-])|`$w`').hasMatch(text),
        _ => RegExp('(?<![A-Za-z0-9_])$w(?![A-Za-z0-9_])').hasMatch(text),
      };
    }

    for (final w in words.values) {
      for (final t in w.tallies) {
        for (final c in corpus.values) {
          final n = c[t] ?? 0;
          w.corpusUses += n;
        }
        w.referenceUses += reference[t] ?? 0;
        w.r10Text += r10Quoted[t] ?? 0;
        if (r10[t] case final r?) {
          w.r10Listed = true;
          w.r10Runs = w.r10Runs < r.runs ? r.runs : w.r10Runs;
          w.r10Uses += r.uses;
        }
      }
      w.corpusAnswers = corpus.values.where((c) => w.tallies.any((t) => (c[t] ?? 0) > 0)).length;
      if (w.category != 'contextual rewrite') {
        w.taughtOpen = named(open, w.word, w.category);
        w.taughtFull = named(full, w.word, w.category);
        w.documented = named(ref, w.word, w.category);
      }
    }
  }

  // --- probes: what a type word expands to, and synonyms -------------------------------

  /// Each type word of kinds b, c and e, and each node type, written alone,
  /// in an app's sidebar and in a page's section, expanded at 1440: the base
  /// node types its expansion uses, and its canonical expansion (synonyms
  /// have the same one).
  void probe() {
    final candidates = words.values.where((w) =>
        (w.kind == 'b' && w.category != 'contextual rewrite' && w.category != 'line rewrite') ||
        (w.kind == 'c' && w.category == 'alias: type') ||
        w.kind == 'e' ||
        (w.kind == 'a' && w.category == 'node type'));
    // A word whose line needs more than a label to be itself is probed
    // with what it needs.
    String line(String w) => switch (w) {
          'Table' => 'Table#probe p in people columns=["Name","Email"]',
          'Dots' => 'Dots#probe @page count=3',
          'RangeSlider' => 'RangeSlider#probe @lo @hi',
          'Canvas' => 'Canvas#probe "Label" path="probe"',
          _ => '$w#probe "Label"',
        };
    List<String> pages(String w) => [
          '${line(w)}\n',
          'App\n  Sidebar\n    ${line(w)}\n  Main\n    Text "x"\n',
          'Page\n  Section\n    ${line(w)}\n',
        ];
    const contextTypes = {'canvas'};
    for (final w in candidates) {
      final docs = [for (final p in pages(w.word)) expandPage(p, width: 1440)];
      w.probe = docs.map((d) => jsonEncode(canonical(d))).join('\n');
      if (w.kind != 'a') {
        final types = <String>{};
        final nodes = (docs.first['nodes'] as Map).cast<String, Object?>();
        for (final n in nodes.values) {
          final t = (n as Map)['type'] as String;
          if (!contextTypes.contains(t)) types.add(t);
        }
        w.expandsTo = types.toList()..sort();
      }
    }
    final byProbe = <String, List<_Word>>{};
    for (final w in candidates) {
      byProbe.putIfAbsent(w.probe!, () => []).add(w);
    }
    for (final g in byProbe.values) {
      if (g.length < 2) continue;
      synonyms.add([for (final w in g) '${w.word} (${w.kind})']);
    }
    synonyms.sort((a, b) => a.first.compareTo(b.first));
  }

  // --- output ----------------------------------------------------------------------------

  Map<String, Object?> toJson() => {
        'generatedBy': 'tool/vocabulary_inventory.dart',
        'kinds': _kinds,
        'handKept': _handKept,
        'counts': {for (final k in _kinds.keys) k: words.values.where((w) => w.kind == k).length},
        'corpusAnswers': corpusFiles,
        'referenceBlocks': referenceBlocks,
        'synonyms': synonyms,
        'problems': problems,
        'words': [for (final w in _sorted) w.toJson()],
      };

  List<_Word> get _sorted => words.values.toList()
    ..sort((a, b) {
      final k = a.kind.compareTo(b.kind);
      if (k != 0) return k;
      final c = a.category.compareTo(b.category);
      return c != 0 ? c : a.word.compareTo(b.word);
    });

  String markdown(bool round10) {
    final b = StringBuffer()
      ..writeln('# The notation\'s words, by kind (generated)')
      ..writeln()
      ..writeln('Written by `tool/vocabulary_inventory.dart` (track B, step B1; design note 23). Do not edit: run it again.')
      ..writeln()
      ..writeln('Read from the code\'s declarations; hand-kept only where the code has nothing to read:')
      ..writeln();
    for (final e in _handKept.entries) {
      b.writeln('- **${e.key}**: ${e.value}');
    }
    b
      ..writeln()
      ..writeln('Counted over the first corpus ($corpusFiles answers: the SDK\'s `tool/vocabulary/corpus*/*/answers`), '
          '${round10 ? 'the round 10 harvest (`runs` and `uses` from its table of the words beyond the core: a word of the core is not listed there; `quoted`: lines in the notation the harvest quotes), ' : ''}'
          'and the notation reference\'s $referenceBlocks ```notation blocks. A use is a line that writes the word '
          '(a line\'s first word for a type, `key=` or a bare word for a property, `onX=` for an event). Taught: named in '
          'the open prompt (`open`) or the full prompt (`full`), both 1440 wide; documented: named in '
          '`docs/reference/notation/*.md`.')
      ..writeln()
      ..writeln('## Counts per kind')
      ..writeln()
      ..writeln('| kind | | words | written somewhere | never written | taught (open or full) |')
      ..writeln('|---|---|---|---|---|---|');
    for (final k in _kinds.entries) {
      final ws = words.values.where((w) => w.kind == k.key).toList();
      b.writeln('| ${k.key} | ${k.value} | ${ws.length} | ${ws.where((w) => w.written).length} | ${ws.where((w) => !w.written).length} | ${ws.where((w) => w.taughtOpen || w.taughtFull).length} |');
    }
    final distinct = {for (final w in words.values) w.word};
    final twice = [
      for (final d in distinct)
        if (words.values.where((w) => w.word == d).map((w) => w.kind).toSet().length > 1) d,
    ]..sort();
    b
      ..writeln()
      ..writeln('${words.length} rows, ${distinct.length} distinct words: a word declared in two places is a row in each '
          '(${twice.length} words are in more than one kind: ${twice.take(60).map((w) => '`$w`').join(', ')}${twice.length > 60 ? ' …' : ''}). '
          'Kind d counts a component once however many design systems have it.')
      ..writeln()
      ..writeln('By category:')
      ..writeln()
      ..writeln('| kind | category | words | never written |')
      ..writeln('|---|---|---|---|');
    final cats = <String, List<_Word>>{};
    for (final w in _sorted) {
      cats.putIfAbsent('${w.kind}|${w.category}', () => []).add(w);
    }
    for (final e in cats.entries) {
      b.writeln('| ${e.key.split('|').first} | ${e.key.split('|').last} | ${e.value.length} | ${e.value.where((w) => !w.written).length} |');
    }
    if (problems.isNotEmpty) {
      b
        ..writeln()
        ..writeln('Problems: ${problems.join('; ')}');
    }
    b
      ..writeln()
      ..writeln('## Synonyms: different words with the same expansion')
      ..writeln()
      ..writeln('Each type word of kinds b, c and e, and each node type, written `Word#probe "Label"` alone, in an App\'s Sidebar and '
          'in a Page\'s Section, expanded at 1440; words whose three expansions are the same (ids aside) are one group.')
      ..writeln();
    for (final g in synonyms) {
      b.writeln('- ${g.join(', ')}');
    }
    String row(_Word w) => '| `${w.word}` | ${w.category} | ${w.source} | ${w.standsFor.replaceAll('|', '/')} | ${w.expandsTo.join(' ')} | '
        '${w.corpusUses} (${w.corpusAnswers}) | ${round10 ? '${w.r10Listed ? '${w.r10Runs} runs, ${w.r10Uses}' : ''}${w.r10Text > 0 ? ' q${w.r10Text}' : ''} | ' : ''}${w.referenceUses} | '
        '${w.taughtOpen ? 'open' : ''}${w.taughtOpen && w.taughtFull ? ' ' : ''}${w.taughtFull ? 'full' : ''} | ${w.documented ? 'yes' : ''} |';
    for (final k in _kinds.entries) {
      b
        ..writeln()
        ..writeln('## Kind ${k.key}: ${k.value}')
        ..writeln()
        ..writeln('| word | category | declared | stands for | expands to | corpus uses (answers) | ${round10 ? 'round 10 | ' : ''}reference uses | taught | documented |')
        ..writeln('|---|---|---|---|---|---|${round10 ? '---|' : ''}---|---|---|');
      for (final w in _sorted.where((w) => w.kind == k.key)) {
        b.writeln(row(w));
      }
    }
    b
      ..writeln()
      ..writeln('## Declared and never written')
      ..writeln()
      ..writeln('Words of kinds a, b, c and e no answer of the first corpus, ${round10 ? 'no line the round 10 harvest lists or quotes, ' : ''}and no example of the reference writes: '
          'candidates to drop from what is taught (a property here may still be printed by the printer).')
      ..writeln();
    for (final k in const ['a', 'b', 'c', 'e']) {
      final never = _sorted.where((w) => w.kind == k && !w.written && w.category != 'contextual rewrite').toList();
      final byCat = <String, List<String>>{};
      for (final w in never) {
        byCat.putIfAbsent(w.category, () => []).add('`${w.word}`${w.taughtOpen || w.taughtFull ? ' (taught)' : ''}');
      }
      for (final e in byCat.entries) {
        b.writeln('- **$k, ${e.key}** (${e.value.length}): ${e.value.join(', ')}');
      }
    }
    return b.toString();
  }
}
