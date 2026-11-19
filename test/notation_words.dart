// The words a writer's dictionary defines over the base (Brand, NavItem,
// Link, Heading …): the tests whose pages are written with them read them
// as a page reads a dictionary it is given (NotationOptions.dictionary).

import 'package:codelessly_api/notation.dart';

/// Each word's definition, by its name.
const notationTestWords = <String, String>{
  'Brand': '''define Brand "name" "under" icon
  Row gap=10 middle pad=[8,6,8,10] ...
    if icon
      Box w=28 h=28 radius=8 fill={theme.accent} center middle
        Icon "{icon}" size=16 color=#FFFFFFFF
    if under
      Column gap=0
        Text "{name}" size=15 weight=700
        Text "{under}" size=11 color={coalesce(theme.mutedInk, "#FF6B7280")}
    else
      Text "{name}" size=15 weight=700''',
  'computed': '''define computed
  state ...''',
  'ConfirmDialog': '''define ConfirmDialog "title" "message" confirm="Confirm" cancel="Cancel" danger=false onConfirm onCancel
  Dialog "{title}" "{message}" ...
    ...
    Row gap=8 end
      Button.ghost "{cancel}" onTap={onCancel; close}
      Button.{danger ? "destructive" : ""} "{confirm}" onTap={onConfirm; close}''',
  'Dots': '''define Dots @page=0 count=3
  Row gap=6 center middle h=16 ...
    each dot in range(count)
      Box w={index==page?16:6} h=6 radius=3 fill={index==page?theme.accent:theme.track} onTap={page=index}''',
  'H1': '''define H1 "text"
  Text.heading1 "{text}" ...''',
  'H2': '''define H2 "text"
  Text.heading2 "{text}" ...''',
  'H3': '''define H3 "text"
  Text.heading3 "{text}" ...''',
  'H4': '''define H4 "text"
  Text.strong "{text}" ...''',
  'Heading': '''define Heading "text" level=2
  Text.{level == 1 ? "heading1" : level == 2 ? "heading2" : "heading3"} "{text}" ...''',
  'IconTile': '''define IconTile "name" size=40 color fill
  Box w={size} h={size} radius={round(size/4)} fill={coalesce(fill, theme.iconTile, theme.selectedFill)} center middle ...
    Icon "{coalesce(name, "star")}" size={round(size/2)} color={coalesce(color, theme.accent)}''',
  'Link': '''define Link "label" href
  if startsWith(coalesce(href, ""), "#")
    Text "{label}" color={coalesce(theme.accentText, theme.accent)} onTap={scroll {replace(href, "#", "")}} ...
  else if href
    Text "{label}" color={coalesce(theme.accentText, theme.accent)} onTap={link {href}} ...
  else
    Text "{label}" color={coalesce(theme.accentText, theme.accent)} ...''',
  'Logo': '''define Logo "name" "under" icon
  Brand "{name}" "{under}" icon={icon} ...''',
  'MenuItem': '''define MenuItem "label" icon badge selected=false
  NavItem "{label}" icon={icon} badge={badge} selected={selected} ...''',
  'NavFooter': '''define NavFooter gap=2 pad=[0,8,0,0]
  SidebarFooter gap={gap} pad={pad} ...
    ...''',
  'NavGroup': '''define NavGroup "label"
  NavSection "{label}" ...''',
  'NavItem': '''define NavItem "label" icon badge selected=false
  Row w=fill gap=10 middle pad=[10,7,10,7] radius=6 selected={selected} selected.fills=[{"color":"{theme.accent}","opacity":0.12}] hovered.fill={theme.hoverFill} ...
    if icon
      Icon "{icon}" size=18 color={coalesce(theme.mutedInk, "#FF6B7280")}
    Text "{label}" size=13 weight=500 color={coalesce(theme.quietInk, "#FF374151")} grow
    if badge
      Text.muted "{badge}"''',
  'NavLabel': '''define NavLabel "label"
  NavSection "{label}" ...''',
  'NavLink': '''define NavLink "label" icon badge selected=false
  NavItem "{label}" icon={icon} badge={badge} selected={selected} ...''',
  'NavSection': '''define NavSection "label"
  Text "{upper(label)}" size=11 weight=600 letterSpacing=0.6 color={coalesce(theme.mutedInk, "#FF6B7280")} w=fill pad=[10,16,10,6] ...''',
  'Shortcut': '''define Shortcut "chord" key keys combo hint description label onPress
  key {replace(coalesce(chord, key, keys, combo), " ", "")} ... onPress={onPress}''',
  'SidebarFooter': '''define SidebarFooter gap=2 pad=[0,8,0,0]
  Spacer
  Column w=fill gap={gap} pad={pad} border-top={theme.line} ...
    ...''',
  'SidebarGroup': '''define SidebarGroup "label"
  NavSection "{label}" ...''',
  'SidebarItem': '''define SidebarItem "label" icon badge selected=false
  NavItem "{label}" icon={icon} badge={badge} selected={selected} ...''',
  'SidebarLabel': '''define SidebarLabel "label"
  NavSection "{label}" ...''',
  'SidebarSection': '''define SidebarSection "label"
  NavSection "{label}" ...''',
  'Title': '''define Title "text"
  Text.title "{text}" ...''',
};

/// [options] with [notationTestWords] as a dictionary named `words`.
NotationOptions withTestWords([NotationOptions options = const NotationOptions()]) => options.dictionary(notationTestWords, name: 'words');
