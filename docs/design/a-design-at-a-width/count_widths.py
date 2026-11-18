"""What round 11's writers wrote when a part was to differ at a width.

Run:  python count_widths.py <dsl-api-11 folder> > COUNTS.md

Reads the notation of arms 1-write, 2-write-repair and 3-write-desk (pages/ and
components/, not drafts/) and the web arm's src/ (4-web). Prints Markdown tables.
Every number in docs/design/24-a-design-at-a-width.md section 2 comes from here.
"""
import collections
import os
import re
import sys

ROOT = sys.argv[1]
ARMS = ['1-write', '2-write-repair', '3-write-desk']
W = r'(phone|tablet|desktop|mobile)'

HIDE = re.compile(r'(?<![\w.])hide=' + W + r'\b')
SHOW = re.compile(r'(?<![\w.])show=' + W + r'\b')
PREFIX = re.compile(r'(?<![\w.#"])' + W + r'\.[a-zA-Z]')
PREFIX_VISIBLE = re.compile(r'(?<![\w.#"])' + W + r'\.(visible|hidden)\b')
VISIBLE_BOUND = re.compile(r'(?<![\w.])visible=\{')
IF_WIDTHISH = re.compile(r'^\s*if\s+[^\n]*?\b[a-z]*(?:phone|mobile|narrow|desktop|tablet)\w*', re.I)
STRINGS = re.compile(r'"[^"]*"|\'[^\']*\'')
BLOCK_LINE = re.compile(r'^\s*(?:(?:if|at|when|on|for)\s+)?' + W + r'\s*:?\s*$', re.I)
SCREEN = re.compile(r'\bscreen\.(width|breakpoint|height)')
COMMENT = re.compile(r'//.*\b(phone|mobile|narrow|tablet|small screen|desktop)', re.I)
WORD_BY_WIDTH = re.compile(r'^\s*(?:define\s+)?(?:[A-Z][A-Za-z0-9]*)?(?:Mobile|Phone|Desktop|Tablet|Narrow)[A-Za-z0-9]*\b')
TYPE = re.compile(r'^\s*([A-Za-z][A-Za-z0-9]*)')
WIDTH_WORDS = re.compile(r'\s(?:hide|show)=' + W + r'\b|\s' + W + r'\.[A-Za-z]+(?:=(?:\{[^}]*\}|\S+))?')


def files(arm):
    for brief in sorted(os.listdir(ROOT)):
        for part in ('pages', 'components'):
            d = os.path.join(ROOT, brief, arm, part)
            if not os.path.isdir(d):
                continue
            for f in sorted(os.listdir(d)):
                if f.endswith('.txt'):
                    yield brief, os.path.join(d, f)


def indent(s):
    return len(s) - len(s.lstrip(' '))


def body(lines, i):
    """The lines under line i (more indented), as written."""
    out, base = [], indent(lines[i])
    for l in lines[i + 1:]:
        if not l.strip():
            continue
        if indent(l) <= base:
            break
        out.append(l)
    return out


def parent(lines, i):
    base = indent(lines[i])
    for j in range(i - 1, -1, -1):
        if lines[j].strip() and indent(lines[j]) < base:
            return j
    return -1


def norm(l):
    return WIDTH_WORDS.sub('', ' ' + l.strip()).strip()


rows = collections.OrderedDict()
quotes = collections.defaultdict(list)
shapes = collections.Counter()
builds = collections.defaultdict(set)
for arm in ARMS:
    c = collections.Counter()
    c['i. a line that opens a block for a width (if phone, at phone, when phone, phone:, phone)'] += 0
    for brief, path in files(arm):
        text = open(path, encoding='utf-8', errors='replace').read()
        lines = text.split('\n')
        c['files'] += 1
        rel = os.path.relpath(path, ROOT).replace('\\', '/')
        shown, hidden = [], []
        for i, l in enumerate(lines):
            s = l.strip()
            if not s or s.startswith('//') and not COMMENT.search(s):
                continue
            c['lines'] += 1
            has = False
            if PREFIX.search(l):
                c['a. a key at a width (phone.pad=16)'] += 1
                has = True
            if PREFIX_VISIBLE.search(l):
                c['a1. of them visible/hidden at a width'] += 1
            if HIDE.search(l):
                c['b. hide=<width>'] += 1
                hidden.append(i)
                has = True
                if body(lines, i):
                    c['b1. hide= on a line with lines under it'] += 1
            if SHOW.search(l):
                c['c. show=<width>'] += 1
                shown.append(i)
                has = True
                if body(lines, i):
                    c['c1. show= on a line with lines under it'] += 1
                if VISIBLE_BOUND.search(l):
                    c['c2. show= with visible={…} (a pane chosen by state)'] += 1
                    quotes['c2'].append((rel, i + 1, s))
                t = TYPE.match(l)
                if t:
                    shapes[t.group(1)] += 1
            if IF_WIDTHISH.search(STRINGS.sub('""', l)):
                c['d. if over a width-named state (if phonePane==…)'] += 1
                quotes['d'].append((rel, i + 1, s))
                has = True
            if BLOCK_LINE.match(l):
                c['i. a line that opens a block for a width (if phone, at phone, when phone, phone:, phone)'] += 1
                quotes['i'].append((rel, i + 1, s))
            if SCREEN.search(l):
                c['e. screen.width in an expression'] += 1
                quotes['e'].append((rel, i + 1, s))
                has = True
            if COMMENT.search(l):
                c['f. a comment about a width'] += 1
                quotes['f'].append((rel, i + 1, s))
            if WORD_BY_WIDTH.search(l):
                c['g. a line whose word is named by a width (PhoneNotebooks)'] += 1
                quotes['g'].append((rel, i + 1, s))
            if has:
                builds[arm].add(brief)
        # Twins: a line shown at a width and a sibling hidden at the same width.
        for i in shown:
            w = SHOW.search(lines[i]).group(1)
            p = parent(lines, i)
            for j in hidden:
                if j == i or parent(lines, j) != p or indent(lines[j]) != indent(lines[i]):
                    continue
                if HIDE.search(lines[j]).group(1) != w:
                    continue
                c['h. twins: show=W beside a sibling hide=W'] += 1
                a, b = TYPE.match(lines[i]), TYPE.match(lines[j])
                if a and b and a.group(1) == b.group(1):
                    c['h1. twins of the same word'] += 1
                bi, bj = [norm(x) for x in body(lines, i)], [norm(x) for x in body(lines, j)]
                if a and b and a.group(1) == b.group(1) and bi == bj:
                    c['h4. value twins: the same word, the same lines under (a phone.key= says it)'] += 1
                else:
                    c['h5. structure twins: another word, or other lines under'] += 1
                    if a and b and a.group(1) == b.group(1):
                        c['h5a. of them the same word, other lines under'] += 1
                    elif a and b and {a.group(1), b.group(1)} <= {'Row', 'Column', 'Flex'}:
                        c['h5b. of them a Row and a Column (phone.direction= says it)'] += 1
                    elif a and b and {a.group(1), b.group(1)} <= {'Grid', 'Column', 'Row'}:
                        c['h5c. of them a Grid and a Column or Row (phone.cols= says most)'] += 1
                    else:
                        c['h5d. of them another word (IconButton for a Button, a menu button for a row of links …)'] += 1
                    quotes['h5'].append((rel, i + 1, lines[i].strip() + '   ||   ' + lines[j].strip()))
                    if re.search(r'IconButton\s+"(menu|more_horiz|more_vert|menu_open)"', lines[i]):
                        c['h6. of them a menu button shown where a row is hidden'] += 1
                c['h2. lines under the shown twin'] += len(bi)
                c['h3. of them also under the hidden twin, the same up to width words'] += sum(1 for x in bi if x in bj)
                if len(quotes['h']) < 400:
                    quotes['h'].append((rel, i + 1, lines[i].strip() + '   ||   ' + lines[j].strip()))
                break
    rows[arm] = c

keys = sorted({k for c in rows.values() for k in c if k not in ('files', 'lines')})
print('## Notation (arms 1 to 3: pages/ and components/)\n')
print('| | ' + ' | '.join(ARMS) + ' | all |')
print('|---|' + '---|' * (len(ARMS) + 1))
for k in ['files', 'lines'] + keys:
    vals = [rows[a][k] for a in ARMS]
    print(f'| {k} | ' + ' | '.join(str(v) for v in vals) + f' | {sum(vals)} |')
print('\nBuilds (briefs) that write a width at all (a key at a width, hide=, show=, if over a width state, screen.width): '
      + ', '.join(f'{a} {len(builds[a])} of 30' for a in ARMS))
print('\n### The lines written show=<width>, by their first word\n')
print('| word | lines |\n|---|---|')
for w, n in shapes.most_common(25):
    print(f'| `{w}` | {n} |')
for k, title in [('d', 'if over a width-named state'), ('e', 'screen.width'), ('f', 'comments'),
                 ('g', 'words named by a width'), ('c2', 'show= with visible={…}'), ('h5', 'structure twins'), ('h', 'all twins')]:
    print(f'\n### {title} ({len(quotes[k])})\n')
    for rel, n, s in quotes[k]:
        print(f'- `{rel}:{n}`: `{s[:200]}`')

# The web arm.
print('\n## Web (arm 4-web: src/)\n')
media = re.compile(r'@media\s*([^{]*)\{', re.S)
wc = collections.Counter()
props = collections.Counter()
conds = collections.Counter()
arrange = collections.Counter()
web_builds = set()
twin_class = re.compile(r'className=["{`][^>]*?\b(mobile|phone|desktop|narrow|wide|compact)[-_][\w-]*', re.I)
for brief in sorted(os.listdir(ROOT)):
    src = os.path.join(ROOT, brief, '4-web', 'src')
    if not os.path.isdir(src):
        continue
    for f in sorted(os.listdir(src)):
        p = os.path.join(src, f)
        t = open(p, encoding='utf-8', errors='replace').read()
        if f.endswith('.css'):
            for m in media.finditer(t):
                cond = re.sub(r'\s+', '', m.group(1))
                if 'width' not in cond:
                    wc['@media blocks not about width (motion, colour scheme, print)'] += 1
                    continue
                wc['@media blocks about width'] += 1
                web_builds.add(brief)
                conds[cond] += 1
                depth, k = 1, m.end()
                while k < len(t) and depth:
                    depth += {'{': 1, '}': -1}.get(t[k], 0)
                    k += 1
                block = t[m.end():k - 1]
                for d in re.findall(r'([a-z-]+)\s*:\s*([^;{}]+)', block):
                    name, val = d[0], d[1].strip()
                    if name == 'display' and val.startswith('none'):
                        props['display: none (a part hidden)'] += 1
                    elif name == 'display':
                        props['display: other (a part shown, or its layout changed)'] += 1
                    elif name in ('flex-direction', 'flex-wrap', 'grid-template-columns', 'grid-template-rows',
                                  'grid-template-areas', 'grid-column', 'grid-row', 'grid-area', 'order', 'position',
                                  'inset', 'top', 'left', 'right', 'bottom', 'transform'):
                        props['arrangement (direction, wrap, grid, order, position)'] += 1
                        arrange[name] += 1
                    else:
                        props['a value (size, padding, font, gap, colour …)'] += 1
        elif f.endswith(('.tsx', '.ts', '.jsx')):
            for m in re.finditer(r'\b(sm|md|lg|xl|max-sm|max-md|max-lg):[a-z][\w-]*', t):
                wc['Tailwind width prefixes in markup (md:hidden …)'] += 1
            for m in re.finditer(r'matchMedia\([^)]*width|innerWidth\s*[<>]', t):
                wc['a width read in script (matchMedia width, innerWidth <)'] += 1
            for m in twin_class.finditer(t):
                wc['elements with a width-named class (mobile-nav, phone-only)'] += 1
            for m in re.finditer(r'\bfunction\s+(Mobile|Phone|Desktop)\w*|\bconst\s+(Mobile|Phone|Desktop)\w*\s*=', t):
                wc['a component named by a width (MobileNav)'] += 1
for k in ('a component named by a width (MobileNav)', 'Tailwind width prefixes in markup (md:hidden …)'):
    wc[k] += 0
print('| | count |\n|---|---|')
for k, v in wc.most_common():
    print(f'| {k} | {v} |')
print(f'| builds with a width @media | {len(web_builds)} of 30 |')
print('\n### Declarations inside the width @media blocks\n\n| kind | count |\n|---|---|')
for k, v in props.most_common():
    print(f'| {k} | {v} |')
print('\n### The arrangement declarations, by property\n\n| property | count |\n|---|---|')
for k, v in arrange.most_common():
    print(f'| `{k}` | {v} |')
print('\n### The commonest conditions\n\n| condition | blocks |\n|---|---|')
for k, v in conds.most_common(12):
    print(f'| `{k}` | {v} |')
