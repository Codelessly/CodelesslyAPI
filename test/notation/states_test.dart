// A node's states in the notation (docs/design/22 section 4.7, "States and
// behaviors: the forms"): `hovered.fill=…` on a line, `btn.selected.color=…`
// on the line of a node inside it, read into the owner's `states` and
// printed back in the same words; a node's name and its behaviors by the
// keys' names.
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:test/test.dart';

Object? _sorted(Object? v) => switch (v) {
      final Map m => {for (final k in m.keys.map((k) => '$k').toList()..sort()) k: _sorted(m[k])},
      final List l => [for (final e in l) _sorted(e)],
      final double d when d == d.roundToDouble() && d.abs() < 1e15 => d.toInt(),
      _ => v,
    };

String _json(Object? v) => jsonEncode(_sorted(v));

Map<String, Object?> _nodeOf(Map<String, Object?> doc, String id) => ((doc['nodes'] as Map)[id] as Map).cast<String, Object?>();

/// Node [id]'s line in [text], without its indent.
String _lineOf(String text, String id) => text.split('\n').map((l) => l.trim()).firstWhere((l) => RegExp('^[A-Za-z][A-Za-z0-9.]*#$id(\\s|\$)').hasMatch(l));

final _stateWord = RegExp(r'^([A-Za-z_][A-Za-z0-9_-]*\.)?(hovered|focused|pressed|selected|disabled|dragged)\.');

/// The words of [line] that are state words, in order.
List<String> _stateWords(String line) => line.split(' ').where(_stateWord.hasMatch).toList();

NotationResult _read(String text) => parseNotation(text, catalog: standardCatalog);

/// [text] (lines under a column) expands with no issue; node [owner]'s
/// states are [states]; the document prints every line's state words back
/// as written, with no `states` in a tail, and the print reads back as the
/// document.
void _word(String text, String owner, Map<String, Object?> states) {
  final r = _read('Column#root\n${text.split('\n').map((l) => '  $l').join('\n')}');
  expect(r.issues, isEmpty, reason: text);
  expect(_json(_nodeOf(r.document, owner)['states']), _json(states), reason: text);
  final printed = printNotation(r.document, catalog: standardCatalog);
  for (final line in text.split('\n')) {
    final id = RegExp(r'#([A-Za-z_][A-Za-z0-9_-]*)').firstMatch(line)![1]!;
    final back = _lineOf(printed, id);
    expect(_stateWords(back), _stateWords(line.trim()), reason: printed);
    expect(back, isNot(contains('"states"')), reason: printed);
  }
  final back = parseNotation(printed, catalog: standardCatalog, options: notationOptionsFor(r.document));
  expect(_json(back.document), _json(r.document), reason: printed);
}

/// A page whose root column holds [top] of [nodes] (their JSON as a
/// document has them): the print reads back as the document, and the lines
/// of [said] carry no `states` (nor [keys]) in a tail. Returns the print.
String _corpus(Map<String, Map<String, Object?>> nodes, List<String> top, {List<String>? said, List<String> keys = const ['states']}) {
  final doc = <String, Object?>{
    'schema': 3,
    'roots': ['page'],
    'nodes': {
      'page': {'type': 'canvas', 'slots': {'body': 'root'}, 'layout': {'width': 390, 'height': 800}},
      'root': {
        'type': 'column',
        'children': top,
        'layout': {'width': {'fill': 0}, 'height': {'hug': 0}},
        'props': {'crossAxisAlignment': 'start'},
      },
      ...nodes,
    },
  };
  final text = printNotation(doc, catalog: standardCatalog);
  final back = parseNotation(text, catalog: standardCatalog, options: notationOptionsFor(doc));
  expect(_json(back.document), _json(doc), reason: text);
  for (final id in said ?? nodes.keys) {
    for (final k in keys) {
      expect(_lineOf(text, id), isNot(contains('"$k"')), reason: 'the $k of $id are said in words:\n$text');
    }
  }
  return text;
}

void main() {
  group('a node\'s own states', () {
    test('every state of WidgetState is a condition', () {
      for (final s in WidgetState.values) {
        _word('Row#r fill=paper ${s.name}.fill=accentDeep', 'r', {
          s.name: {
            'r': {
              'decoration': {
                'fills': [
                  {'color': 'accentDeep'},
                ],
              },
            },
          },
        });
      }
    });

    test('a patch is what the words change, any key the line reads', () {
      _word('Row#btn gap=8 fill=accent radius=14 hovered.fill=accentDeep pressed.opacity=0.82 focused.strokes=[{"color":"focusBorder"}]', 'btn', {
        'hovered': {
          'btn': {
            'decoration': {
              'fills': [
                {'color': 'accentDeep'},
              ],
            },
          },
        },
        'pressed': {
          'btn': {'opacity': 0.82},
        },
        'focused': {
          'btn': {
            'decoration': {
              'strokes': [
                {'color': 'focusBorder'},
              ],
            },
          },
        },
      });
      _word('Text#t "Save" color=secondaryText hovered.color=primaryText hovered.weight=600', 't', {
        'hovered': {
          't': {
            'props': {
              'style': {'color': 'primaryText', 'fontWeight': 600},
            },
          },
        },
      });
    });

    test('the words of one state are one patch wherever they are on the line', () {
      final r = _read('Row#r hovered.fill=paper pressed.opacity=0.8 hovered.radius=4');
      expect(r.issues, isEmpty);
      expect(_json(readMap(_nodeOf(r.document, 'r')['states'])?['hovered']), _json({
        'r': {
          'decoration': {
            'fills': [
              {'color': 'paper'},
            ],
            'radius': 4,
          },
        },
      }));
    });

    test('a flag and a binding in a state', () {
      final r = _read('Text#t "x" hovered.hidden hovered.color={dark ? "white" : "ink"}');
      expect(r.issues, isEmpty);
      expect(_json(_nodeOf(r.document, 't')['states']), _json({
        'hovered': {
          't': {
            'visible': false,
            'bind': {'props.style.color': r'${= dark ? "white" : "ink"}'},
          },
        },
      }));
      final printed = printNotation(r.document, catalog: standardCatalog);
      expect(_lineOf(printed, 't'), contains('hovered.hidden'));
      final back = parseNotation(printed, catalog: standardCatalog, options: notationOptionsFor(r.document));
      expect(_json(back.document), _json(r.document), reason: printed);
    });
  });

  group('a state of a line around it', () {
    test('is written on the restyled node\'s line after the owner\'s id', () {
      _word('Row#btn gap=8 hovered.fill=accentDeep\n  Icon#glyph "star" btn.selected.color=primaryText\n  Text#label "Save" btn.selected.color=primaryText btn.selected.weight=600', 'btn', {
        'hovered': {
          'btn': {
            'decoration': {
              'fills': [
                {'color': 'accentDeep'},
              ],
            },
          },
        },
        'selected': {
          'glyph': {
            'props': {'color': 'primaryText'},
          },
          'label': {
            'props': {
              'style': {'color': 'primaryText', 'fontWeight': 600},
            },
          },
        },
      });
    });

    test('the owner is any line around it, and must be one', () {
      _word('Column#card gap=4\n  Row#inner gap=2\n    Text#title "T" card.hovered.color=primary', 'card', {
        'hovered': {
          'title': {
            'props': {
              'style': {'color': 'primary'},
            },
          },
        },
      });
      final r = _read('Column#a\n  Text#t "x" b.hovered.color=primary');
      expect(r.issues.map((i) => i.message), [contains('there is no line b around this one')]);
    });

    test('an id joined by - names its line', () {
      _word('Row#m-nav gap=4\n  Text#m-nav-t "Docs" m-nav.hovered.color=#FF0F172A', 'm-nav', {
        'hovered': {
          'm-nav-t': {
            'props': {
              'style': {'color': '#FF0F172A'},
            },
          },
        },
      });
    });
  });

  group('the defaults the line gives', () {
    test('selected={…} on a box is the theme\'s fill until its selected look is written', () {
      final plain = _read('Row#r selected={on}');
      expect(readMap(_nodeOf(plain.document, 'r')['states'])?.keys, ['selected']);
      final printed = printNotation(plain.document, catalog: standardCatalog);
      expect(_lineOf(printed, 'r'), contains('selected={on}'));
      expect(_stateWords(_lineOf(printed, 'r')), isEmpty);

      _word('Row#r selected={on} selected.fill=primaryTint', 'r', {
        'selected': {
          'r': {
            'decoration': {
              'fills': [
                {'color': 'primaryTint'},
              ],
            },
          },
        },
      });
      // Written under it: the box takes no fill of its own.
      _word('Row#r selected={on}\n  Text#l "x" r.selected.weight=600', 'r', {
        'selected': {
          'l': {
            'props': {
              'style': {'fontWeight': 600},
            },
          },
        },
      });
    });

    test('enabled={…} on a box is half strength until its disabled look is written', () {
      final r = _read('Row#r enabled={ok} disabled.opacity=0.4');
      expect(r.issues, isEmpty);
      expect(_json(_nodeOf(r.document, 'r')['states']), _json({
        'disabled': {
          'r': {'opacity': 0.4},
        },
      }));
    });
  });

  group('said', () {
    test('a media rule holds no state, a state no media rule', () {
      expect(_read('Row#r phone.hovered.fill=paper').issues.map((i) => i.message), [contains('A media rule holds the line\'s own keys, not a state')]);
      expect(_read('Row#r hovered.phone.pad=4').issues.map((i) => i.message), [contains('not a media rule or another state')]);
    });

    test('a key of the type wins: the full path still reads', () {
      final r = _read('Row#r states.hovered.r.opacity=0.5');
      expect(r.issues, isEmpty);
      expect(_json(_nodeOf(r.document, 'r')['states']), _json({
        'hovered': {
          'r': {'opacity': 0.5},
        },
      }));
    });

    test('an owner whose id is a media condition leaves its states to the tail', () {
      final text = _corpus({
        'phone': {
          'type': 'row',
          'children': ['pt'],
          'layout': {'width': {'fill': 0}, 'height': {'hug': 0}},
          'props': {'crossAxisAlignment': 'center'},
          'states': {
            'hovered': {
              'pt': {
                'props': {
                  'style': {'color': 'primary'},
                },
              },
            },
          },
        },
        'pt': {
          'type': 'text',
          'layout': {'width': {'hug': 0}, 'height': {'hug': 0}},
          'props': {
            'text': 'x',
            'style': {'fontSize': 13, 'color': '#FF111827'},
          },
        },
      }, ['phone'], said: const []);
      expect(_lineOf(text, 'phone'), contains('"states"'));
      expect(_stateWords(_lineOf(text, 'pt')), isEmpty);
    });
  });

  group('from the corpus', () {
    test('ActionButton: a pressed opacity over bindings', () {
      // CodelesslySDK design_systems/cards/components/ActionButton.json (btn).
      final text = _corpus({
        'btn': {
          'type': 'row',
          'children': [],
          'props': {'crossAxisAlignment': 'center', 'spacing': 8, 'mainAxisAlignment': 'center'},
          'layout': {
            'width': {'fill': 0},
            'height': 46,
            'padding': [16, 0, 16, 0],
          },
          'decoration': {
            'fills': [
              {'color': 'accent'},
            ],
            'radius': 14,
          },
          'bind': {'opacity': r'${= props.enabled ? 1 : 0.4}'},
          'states': {
            'pressed': {
              'btn': {'opacity': 0.82},
            },
          },
        },
      }, ['btn']);
      expect(_lineOf(text, 'btn'), contains('pressed.opacity=0.82'));
    });

    test('Chip: its own look and its label\'s and icon\'s while selected', () {
      // CodelesslySDK design_systems/cards/components/Chip.json.
      final text = _corpus({
        'chip': {
          'type': 'row',
          'children': ['strut', 'chipContent'],
          'props': {'crossAxisAlignment': 'center', 'spacing': 0},
          'layout': {
            'width': {'hug': 60},
            'height': {'hug': 24},
            'padding': [8, 0, 8, 0],
          },
          'decoration': {
            'fills': [
              {'color': 'subtleFill'},
            ],
            'strokes': [
              {'color': '#00000000'},
            ],
            'radius': 9,
          },
          'bind': {'selected': r'${= selected}'},
          'states': {
            'selected': {
              'chip': {
                'decoration': {
                  'fills': [
                    {'color': 'activeTint'},
                  ],
                  'strokes': [
                    {'color': 'primaryTintBorder'},
                  ],
                },
              },
              'label': {
                'props': {
                  'style': {'color': 'primary'},
                },
              },
              'icon': {
                'props': {'color': 'primary'},
              },
            },
            'hovered': {
              'chip': {
                'decoration': {
                  'foregroundFills': [
                    {'color': 'hoverOverlay'},
                  ],
                },
              },
            },
          },
        },
        'strut': {
          'type': 'box',
          'layout': {'width': 0, 'height': 24},
        },
        'icon': {
          'type': 'icon',
          'props': {'icon': 'sell', 'color': 'secondaryText', 'size': 12},
          'layout': {'width': 12, 'height': 12},
        },
        'label': {
          'type': 'text',
          'props': {
            'text': 'Tag',
            'style': {'from': 'controlCompact', 'color': 'primaryText'},
          },
          'layout': {
            'width': {'hug': 40},
            'height': {'hug': 15},
          },
        },
        'chipContent': {
          'type': 'row',
          'children': ['icon', 'label'],
          'props': {'crossAxisAlignment': 'center', 'spacing': 4},
          'layout': {
            'width': {'hug': 40},
            'height': {'hug': 16},
          },
        },
      }, ['chip']);
      expect(_lineOf(text, 'chip'), contains('selected={selected}'));
      expect(_stateWords(_lineOf(text, 'chip')), ['selected.fill=activeTint', 'selected.strokes=[{"color":"primaryTintBorder"}]', 'hovered.foregroundFills=[{"color":"hoverOverlay"}]']);
      expect(_stateWords(_lineOf(text, 'label')), ['chip.selected.color=primary']);
      expect(_stateWords(_lineOf(text, 'icon')), ['chip.selected.color=primary']);
    });

    test('a disabled row, a focused ring, a hovered row of a list', () {
      // CodelesslySDK design_systems (states.disabled.row.opacity,
      // states.focused.box.decoration.strokes[].color,
      // states.hovered.row.decoration.fills[].color).
      final text = _corpus({
        'row': {
          'type': 'row',
          'children': ['box'],
          'props': {'crossAxisAlignment': 'center', 'spacing': 8},
          'layout': {
            'width': {'fill': 0},
            'height': 36,
            'padding': [12, 0, 12, 0],
          },
          'bind': {'disabled': r'${= !props.enabled}'},
          'states': {
            'disabled': {
              'row': {'opacity': 0.5},
            },
            'hovered': {
              'row': {
                'decoration': {
                  'fills': [
                    {'color': 'secondaryBackground'},
                  ],
                },
              },
            },
            'focused': {
              'box': {
                'decoration': {
                  'strokes': [
                    {'color': 'focusBorder'},
                  ],
                },
              },
            },
          },
        },
        'box': {
          'type': 'box',
          'layout': {'width': 16, 'height': 16},
          'decoration': {
            'strokes': [
              {'color': 'primaryBorder'},
            ],
            'radius': 4,
          },
        },
      }, ['row']);
      expect(_stateWords(_lineOf(text, 'row')), ['disabled.opacity=0.5', 'hovered.fill=secondaryBackground']);
      expect(_stateWords(_lineOf(text, 'box')), ['row.focused.strokes=[{"color":"focusBorder"}]']);
    });

    test('a card of a board: dragged by its id, ringed while selected', () {
      // CodelesslySDK examples/showcase/desktop/native/app_board/round2/doc.json (card).
      final text = _corpus({
        'card': {
          'type': 'column',
          'children': [],
          'props': {'crossAxisAlignment': 'start', 'spacing': 8},
          'layout': {
            'width': {'fill': 188},
            'height': {'hug': 112},
            'padding': 12,
          },
          'decoration': {
            'fills': [
              {'color': '#FFFFFFFF'},
            ],
            'strokes': [
              {'color': '#FFE5E7EB'},
            ],
            'strokeWidth': 1.5,
            'radius': 12,
          },
          'bind': {'selected': r'${= selectedId == item.id}'},
          'states': {
            'hovered': {
              'card': {
                'decoration': {
                  'strokes': [
                    {'color': '#FFCBD5E1'},
                  ],
                },
              },
            },
            'selected': {
              'card': {
                'decoration': {
                  'strokes': [
                    {'color': '#FF2563EB'},
                  ],
                  'effects': [
                    {
                      'type': 'dropShadow',
                      'color': '#262563EB',
                      'offset': [0, 0],
                      'blurRadius': 0,
                      'spreadRadius': 3,
                    },
                  ],
                },
              },
            },
          },
          'draggable': {'group': 'card', 'data': r'${item.id}', 'start': 'auto', 'childWhenDragging': 'ghost'},
        },
      }, ['card'], keys: const ['states', 'draggable']);
      final line = _lineOf(text, 'card');
      expect(line, contains('drag=card(item.id) draggable.start=auto draggable.childWhenDragging=ghost'));
      expect(_stateWords(line), [
        'hovered.strokes=[{"color":"#FFCBD5E1"}]',
        'selected.strokes=[{"color":"#FF2563EB"}]',
        'selected.effects=[{"type":"dropShadow","color":"#262563EB","offset":[0,0],"blurRadius":0,"spreadRadius":3}]',
      ]);
    });
  });

  group('a node\'s name and its behaviors', () {
    test('name= is the node\'s name', () {
      for (final (line, name) in [('Column#b name=Board', 'Board'), ('Column#b name="Search results"', 'Search results')]) {
        final r = _read(line);
        expect(r.issues, isEmpty);
        expect(_nodeOf(r.document, 'b')['name'], name);
        final printed = printNotation(r.document, catalog: standardCatalog);
        expect(_lineOf(printed, 'b'), endsWith(line.substring(9)));
      }
    });

    test('a behavior is written by the keys\' names', () {
      const layout = {
        'width': {'fill': 0},
        'height': {'hug': 0},
      };
      for (final (fields, words) in <(Map<String, Object?>, String)>[
        ({'inkWell': {'hoverColor': 'hoverOverlay', 'splashColor': '#142563EB'}}, 'inkWell.hoverColor=hoverOverlay inkWell.splashColor=#142563EB'),
        ({'focusable': false}, 'focusable=false'),
        ({'ignorePointer': true}, 'ignorePointer=true'),
        ({'floating': true}, 'floating=true'),
        ({'reorderHandle': true}, 'reorderHandle=true'),
        ({'motion': {'rotate': 90, 'translateX': -5}}, 'motion.rotate=90 motion.translateX=-5'),
        ({'focusGroup': {'typeAhead': true}}, 'focusGroup.typeAhead=true'),
        ({'form': {'autovalidateMode': 'onUnfocus'}}, 'form.autovalidateMode=onUnfocus'),
      ]) {
        final node = {'type': 'row', 'children': <Object?>[], 'layout': layout, 'props': {'crossAxisAlignment': 'center'}, ...fields};
        final text = _corpus({'n': node}, ['n'], keys: fields.keys.toList());
        expect(_lineOf(text, 'n'), contains(words), reason: text);
        // Written, it reads as the field.
        final r = _read('Column#root\n  Row#n $words');
        expect(r.issues, isEmpty, reason: words);
        for (final k in fields.keys) {
          expect(_json(_nodeOf(r.document, 'n')[k]), _json(fields[k]), reason: words);
        }
      }
    });
  });
}
