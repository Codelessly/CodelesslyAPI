# The corpora against the base (generated)

Written by `tool/corpus_closure.dart` (track B, step B2; design note 23). Do not edit: run it again.

A word beyond the core is one a writer used that is not a core word of the notation. It is **defined by the writer** when its resolution is a definition (`define`, a page's or a site's) or a site's own component; it **maps to a word we have** when it is an alias, a design system's component or a universal word; it has **no definition that renders** when it is unknown (a placeholder, or left out), refused, a primitive (a labelled box stands in), or given and never read.

## First corpus: open (the SDK's tool/vocabulary/corpus: 313 answers, not asked to define)

313 files, 1078 screens, expanded 1280 wide with Cards; aliases: built-in + Cards.

Its writers were not asked to define the words they used: what resolved as a definition is the design system's (Cards), counted as a word we have.

| kind | words | core | beyond the core | defined by the writer | maps to a word we have | no definition that renders |
|---|---|---|---|---|---|---|
| type | 602 | 75 | 527 | 0 (0.0%) | 111 (21.1%) | 416 (78.9%) |
| text | 191 | 50 | 141 | 0 (0.0%) | 52 (36.9%) | 89 (63.1%) |
| parameter | 2899 | 401 | 2498 | 0 (0.0%) | 672 (26.9%) | 1826 (73.1%) |
| flag | 360 | 117 | 243 | 0 (0.0%) | 65 (26.7%) | 178 (73.3%) |
| event | 626 | 99 | 527 | 0 (0.0%) | 147 (27.9%) | 380 (72.1%) |
| variant | 56 | 33 | 23 | 0 (0.0%) | 4 (17.4%) | 19 (82.6%) |
| verb | 312 | 261 | 51 | 0 (0.0%) | 0 (0.0%) | 51 (100.0%) |
| key | 0 | 0 | 0 | 0 (0%) | 0 (0%) | 0 (0%) |
| function | 99 | 59 | 40 | 0 (0.0%) | 0 (0.0%) | 40 (100.0%) |
| statement | 8 | 6 | 2 | 0 (0.0%) | 2 (100.0%) | 0 (0.0%) |
| all | 5153 | 1101 | 4052 | 0 (0.0%) | 1053 (26.0%) | 2999 (74.0%) |

Types we do not have, by files (the first twenty): 

`Marker` (9 files, 20 uses), `SeatMap` (7 files, 9 uses), `FileDrop` (6 files, 6 uses), `Ruler` (5 files, 7 uses), `Compass` (5 files, 5 uses), `Knob` (4 files, 14 uses), `MapMarker` (4 files, 9 uses), `Pin` (4 files, 8 uses), `Wheel` (4 files, 4 uses), `Flag` (3 files, 11 uses), `Clock` (3 files, 10 uses), `Hotspot` (3 files, 5 uses), `Lane` (3 files, 4 uses), `Arrow` (3 files, 3 uses), `Confetti` (3 files, 3 uses), `Footer` (3 files, 3 uses), `LevelMeter` (3 files, 3 uses), `MapPin` (3 files, 3 uses), `Marquee` (3 files, 3 uses), `Minimap` (3 files, 3 uses)

## First corpus: define (tool/vocabulary/corpus-define: 128 answers, asked to define)

128 files, 410 screens, expanded 1280 wide with Cards; aliases: built-in + Cards.

Its writers were asked to define the words they used: what resolved as a definition is theirs, or the design system's (Cards; the table does not tell them apart), or a site's component.

| kind | words | core | beyond the core | defined by the writer | maps to a word we have | no definition that renders |
|---|---|---|---|---|---|---|
| type | 447 | 54 | 393 | 354 (90.1%) | 36 (9.2%) | 3 (0.8%) |
| text | 161 | 34 | 127 | 97 (76.4%) | 28 (22.0%) | 2 (1.6%) |
| parameter | 1411 | 186 | 1225 | 1029 (84.0%) | 64 (5.2%) | 132 (10.8%) |
| flag | 91 | 71 | 20 | 10 (50.0%) | 7 (35.0%) | 3 (15.0%) |
| event | 337 | 38 | 299 | 218 (72.9%) | 19 (6.4%) | 62 (20.7%) |
| variant | 28 | 25 | 3 | 0 (0.0%) | 3 (100.0%) | 0 (0.0%) |
| verb | 143 | 132 | 11 | 0 (0.0%) | 0 (0.0%) | 11 (100.0%) |
| key | 0 | 0 | 0 | 0 (0%) | 0 (0%) | 0 (0%) |
| function | 60 | 48 | 12 | 0 (0.0%) | 0 (0.0%) | 12 (100.0%) |
| statement | 6 | 6 | 0 | 0 (0%) | 0 (0%) | 0 (0%) |
| all | 2684 | 594 | 2090 | 1708 (81.7%) | 157 (7.5%) | 225 (10.8%) |

Types we do not have, by files (the first twenty): 

`StatusPill` (1 files, 2 uses), `Dots` (1 files, 1 uses), `Footer` (1 files, 1 uses), `Hotspot` (1 files, 1 uses), `MatchPairs` (1 files, 1 uses)

## Round 10 (116 runs)

From the harvest's table of every word beyond the core (1859 rows: a word once per kind; a parameter, flag or event once per type it is on). A word is counted under what most of its uses resolved to; uses are counted under what each resolved to.

| kind | words | defined by the writer | maps to a word we have | no definition that renders | uses | uses defined | uses mapped | uses with none |
|---|---|---|---|---|---|---|---|---|
| type | 395 | 383 (97.0%) | 5 (1.3%) | 7 (1.8%) | 4497 | 4354 (96.8%) | 49 (1.1%) | 94 (2.1%) |
| parameter | 897 | 812 (90.5%) | 33 (3.7%) | 52 (5.8%) | 6253 | 5718 (91.4%) | 304 (4.9%) | 231 (3.7%) |
| flag | 377 | 333 (88.3%) | 11 (2.9%) | 33 (8.8%) | 1489 | 1240 (83.3%) | 176 (11.8%) | 73 (4.9%) |
| event | 80 | 61 (76.3%) | 7 (8.8%) | 12 (15.0%) | 589 | 511 (86.8%) | 60 (10.2%) | 18 (3.1%) |
| variant | 16 | 0 (0.0%) | 0 (0.0%) | 16 (100.0%) | 26 | 0 (0.0%) | 0 (0.0%) | 26 (100.0%) |
| verb | 9 | 0 (0.0%) | 1 (11.1%) | 8 (88.9%) | 23 | 0 (0.0%) | 2 (8.7%) | 21 (91.3%) |
| key | 13 | 0 (0.0%) | 1 (7.7%) | 12 (92.3%) | 53 | 0 (0.0%) | 12 (22.6%) | 41 (77.4%) |
| function | 72 | 71 (98.6%) | 0 (0.0%) | 1 (1.4%) | 445 | 444 (99.8%) | 0 (0.0%) | 1 (0.2%) |
| all | 1859 | 1660 (89.3%) | 58 (3.1%) | 141 (7.6%) | 13375 | 12267 (91.7%) | 603 (4.5%) | 505 (3.8%) |

### The recurring words some uses of which have no definition that renders (the first twenty, by runs)

| kind | word | runs | uses | resolved |
|---|---|---|---|---|
| type | `Mast` | 19 | 221 | site 206, unknown 10, definition 5 |
| type | `Masthead` | 18 | 200 | site 189, definition 5, unknown 6 |
| type | `App` | 12 | 35 | unknown 19, core 16 |
| type | `NavSection` | 9 | 17 | unknown 13, core 4 |
| parameter | `Toggle.semanticLabel` | 5 | 9 | unknown 9 |
| key | `e` | 5 | 8 | refused 7, core 1 |
| parameter | `Slider.semanticLabel` | 4 | 13 | unknown 13 |
| type | `EntryForm` | 4 | 12 | unknown 2, site 10 |
| parameter | `Image.url` | 4 | 12 | unknown 12 |
| parameter | `Grid.crossAxisSpacing` | 4 | 9 | unknown 9 |
| parameter | `Grid.mainAxisSpacing` | 4 | 9 | unknown 9 |
| verb | `setThemeMode` | 4 | 5 | unknown 4, core 1 |
| type | `MethodCard` | 3 | 31 | definition 6, unknown 6, site 19 |
| parameter | `MethodCard.signature` | 3 | 31 | definition 6, unknown 6, site 19 |
| key | `n` | 3 | 6 | refused 6 |
| type | `Console` | 3 | 5 | site 3, definition 1, unknown 1 |
| type | `RangeSlider` | 3 | 5 | unknown 3, definition 2 |
| parameter | `RangeSlider.end` | 3 | 5 | unknown 3, definition 2 |
| parameter | `RangeSlider.max` | 3 | 5 | unknown 3, definition 2 |
| parameter | `RangeSlider.min` | 3 | 5 | unknown 3, definition 2 |

Types with no definition that renders in most of their uses: 6: `App` (12), `NavSection` (9), `RangeSlider` (3), `Navigation` (1), `LibraryLinks` (1), `FilePicker` (1).
