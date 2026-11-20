# 26. Lists that hold their place

A list over data is a window onto items that change while someone reads it: a message arrives, an older page
loads, a provisional copy is replaced, a row is deleted. Until now a running list kept its scroll *offset* through
such a change, so whatever was put or taken out before the view moved everything in it. The NOCD rebuild measured
it: a reversed chat the reader had scrolled up in moved 139 px when a message arrived (105 to 139 px over four
parts). Only a list with `stickToEnd` kept its place, and only for items put in front of the first item it ever
showed.

## The behaviour underneath

> A list anchors what is in view to an item, not to an offset, when items are put before it or taken out before
> it.

This is browsers' scroll anchoring (CSS `overflow-anchor: auto`), on by default for every scroller since 2017. It
is not a chat word: a feed that loads newer posts above, a log that drops its oldest lines, a search list whose
results above the fold are refined, a board column that receives a card all need it.

## Decision: how a list behaves, not a key

Holding the view is the right default for every list over data, so it is not opted into. A writer cannot be expected
to know that a list needs it until the jump is seen, and no list wants the jump. What it changes for an existing
document: a list scrolled away from its start no longer moves when items are put or taken out before what is in
view. Nothing else: at rest, at its start, a list shows what is put at its start exactly as before (browsers
suppress anchoring at offset 0 for the same reason: a list at its top shows its newest entry, a todo added first
appears).

The one place this default and an app disagree is the very start. The audited NOCD thread never moves on arrival,
even when the reader is at the newest message (offset 0): the new message waits just below the view. That is a
choice an app makes about its start, so it is one key, symmetric with `stickToEnd`:

- `stickToStart` (default `true`): at its start the list shows what is put at its start. `false` keeps what is in
  view there too, once the items fill the list (a list that does not fill its view still shows them, as the app's
  physics do when there is nothing to scroll).
- `stickToEnd` keeps its documented meaning: it opens at its end, follows items added at the end while at the end,
  and keeps its place when items are put before. A list that sticks to its end keeps its place at its start too
  (as it always did), whatever `stickToStart` says.

A reversed list needs nothing of its own: its start is its bottom, so "the start" rule covers the newest message.

## How it is built

`DataListView` (the running list over data) already had the mechanism for `stickToEnd`: a viewport `center` at an
anchor item, items before it in a sliver that grows away from it, so putting items there moves nothing. Now every
list over data is built that way (not a grid, a list in sections, a list paged a page at a time, or a list that
hugs its items, which has no viewport to anchor):

1. The anchor is the first item the list showed, kept while it is there (when it is taken out, the next item still
   there). Items put before it go in the sliver before it: no offset changes at all. This alone holds the chat's
   two cases (a newer message at a reversed list's start, an older page at its far end).
2. Anything else that would move what is in view (items put in or taken out between the anchor and the view, the
   anchor taken out) is undone in the same frame. When the item keys change, the list notes the first item in view
   that is still there and where it is laid out; scroll physics (`_HoldPhysics.adjustPositionForNewDimensions`,
   which Flutter calls while the viewport lays out with new extents) put the offset back so that item is where it
   was. Items taken out between the anchor and the view are allowed for before layout (their extents are known), so
   the held item is laid out where the list looks even after a large removal.
3. At the start (the offset at its minimum), with `stickToStart` or a list that does not fill its view, the same
   physics put the offset at the new minimum: what was put at the start shows.

Items are told apart by their key (`id`, or the pagination key path), the same key `scrollTo item=` reads. Items
without one (plain strings, maps without an id rebuilt each time) are anchored as well as their equality allows.

Two lessons from building it, kept in the code's comments: a sliver whose child count changes keeps its laid-out
rows and underestimates how far it reaches (the sliver before the anchor is rebuilt as its count changes); and a
center sliver re-keyed to a new anchor moves rows between slivers, which broke semantics merging in the chat (the
anchor is therefore kept, and other moves are undone by measuring instead).

## What the reader sees on the chat

- Scrolled up, a message arrives: 0 px (was 139).
- An older page loads at the far end: 0 px (was 0).
- At the newest message, a message arrives: the message shows and the thread moves up by its height (as before);
  with `stickToStart=false`, 0 px and the message waits below.

## Also in this change

- `jumpToLatest=false` on a list that sticks to its end draws no built-in jump-to-latest button, for a pill of the
  writer's own (which reads `onScroll`). The default draws it, as before.

## Not changed

Grids, lists in sections and lists paged a page at a time keep their offset as before. The render-object list (a
list with an `itemCount` and no data) has no items that come and go.
