## Notation (arms 1 to 3: pages/ and components/)

| | 1-write | 2-write-repair | 3-write-desk | all |
|---|---|---|---|---|
| files | 272 | 245 | 182 | 699 |
| lines | 12126 | 11646 | 7998 | 31770 |
| a. a key at a width (phone.pad=16) | 0 | 75 | 0 | 75 |
| b. hide=<width> | 257 | 205 | 151 | 613 |
| b1. hide= on a line with lines under it | 59 | 67 | 50 | 176 |
| c. show=<width> | 120 | 107 | 58 | 285 |
| c1. show= on a line with lines under it | 30 | 39 | 29 | 98 |
| c2. show= with visible={…} (a pane chosen by state) | 1 | 0 | 3 | 4 |
| d. if over a width-named state (if phonePane==…) | 3 | 0 | 3 | 6 |
| e. screen.width in an expression | 0 | 4 | 0 | 4 |
| f. a comment about a width | 1 | 1 | 3 | 5 |
| g. a line whose word is named by a width (PhoneNotebooks) | 0 | 0 | 2 | 2 |
| h. twins: show=W beside a sibling hide=W | 93 | 75 | 33 | 201 |
| h1. twins of the same word | 84 | 52 | 15 | 151 |
| h2. lines under the shown twin | 68 | 126 | 57 | 251 |
| h3. of them also under the hidden twin, the same up to width words | 28 | 28 | 13 | 69 |
| h4. value twins: the same word, the same lines under (a phone.key= says it) | 73 | 38 | 8 | 119 |
| h5. structure twins: another word, or other lines under | 20 | 37 | 25 | 82 |
| h5a. of them the same word, other lines under | 11 | 14 | 7 | 32 |
| h5b. of them a Row and a Column (phone.direction= says it) | 2 | 3 | 3 | 8 |
| h5c. of them a Grid and a Column or Row (phone.cols= says most) | 3 | 2 | 2 | 7 |
| h5d. of them another word (IconButton for a Button, a menu button for a row of links …) | 4 | 18 | 13 | 35 |
| h6. of them a menu button shown where a row is hidden | 0 | 6 | 0 | 6 |
| i. a line that opens a block for a width (if phone, at phone, when phone, phone:, phone) | 0 | 0 | 0 | 0 |

Builds (briefs) that write a width at all (a key at a width, hide=, show=, if over a width state, screen.width): 1-write 30 of 30, 2-write-repair 29 of 30, 3-write-desk 20 of 30

### The lines written show=<width>, by their first word

| word | lines |
|---|---|
| `Text` | 84 |
| `Column` | 54 |
| `IconButton` | 32 |
| `Box` | 18 |
| `Row` | 12 |
| `Button` | 11 |
| `Headline` | 7 |
| `Stack` | 7 |
| `Figure` | 5 |
| `Grid` | 3 |
| `Link` | 3 |
| `DrawnScene` | 3 |
| `CoverArt` | 3 |
| `Brand` | 3 |
| `PlayerSheet` | 2 |
| `KitchenStill` | 2 |
| `ArtPanel` | 2 |
| `BookTitle` | 2 |
| `AdjustedPhoto` | 2 |
| `GridViewport` | 2 |
| `StillLife` | 2 |
| `Toolbar` | 2 |
| `Main` | 2 |
| `CompareSurface` | 2 |
| `PaintedPhoto` | 2 |

### if over a width-named state (6)

- `notes-app/1-write/pages/workspace.txt:45`: `if mobilePane=="list"`
- `notes-app/1-write/pages/workspace.txt:59`: `if mobilePane=="note"`
- `team-chat/1-write/pages/thread.txt:88`: `if desktopDetails`
- `mail-client/3-write-desk/pages/mailbox.txt:34`: `if phonePane=="folders"`
- `mail-client/3-write-desk/pages/mailbox.txt:39`: `if phonePane=="list"`
- `mail-client/3-write-desk/pages/mailbox.txt:48`: `if phonePane=="reading"`

### screen.width (4)

- `mail-client/2-write-repair/pages/mailbox.txt:33`: `Sidebar w={screen.width<1000 ? folderWidth-32 : folderWidth} hide=phone fill=#FFF8FAFC border-right=#FFE2E8F0`
- `mail-client/2-write-repair/pages/mailbox.txt:66`: `Column w={screen.width<1000 ? clamp(listWidth-55,255,330) : listWidth} grow fill=#FFFFFFFF scroll`
- `notes-app/2-write-repair/pages/workspace.txt:27`: `Sidebar w={screen.width<1024 ? clamp(bookWidth-24,176,230) : bookWidth} hide=phone`
- `notes-app/2-write-repair/pages/workspace.txt:54`: `Column w={screen.width<1024 ? clamp(listWidth-72,164,248) : listWidth} h=fill`

### comments (5)

- `team-chat/1-write/components/ConversationParts.txt:88`: `// Allows the phone sheet to settle halfway or fully open after a vertical drag.`
- `music-player/2-write-repair/components/Halftone.txt:66`: `// Switches between the player’s two phone stops.`
- `mail-client/3-write-desk/pages/mailbox.txt:203`: `// A row reports Shift, Control and Meta at activation and maps phone swipes to archive and delete.`
- `scrolly-story/3-write-desk/pages/glacier-lines.txt:300`: `// Places its children in a fixed gutter on wide windows and a compact pinned strip on phones.`
- `team-chat/3-write-desk/components/Murmur.txt:19`: `// Copies its text argument to the desktop or phone clipboard.`

### words named by a width (2)

- `notes-app/3-write-desk/pages/workspace.txt:34`: `PhoneNotebooks show=phone visible={mobilePane=="books"} selected={bookId} onPick={bookId=result; mobilePane="list"; selected=[]} onTags={go tags} onTrash={go trash} onSettings={go settings} onFind={q=`
- `notes-app/3-write-desk/components/PhoneNotebooks.txt:1`: `define PhoneNotebooks selected="" onPick onTags onTrash onSettings onFind`

### show= with visible={…} (4)

- `mail-client/1-write/pages/mailbox.txt:55`: `Column gap=0 visible={phonePane=="list"} show=phone`
- `notes-app/3-write-desk/pages/workspace.txt:34`: `PhoneNotebooks show=phone visible={mobilePane=="books"} selected={bookId} onPick={bookId=result; mobilePane="list"; selected=[]} onTags={go tags} onTrash={go trash} onSettings={go settings} onFind={q=`
- `notes-app/3-write-desk/pages/workspace.txt:46`: `Main show=phone visible={mobilePane=="list"}`
- `notes-app/3-write-desk/pages/workspace.txt:52`: `Main show=phone visible={mobilePane=="note"}`

### structure twins (82)

- `calendar-app/1-write/pages/month.txt:88`: `Column h=76 fill={date.first==dates[selected].first ? white : wash} pad=[3,5,3,4] gap=4 show=phone onTap={selected=date.id; view="day"; go day}   ||   Column h=108 fill={date.first==dates[selected].fi`
- `calendar-app/1-write/pages/week.txt:97`: `Column scroll h=530 show=phone   ||   Column scroll h=570 hide=phone`
- `clip-editor/1-write/pages/timeline.txt:90`: `Column w=66 gap=1 show=phone   ||   Column w=154 gap=1 hide=phone`
- `clip-editor/1-write/pages/timeline.txt:96`: `TimelineCanvas grow show=phone clips={clips} markers={markers} tracks={tracks} selected={selected} head={playhead} zoom={zoom} loop={loop} loopStart={loopStart} loopEnd={loopEnd} active={activeTrack} `
- `conference/1-write/pages/schedule.txt:42`: `Column gap=12 show=phone   ||   Column gap=12 hide=phone`
- `magazine/1-write/pages/front.txt:35`: `Column gap=22 show=phone   ||   Grid cols=3 gap=24 hide=phone`
- `mail-client/1-write/pages/mailbox.txt:55`: `Column gap=0 visible={phonePane=="list"} show=phone   ||   Column gap=0 hide=phone`
- `meal-planner/1-write/pages/week.txt:20`: `Row between middle show=phone   ||   Grid cols=7 keep gap=6 hide=phone`
- `meal-planner/1-write/pages/week.txt:32`: `Column gap=8 show=phone   ||   Grid cols=7 keep gap=6 hide=phone`
- `music-player/1-write/pages/player.txt:26`: `Stack w=fill h=204 radius=22 fill=#FF35281B center middle show=phone   ||   Stack w=fill h=284 radius=22 fill=#FF35281B center middle hide=phone`
- `music-player/1-write/components/NowBar.txt:17`: `Column show=phone w=fill gap=0 pad=[10,3,10,5]   ||   Row gap=18 middle pad=[18,9,18,9] hide=phone`
- `photo-library/1-write/pages/photos.txt:39`: `IconButton "playlist_add" tooltip="Add to album" onTap={targetAlbum=""; open addSelection} show=phone   ||   Button.outline "Add to album" onTap={targetAlbum=""; open addSelection} hide=phone`
- `photo-library/1-write/components/ViewerBody.txt:53`: `Stack h=420 show=tablet hide=phone fill=#FF272725 clip=true onSwipeLeft={onNext} onSwipeRight={onPrevious} onSwipeDown={onDismiss} onEscape={onDismiss} onArrowLeft={onPrevious} onArrowRight={onNext} o`
- `photo-library/1-write/components/ViewerBody.txt:55`: `Stack h=280 show=phone fill=#FF272725 clip=true onSwipeLeft={onNext} onSwipeRight={onPrevious} onSwipeDown={onDismiss} onEscape={onDismiss} onArrowLeft={onPrevious} onArrowRight={onNext} onPinch={view`
- `restaurant/1-write/pages/home.txt:16`: `Column gap=16 pad=24 show=phone   ||   Column gap=22 pad=[76,32,28,32] hide=phone`
- `restaurant/1-write/components/Brasa.txt:52`: `Stack w=304 middle center show=tablet   ||   Stack w=690 middle center hide=tablet`
- `saas-landing/1-write/components/Relay.txt:10`: `Link "Contact sales" show=phone onTap={go contact}   ||   Button.primary "Contact sales" hide=phone onTap={go contact}`
- `seat-booking/1-write/pages/seats.txt:45`: `Row middle gap=8 show=phone   ||   Text "Use arrow keys to move and Enter to select." center color=#FFC5AEC1 size=11 hide=phone`
- `spreadsheet/1-write/pages/sheet.txt:54`: `Row middle gap=2 pad=[7,4,7,4] fill=toolbar border-bottom=line show=phone   ||   Row middle gap=6 pad=[14,6,14,6] fill=toolbar border-bottom=line hide=phone`
- `studio-portfolio/1-write/pages/work.txt:33`: `Column gap=28 show=phone   ||   Row gap=24 top hide=phone`
- `admin-console/2-write-repair/pages/audit.txt:23`: `Column show=phone gap=8   ||   Row middle gap=8 hide=phone`
- `calendar-app/2-write-repair/pages/agenda.txt:33`: `IconButton "add" tooltip="New event" onTap={editing=""; draftTitle=""; draftCalendar="Studio"; draftStart=dates[active].date; draftEnd=dates[active].date; draftStartTime="09:00"; draftEndTime="10:00";`
- `calendar-app/2-write-repair/pages/calendars.txt:33`: `IconButton "add" tooltip="New event" onTap={editing=""; draftTitle=""; draftCalendar="Studio"; draftStart=dates[active].date; draftEnd=dates[active].date; draftStartTime="09:00"; draftEndTime="10:00";`
- `calendar-app/2-write-repair/pages/day.txt:33`: `IconButton "add" tooltip="New event" onTap={editing=""; draftTitle=""; draftCalendar="Studio"; draftStart=dates[active].date; draftEnd=dates[active].date; draftStartTime="09:00"; draftEndTime="10:00";`
- `calendar-app/2-write-repair/pages/month.txt:33`: `IconButton "add" tooltip="New event" onTap={editing=""; draftTitle=""; draftCalendar="Studio"; draftStart=dates[active].date; draftEnd=dates[active].date; draftStartTime="09:00"; draftEndTime="10:00";`
- `calendar-app/2-write-repair/pages/month.txt:59`: `Box h=55 show=phone pad=[2,4,2,3] border-top=rule border-right=rule fill={d.date==dates[active].date ? "#FFF4F6FF" : "#FFFFFFFF"} onTap={active=indexOf(map(dates,x=>x.date),d.date); chosenView="Day"; `
- `calendar-app/2-write-repair/pages/search.txt:34`: `IconButton "add" tooltip="New event" onTap={editing=""; draftTitle=""; draftCalendar="Studio"; draftStart=dates[active].date; draftEnd=dates[active].date; draftStartTime="09:00"; draftEndTime="10:00";`
- `calendar-app/2-write-repair/pages/week.txt:33`: `IconButton "add" tooltip="New event" onTap={editing=""; draftTitle=""; draftCalendar="Studio"; draftStart=dates[active].date; draftEnd=dates[active].date; draftStartTime="09:00"; draftEndTime="10:00";`
- `clip-editor/2-write-repair/pages/editor.txt:69`: `IconButton "keyboard" tooltip="Keyboard shortcuts" onTap={open shortcuts} show=phone   ||   Text.mono "/ 03:12" color=#FF9CA8BA hide=phone`
- `clip-editor/2-write-repair/pages/editor.txt:89`: `Column w=92 fill=#FF242933 show=phone   ||   Column w=150 fill=#FF242933 hide=phone`
- `clip-editor/2-write-repair/pages/editor.txt:103`: `Column w={max(450,zoom*620)} gap=0 show=phone   ||   Column w={max(700,zoom*952)} gap=0 hide=phone`
- `conference/2-write-repair/pages/home.txt:18`: `Column show=phone   ||   Column hide=phone`
- `conference/2-write-repair/pages/schedule.txt:41`: `Column gap=9 show=phone   ||   Column gap=8 hide=phone`
- `food-ordering/2-write-repair/pages/restaurant.txt:21`: `IconButton "more_horiz" show=phone tooltip="Open navigation" onTap={open restaurantNavigation}   ||   Row gap=14 hide=phone`
- `food-ordering/2-write-repair/pages/restaurant.txt:99`: `Box w=96 show=phone onTap={onPhone}   ||   Box w=152 hide=phone onTap={onDesktop}`
- `meal-planner/2-write-repair/pages/week.txt:30`: `Column show=phone gap=8   ||   Grid cols=7 keep gap=5 hide=phone`
- `music-player/2-write-repair/pages/player.txt:10`: `PlayerSheet @stop start="mini" end="full" show=phone onChange={stop=result}   ||   Column hide=phone`
- `notes-app/2-write-repair/pages/tags.txt:23`: `Column gap=16 show=tablet   ||   Row gap=18 top hide=tablet`
- `notes-app/2-write-repair/pages/workspace.txt:51`: `IconButton "search" tooltip="Search" show=phone onTap={query=""; cursor=0; open command}   ||   Button.ghost "Search  ⌘ K" hide=phone onTap={query=""; cursor=0; open command}`
- `photo-library/2-write-repair/pages/photos.txt:31`: `Row gap=4 middle show=phone   ||   Row gap=4 middle hide=phone`
- `photo-library/2-write-repair/pages/search.txt:41`: `Column gap=7 show=phone   ||   Grid cols=5 gap=5 hide=phone`
- `photo-library/2-write-repair/pages/viewer.txt:40`: `Column show=tablet hide=phone   ||   Column hide=tablet`
- `photo-library/2-write-repair/pages/viewer.txt:44`: `Column show=phone   ||   Column show=tablet hide=phone`
- `restaurant/2-write-repair/pages/home.txt:27`: `Stack w=fill h=510 show=phone fill=#FF2E1B13   ||   Stack w=fill h=580 hide=phone fill=#FF2E1B13`
- `scrolly-story/2-write-repair/pages/glacier-lines.txt:34`: `Stack h=884 show=tablet hide=phone center middle fill=#FF193744   ||   Stack h=896 hide=tablet center middle fill=#FF193744`
- `scrolly-story/2-write-repair/pages/glacier-lines.txt:41`: `Stack h=760 show=phone center middle fill=#FF193744   ||   Stack h=884 show=tablet hide=phone center middle fill=#FF193744`
- `scrolly-story/2-write-repair/pages/glacier-lines.txt:66`: `Column show=phone gap=12   ||   Row gap=44 top hide=phone`
- `seat-booking/2-write-repair/pages/seats.txt:38`: `Row show=phone gap=4 middle   ||   Text "Tab to the plan, then use arrow keys to move. Enter or Space selects a seat." hide=phone color=#FFCAB7C8 size=13`
- `spreadsheet/2-write-repair/pages/sheet.txt:67`: `Row gap=5 middle pad=[8,4,8,4] fill=#FFF7F9F8 border-bottom=#FFDEE5E0 show=phone   ||   Row gap=5 middle pad=[12,4,12,4] fill=#FFF7F9F8 border-bottom=#FFDEE5E0 hide=phone`
- `story-reader/2-write-repair/pages/saved.txt:12`: `IconButton "menu" tooltip="Open navigation" show=phone onTap={open savedNav}   ||   Row gap=10 hide=phone`
- `story-reader/2-write-repair/pages/search.txt:13`: `IconButton "menu" tooltip="Open navigation" show=phone onTap={open searchNav}   ||   Row gap=10 hide=phone`
- `story-reader/2-write-repair/pages/settings.txt:11`: `IconButton "menu" tooltip="Open navigation" show=phone onTap={open settingsNav}   ||   Row gap=10 hide=phone`
- `story-reader/2-write-repair/pages/story.txt:16`: `IconButton "menu" tooltip="Open navigation" show=phone onTap={open storyNav}   ||   Row gap=10 hide=phone`
- `story-reader/2-write-repair/pages/today.txt:19`: `IconButton "menu" tooltip="Open navigation" show=phone onTap={open todayNav}   ||   Row gap=10 hide=phone`
- `story-reader/2-write-repair/pages/today.txt:47`: `Column w=fill gap=9 pad=[22,22,25,20] show=phone   ||   Box w=fill h=866 show=tablet hide=phone`
- `team-chat/2-write-repair/pages/conversations.txt:19`: `Icon "forum" color=violet show=phone   ||   Text " /  Studio North" size=13 color=quiet hide=phone`
- `travel-guide/2-write-repair/pages/city.txt:19`: `Nav sticky show=phone fill=#FFFAF6ED border-bottom=#FFD7CDB9   ||   Nav sticky hide=phone fill=#FFFAF6ED border-bottom=#FFD7CDB9`
- `admin-console/3-write-desk/pages/member.txt:31`: `Column pad=16 gap=12 show=phone   ||   Column pad=24 gap=16 hide=phone`
- `calendar-app/3-write-desk/pages/month.txt:69`: `Box h=6 w=6 radius=3 fill=#FF286766 show=phone   ||   Badge.primary "Today" hide=phone`
- `clip-editor/3-write-desk/pages/studio.txt:93`: `Toolbar show=tablet   ||   Row gap=12 top hide=tablet`
- `flashcards/3-write-desk/pages/study.txt:41`: `Text.caption "Tap to reveal" show=phone   ||   Row gap=6 middle hide=phone`
- `kanban-board/3-write-desk/pages/archive.txt:12`: `Brand "Stack" icon="view_kanban" show=phone   ||   Text.barTitle "Product delivery" hide=phone`
- `kanban-board/3-write-desk/pages/board.txt:17`: `Brand "Stack" icon="view_kanban" show=phone   ||   Text.barTitle "Product delivery" hide=phone`
- `kanban-board/3-write-desk/pages/list.txt:18`: `Brand "Stack" icon="view_kanban" show=phone   ||   Text.barTitle "Product delivery" hide=phone`
- `meal-planner/3-write-desk/pages/week.txt:23`: `Row show=phone between middle   ||   Grid cols=7 keep gap=8 hide=phone`
- `meal-planner/3-write-desk/pages/week.txt:33`: `Column show=phone gap=8   ||   Grid cols=7 keep gap=8 hide=phone`
- `music-player/3-write-desk/pages/player.txt:19`: `Column show=phone gap=16   ||   Row gap=42 top hide=phone`
- `music-player/3-write-desk/components/PlayerBar.txt:23`: `Column gap=3 show=phone   ||   Row gap=16 middle hide=phone`
- `notes-app/3-write-desk/pages/workspace.txt:34`: `PhoneNotebooks show=phone visible={mobilePane=="books"} selected={bookId} onPick={bookId=result; mobilePane="list"; selected=[]} onTags={go tags} onTrash={go trash} onSettings={go settings} onFind={q=`
- `notes-app/3-write-desk/pages/workspace.txt:46`: `Main show=phone visible={mobilePane=="list"}   ||   Sidebar w={railWidth} hide=phone`
- `notes-app/3-write-desk/pages/workspace.txt:52`: `Main show=phone visible={mobilePane=="note"}   ||   Sidebar w={railWidth} hide=phone`
- `scrolly-story/3-write-desk/pages/glacier-lines.txt:42`: `Column grow show=phone sticky gap=8   ||   Column grow sticky hide=phone gap=12`
- `scrolly-story/3-write-desk/pages/glacier-lines.txt:67`: `Column grow sticky show=phone gap=8   ||   Column grow sticky hide=phone gap=12`
- `scrolly-story/3-write-desk/pages/glacier-lines.txt:92`: `Column grow sticky show=phone gap=8   ||   Column grow sticky hide=phone gap=12`
- `scrolly-story/3-write-desk/pages/glacier-lines.txt:117`: `Column grow sticky show=phone gap=8   ||   Column grow sticky hide=phone gap=12`
- `scrolly-story/3-write-desk/pages/glacier-lines.txt:144`: `Column grow sticky show=phone gap=8   ||   Column grow sticky hide=phone gap=10`
- `scrolly-story/3-write-desk/pages/glacier-lines.txt:260`: `Row show=phone gap=10   ||   Column gap=4 hide=phone`
- `story-reader/3-write-desk/pages/today.txt:32`: `Column grow gap=8 pad=[10,8,10,8] show=phone   ||   Column grow gap=12 pad=[24,12,24,12] hide=phone`
- `story-reader/3-write-desk/components/Dispatch.txt:7`: `IconButton "view_day" tooltip="Today" show=phone selected={current=="Today"} onTap={go today}   ||   Link "Today" hide=phone onTap={go today}`
- `story-reader/3-write-desk/components/Dispatch.txt:8`: `IconButton "bookmark_border" tooltip="Saved" show=phone selected={current=="Saved"} onTap={go saved}   ||   Link "Today" hide=phone onTap={go today}`
- `story-reader/3-write-desk/components/Dispatch.txt:9`: `IconButton "search" tooltip="Search" show=phone selected={current=="Search"} onTap={go search}   ||   Link "Today" hide=phone onTap={go today}`
- `story-reader/3-write-desk/components/Dispatch.txt:10`: `IconButton "settings" tooltip="Settings" show=phone selected={current=="Settings"} onTap={go settings}   ||   Link "Today" hide=phone onTap={go today}`

### all twins (201)

- `calendar-app/1-write/pages/agenda.txt:49`: `Text "Margin" size=17 weight=700 color=ink show=phone   ||   Text "Workspace" size=12 weight=600 color=quiet hide=phone`
- `calendar-app/1-write/pages/agenda.txt:61`: `Text "{dates[selected].month}" size=21 weight=700 color=ink show=phone   ||   Text "{dates[selected].month}" size=29 weight=700 color=ink hide=phone`
- `calendar-app/1-write/pages/calendars.txt:49`: `Text "Margin" size=17 weight=700 color=ink show=phone   ||   Text "Workspace" size=12 weight=600 color=quiet hide=phone`
- `calendar-app/1-write/pages/day.txt:49`: `Text "Margin" size=17 weight=700 color=ink show=phone   ||   Text "Workspace" size=12 weight=600 color=quiet hide=phone`
- `calendar-app/1-write/pages/day.txt:61`: `Text "{dates[selected].full}" size=21 weight=700 color=ink show=phone   ||   Text "{dates[selected].full}" size=29 weight=700 color=ink hide=phone`
- `calendar-app/1-write/pages/month.txt:50`: `Text "Margin" size=17 weight=700 color=ink show=phone   ||   Text "Workspace" size=12 weight=600 color=quiet hide=phone`
- `calendar-app/1-write/pages/month.txt:62`: `Text "{dates[selected].month}" size=21 weight=700 color=ink show=phone   ||   Text "{dates[selected].month}" size=29 weight=700 color=ink hide=phone`
- `calendar-app/1-write/pages/month.txt:88`: `Column h=76 fill={date.first==dates[selected].first ? white : wash} pad=[3,5,3,4] gap=4 show=phone onTap={selected=date.id; view="day"; go day}   ||   Column h=108 fill={date.first==dates[selected].fi`
- `calendar-app/1-write/pages/search.txt:49`: `Text "Margin" size=17 weight=700 color=ink show=phone   ||   Text "Workspace" size=12 weight=600 color=quiet hide=phone`
- `calendar-app/1-write/pages/week.txt:49`: `Text "Margin" size=17 weight=700 color=ink show=phone   ||   Text "Workspace" size=12 weight=600 color=quiet hide=phone`
- `calendar-app/1-write/pages/week.txt:61`: `Text "{dates[selected].month}" size=21 weight=700 color=ink show=phone   ||   Text "{dates[selected].month}" size=29 weight=700 color=ink hide=phone`
- `calendar-app/1-write/pages/week.txt:78`: `Text "{date.weekday}" size=8 weight=700 color=quiet show=phone center   ||   Text "{date.weekday}" size=10 weight=700 color=quiet hide=phone center`
- `calendar-app/1-write/pages/week.txt:97`: `Column scroll h=530 show=phone   ||   Column scroll h=570 hide=phone`
- `clip-editor/1-write/pages/timeline.txt:90`: `Column w=66 gap=1 show=phone   ||   Column w=154 gap=1 hide=phone`
- `clip-editor/1-write/pages/timeline.txt:96`: `TimelineCanvas grow show=phone clips={clips} markers={markers} tracks={tracks} selected={selected} head={playhead} zoom={zoom} loop={loop} loopStart={loopStart} loopEnd={loopEnd} active={activeTrack} `
- `conference/1-write/pages/home.txt:10`: `Text "NORTHLIGHT" size=55 weight=900 color=#FFE9FCF6 show=tablet hide=phone   ||   Text "NORTHLIGHT" size=66 weight=900 color=#FFE9FCF6 hide=tablet`
- `conference/1-write/pages/home.txt:11`: `Text "NORTHLIGHT" size=42 weight=900 color=#FFE9FCF6 show=phone   ||   Text "NORTHLIGHT" size=55 weight=900 color=#FFE9FCF6 show=tablet hide=phone`
- `conference/1-write/pages/schedule.txt:42`: `Column gap=12 show=phone   ||   Column gap=12 hide=phone`
- `docs-site/1-write/pages/landing.txt:21`: `Text "Text diffs that read like text." size=42 weight=700 color={dark ? "#FFF1F4FF" : "#FF172034"} show=tablet hide=phone   ||   Text "Text diffs that read like text." size=58 weight=700 color={dark ?`
- `docs-site/1-write/pages/landing.txt:22`: `Text "Text diffs that read like text." size=35 weight=700 color={dark ? "#FFF1F4FF" : "#FF172034"} show=phone   ||   Text "Text diffs that read like text." size=42 weight=700 color={dark ? "#FFF1F4FF"`
- `kanban-board/1-write/pages/board.txt:82`: `Column scroll gap=8 h=270 show=phone   ||   Column scroll gap=8 h=400 hide=phone`
- `magazine/1-write/pages/about.txt:7`: `Headline "At the water’s edge" size=40 show=tablet   ||   Headline "At the water’s edge" size=58 hide=tablet`
- `magazine/1-write/pages/about.txt:15`: `Figure "The last light on an outgoing tide." palette=deep height=156 show=phone   ||   Figure "The last light on an outgoing tide. Illustration by The Long Tide." palette=deep height=234 hide=phone`
- `magazine/1-write/pages/article.txt:11`: `Headline "The marsh that moved inland" size=41 show=tablet   ||   Headline "The marsh that moved inland" size=58 hide=tablet`
- `magazine/1-write/pages/article.txt:18`: `Figure "A late-autumn tide over the flats at the head of the Bay of Fundy." height=184 show=phone   ||   Figure "A late-autumn tide over the flats at the head of the Bay of Fundy. Illustration by The `
- `magazine/1-write/pages/article.txt:28`: `Figure "At the breach, each incoming tide leaves a new edge in the mud." palette=dune height=158 show=phone   ||   Figure "At the breach, each incoming tide leaves a new edge in the mud." palette=dune`
- `magazine/1-write/pages/article.txt:45`: `Headline "{story.title}" size=40 show=tablet   ||   Headline "{story.title}" size=56 hide=tablet`
- `magazine/1-write/pages/article.txt:50`: `Figure "{story.caption}" palette={story.palette} height=176 show=phone   ||   Figure "{story.caption}" palette={story.palette} height=280 hide=phone`
- `magazine/1-write/pages/author.txt:11`: `Headline "Mara Vale" size=42 show=tablet   ||   Headline "Mara Vale" size=56 hide=tablet`
- `magazine/1-write/pages/front.txt:16`: `Headline "The marsh that moved inland" size=40 show=tablet   ||   Headline "The marsh that moved inland" size=56 hide=tablet`
- `magazine/1-write/pages/front.txt:22`: `Figure "The upper Bay of Fundy at low water." height=178 show=phone   ||   Figure "The upper Bay of Fundy at low water. Illustration by The Long Tide." height=326 hide=phone`
- `magazine/1-write/pages/front.txt:35`: `Column gap=22 show=phone   ||   Grid cols=3 gap=24 hide=phone`
- `magazine/1-write/pages/search.txt:8`: `Headline "Search the magazine" size=38 show=tablet   ||   Headline "Search the magazine" size=53 hide=tablet`
- `magazine/1-write/pages/section.txt:7`: `Headline "Coasts" size=46 show=tablet   ||   Headline "Coasts" size=62 hide=tablet`
- `mail-client/1-write/pages/mailbox.txt:55`: `Column gap=0 visible={phonePane=="list"} show=phone   ||   Column gap=0 hide=phone`
- `meal-planner/1-write/pages/week.txt:20`: `Row between middle show=phone   ||   Grid cols=7 keep gap=6 hide=phone`
- `meal-planner/1-write/pages/week.txt:32`: `Column gap=8 show=phone   ||   Grid cols=7 keep gap=6 hide=phone`
- `money-tracker/1-write/pages/home.txt:19`: `Button "Add" show=phone onTap={open homeAddSheet}   ||   Button "Add transaction" hide=phone onTap={open homeAddDialog}`
- `money-tracker/1-write/pages/transactions.txt:27`: `Button "Add" show=phone onTap={open listAddSheet}   ||   Button "Add transaction" hide=phone onTap={open listAddDialog}`
- `music-player/1-write/pages/player.txt:26`: `Stack w=fill h=204 radius=22 fill=#FF35281B center middle show=phone   ||   Stack w=fill h=284 radius=22 fill=#FF35281B center middle hide=phone`
- `music-player/1-write/components/NowBar.txt:17`: `Column show=phone w=fill gap=0 pad=[10,3,10,5]   ||   Row gap=18 middle pad=[18,9,18,9] hide=phone`
- `photo-library/1-write/pages/photos.txt:26`: `Grid cols={gridSize==0 ? 7 : gridSize==1 ? 5 : 3} gap=4 show=tablet hide=phone   ||   Grid cols={gridSize==0 ? 9 : gridSize==1 ? 6 : 4} gap=4 hide=tablet`
- `photo-library/1-write/pages/photos.txt:28`: `Grid cols={gridSize==0 ? 5 : gridSize==1 ? 3 : 2} gap=4 show=phone   ||   Grid cols={gridSize==0 ? 7 : gridSize==1 ? 5 : 3} gap=4 show=tablet hide=phone`
- `photo-library/1-write/pages/photos.txt:39`: `IconButton "playlist_add" tooltip="Add to album" onTap={targetAlbum=""; open addSelection} show=phone   ||   Button.outline "Add to album" onTap={targetAlbum=""; open addSelection} hide=phone`
- `photo-library/1-write/components/ViewerBody.txt:53`: `Stack h=420 show=tablet hide=phone fill=#FF272725 clip=true onSwipeLeft={onNext} onSwipeRight={onPrevious} onSwipeDown={onDismiss} onEscape={onDismiss} onArrowLeft={onPrevious} onArrowRight={onNext} o`
- `photo-library/1-write/components/ViewerBody.txt:55`: `Stack h=280 show=phone fill=#FF272725 clip=true onSwipeLeft={onNext} onSwipeRight={onPrevious} onSwipeDown={onDismiss} onEscape={onDismiss} onArrowLeft={onPrevious} onArrowRight={onNext} onPinch={view`
- `property-listings/1-write/pages/listing.txt:29`: `PropertyScene kind={home.scene} sky={home.sky} wall={home.wall} h=208 show=phone   ||   PropertyScene kind={home.scene} sky={home.sky} wall={home.wall} h=352 hide=phone`
- `restaurant/1-write/pages/home.txt:16`: `Column gap=16 pad=24 show=phone   ||   Column gap=22 pad=[76,32,28,32] hide=phone`
- `restaurant/1-write/components/Brasa.txt:52`: `Stack w=304 middle center show=tablet   ||   Stack w=690 middle center hide=tablet`
- `saas-landing/1-write/pages/home.txt:12`: `Text.heading1 "Resolve incidents before they spread." color=#FFF3F5F7 size=43 weight=760 show=phone   ||   Text.heading1 "Resolve incidents before they spread." color=#FFF3F5F7 size=61 weight=760 hide`
- `saas-landing/1-write/pages/home.txt:46`: `Column grow show=phone   ||   Column grow hide=phone`
- `saas-landing/1-write/components/Relay.txt:10`: `Link "Contact sales" show=phone onTap={go contact}   ||   Button.primary "Contact sales" hide=phone onTap={go contact}`
- `scrolly-story/1-write/pages/glacier-lines.txt:40`: `Text.pageTitle "Glacier Lines" show=phone size=55 weight=600 color=#FFFBFAF5 fontFamily="Georgia"   ||   Text.pageTitle "Glacier Lines" hide=phone size=106 weight=600 color=#FFFBFAF5 fontFamily="Georg`
- `seat-booking/1-write/pages/production.txt:12`: `Poster "{show.title}" artwork={show.artwork} h=235 show=phone   ||   Poster "{show.title}" artwork={show.artwork} h=325 hide=phone`
- `seat-booking/1-write/pages/production.txt:16`: `Text "{show.title}" style=display color=#FFFFEAD3 size=32 weight=700 show=phone   ||   Text "{show.title}" style=display color=#FFFFEAD3 size=44 weight=700 hide=phone`
- `seat-booking/1-write/pages/seats.txt:19`: `Text "Choose your seats" style=display color=#FFFFEAD3 size=30 weight=700 show=phone   ||   Text "Choose your seats" style=display color=#FFFFEAD3 size=40 weight=700 hide=phone`
- `seat-booking/1-write/pages/seats.txt:45`: `Row middle gap=8 show=phone   ||   Text "Use arrow keys to move and Enter to select." center color=#FFC5AEC1 size=11 hide=phone`
- `seat-booking/1-write/pages/tickets.txt:10`: `Text "You're on the list." style=display color=#FFFFEAD3 size=34 weight=700 show=phone   ||   Text "You're on the list." style=display color=#FFFFEAD3 size=50 weight=700 hide=phone`
- `seat-booking/1-write/pages/whats-on.txt:10`: `Text "A night worth dressing up for." style=display color=#FFFFEAD3 size=38 weight=700 show=phone   ||   Text "A night worth dressing up for." style=display color=#FFFFEAD3 size=58 weight=700 hide=pho`
- `spreadsheet/1-write/pages/sheet.txt:54`: `Row middle gap=2 pad=[7,4,7,4] fill=toolbar border-bottom=line show=phone   ||   Row middle gap=6 pad=[14,6,14,6] fill=toolbar border-bottom=line hide=phone`
- `spreadsheet/1-write/pages/sheet.txt:88`: `Text.caption "{letters[min(col,anchorCol)]}{min(row,anchorRow)}" color=muted show=phone   ||   Text.caption "Selection" color=muted hide=phone`
- `storefront/1-write/pages/collection.txt:9`: `Text.heading1 "The kitchen collection" size=35 weight=600 color=forest show=phone   ||   Text.heading1 "The kitchen collection" size=48 weight=600 color=forest hide=phone`
- `storefront/1-write/pages/home.txt:9`: `Text.heading1 "Good things for the everyday table" size=40 weight=600 color=forest show=tablet   ||   Text.heading1 "Good things for the everyday table" size=57 weight=600 color=forest hide=tablet`
- `storefront/1-write/pages/home.txt:16`: `KitchenStill kind=shelf tone=#FF566B4D backdrop=#FFDDC5A9 height=235 show=phone   ||   KitchenStill kind=shelf tone=#FF566B4D backdrop=#FFDDC5A9 height=375 hide=phone`
- `storefront/1-write/pages/journal.txt:9`: `Text.heading1 "The journal" size=37 color=forest show=phone   ||   Text.heading1 "The journal" size=49 color=forest hide=phone`
- `storefront/1-write/pages/product.txt:17`: `KitchenStill kind={item.kind} tone={item.finishes[variant].tone} backdrop={item.backdrop} height=255 angle={angle} show=phone   ||   KitchenStill kind={item.kind} tone={item.finishes[variant].tone} ba`
- `story-reader/1-write/pages/story.txt:19`: `Text "{item.headline}" size=34 weight=900 color=ink show=phone   ||   Text "{item.headline}" size=52 weight=900 color=ink maxw=820 hide=phone`
- `story-reader/1-write/components/Dispatch.txt:24`: `DrawnScene scene={scene} tint={tint} accent={accent} h=290 show=tablet hide=phone   ||   DrawnScene scene={scene} tint={tint} accent={accent} h=300 hide=tablet`
- `story-reader/1-write/components/Dispatch.txt:25`: `DrawnScene scene={scene} tint={tint} accent={accent} h=205 show=phone   ||   DrawnScene scene={scene} tint={tint} accent={accent} h=290 show=tablet hide=phone`
- `studio-portfolio/1-write/pages/contact.txt:19`: `Text "LET'S TALK." size=86 weight=900 color=ink show=tablet hide=phone   ||   Text "LET'S TALK." size=152 weight=900 color=ink hide=tablet`
- `studio-portfolio/1-write/pages/contact.txt:20`: `Text "LET'S TALK." size=57 weight=900 color=ink show=phone   ||   Text "LET'S TALK." size=86 weight=900 color=ink show=tablet hide=phone`
- `studio-portfolio/1-write/pages/home.txt:21`: `Text "ODD HOURS." size=110 weight=900 color=ink show=tablet hide=phone   ||   Text "ODD" size=218 weight=900 color=ink hide=tablet`
- `studio-portfolio/1-write/pages/home.txt:22`: `Text "ODD" size=91 weight=900 color=ink show=phone   ||   Text "ODD HOURS." size=110 weight=900 color=ink show=tablet hide=phone`
- `studio-portfolio/1-write/pages/home.txt:23`: `Text "HOURS." size=88 weight=900 color=ink show=phone   ||   Text "ODD HOURS." size=110 weight=900 color=ink show=tablet hide=phone`
- `studio-portfolio/1-write/pages/project.txt:16`: `Text "{projects[activeProject].title}" size=65 weight=900 color=ink show=tablet hide=phone   ||   Text "{projects[activeProject].title}" size=112 weight=900 color=ink hide=tablet`
- `studio-portfolio/1-write/pages/project.txt:17`: `Text "{projects[activeProject].title}" size=46 weight=900 color=ink show=phone   ||   Text "{projects[activeProject].title}" size=65 weight=900 color=ink show=tablet hide=phone`
- `studio-portfolio/1-write/pages/project.txt:21`: `ArtPanel "{projects[activeProject].mark}" tone={projects[activeProject].tone} detail={projects[activeProject].graphic} h=385 show=tablet hide=phone   ||   ArtPanel "{projects[activeProject].mark}" ton`
- `studio-portfolio/1-write/pages/project.txt:22`: `ArtPanel "{projects[activeProject].mark}" tone={projects[activeProject].tone} detail={projects[activeProject].graphic} h=260 show=phone   ||   ArtPanel "{projects[activeProject].mark}" tone={projects[`
- `studio-portfolio/1-write/pages/studio.txt:14`: `Text "SMALL CREW." size=67 weight=900 color=ink show=tablet hide=phone   ||   Text "SMALL CREW." size=126 weight=900 color=ink hide=tablet`
- `studio-portfolio/1-write/pages/studio.txt:15`: `Text "BIG FEELINGS." size=67 weight=900 color=ink show=tablet hide=phone   ||   Text "SMALL CREW." size=126 weight=900 color=ink hide=tablet`
- `studio-portfolio/1-write/pages/studio.txt:16`: `Text "SMALL CREW. BIG FEELINGS." size=57 weight=900 color=ink show=phone   ||   Text "SMALL CREW." size=67 weight=900 color=ink show=tablet hide=phone`
- `studio-portfolio/1-write/pages/work.txt:14`: `Text "WORK." size=92 weight=900 color=ink show=tablet hide=phone   ||   Text "WORK." size=180 weight=900 color=ink hide=tablet`
- `studio-portfolio/1-write/pages/work.txt:15`: `Text "WORK." size=69 weight=900 color=ink show=phone   ||   Text "WORK." size=92 weight=900 color=ink show=tablet hide=phone`
- `studio-portfolio/1-write/pages/work.txt:33`: `Column gap=28 show=phone   ||   Row gap=24 top hide=phone`
- `team-chat/1-write/pages/thread.txt:47`: `IconButton "info_outline" tooltip="Conversation details" show=tablet onTap={sheetStop=0; open threadDetails}   ||   IconButton "info_outline" tooltip="Conversation details" hide=tablet onTap={desktopD`
- `travel-guide/1-write/pages/explore.txt:16`: `Text "Find your line" size=39 weight=800 color=#FF233B31 show=phone   ||   Text "Find your line" size=53 weight=800 color=#FF233B31 hide=phone`
- `travel-guide/1-write/pages/home.txt:18`: `Text "Europe at window speed." size=47 weight=800 color=#FF233B31 show=tablet hide=phone   ||   Text "Europe at\nwindow speed." size=63 weight=800 color=#FF233B31 hide=tablet`
- `travel-guide/1-write/pages/home.txt:19`: `Text "Europe at window speed." size=38 weight=800 color=#FF233B31 show=phone   ||   Text "Europe at window speed." size=47 weight=800 color=#FF233B31 show=tablet hide=phone`
- `travel-guide/1-write/pages/journal.txt:15`: `Text "Notes from the line" size=38 weight=800 color=#FF233B31 show=phone   ||   Text "Notes from the line" size=50 weight=800 color=#FF233B31 hide=phone`
- `travel-guide/1-write/pages/newsletter.txt:19`: `Text "A postcard from the railway" size=37 weight=800 color=#FF233B31 show=phone   ||   Text "A postcard from\nthe railway" size=51 weight=800 color=#FF233B31 hide=phone`
- `travel-guide/1-write/pages/planner.txt:14`: `Text "Build your journey" size=36 weight=800 color=#FF233B31 show=phone   ||   Text "Build your journey" size=49 weight=800 color=#FF233B31 hide=phone`
- `travel-guide/1-write/pages/route.txt:20`: `Text "{trip.name}" size=36 weight=800 color=#FF233B31 show=phone   ||   Text "{trip.name}" size=48 weight=800 color=#FF233B31 hide=phone`
- `workout-tracker/1-write/pages/today.txt:19`: `Text "{plans[0].days[0].name}" size=28 weight=900 color=#FFF5F6F0 show=phone   ||   Text "{plans[0].days[0].name}" size=43 weight=900 color=#FFF5F6F0 hide=phone`
- `admin-console/2-write-repair/pages/audit.txt:23`: `Column show=phone gap=8   ||   Row middle gap=8 hide=phone`
- `calendar-app/2-write-repair/pages/agenda.txt:33`: `IconButton "add" tooltip="New event" onTap={editing=""; draftTitle=""; draftCalendar="Studio"; draftStart=dates[active].date; draftEnd=dates[active].date; draftStartTime="09:00"; draftEndTime="10:00";`
- `calendar-app/2-write-repair/pages/calendars.txt:33`: `IconButton "add" tooltip="New event" onTap={editing=""; draftTitle=""; draftCalendar="Studio"; draftStart=dates[active].date; draftEnd=dates[active].date; draftStartTime="09:00"; draftEndTime="10:00";`
- `calendar-app/2-write-repair/pages/day.txt:33`: `IconButton "add" tooltip="New event" onTap={editing=""; draftTitle=""; draftCalendar="Studio"; draftStart=dates[active].date; draftEnd=dates[active].date; draftStartTime="09:00"; draftEndTime="10:00";`
- `calendar-app/2-write-repair/pages/day.txt:39`: `Text.pageTitle "{dates[active].short}" show=phone   ||   Text.pageTitle "{dates[active].label}" hide=phone`
- `calendar-app/2-write-repair/pages/month.txt:33`: `IconButton "add" tooltip="New event" onTap={editing=""; draftTitle=""; draftCalendar="Studio"; draftStart=dates[active].date; draftEnd=dates[active].date; draftStartTime="09:00"; draftEndTime="10:00";`
- `calendar-app/2-write-repair/pages/month.txt:59`: `Box h=55 show=phone pad=[2,4,2,3] border-top=rule border-right=rule fill={d.date==dates[active].date ? "#FFF4F6FF" : "#FFFFFFFF"} onTap={active=indexOf(map(dates,x=>x.date),d.date); chosenView="Day"; `
- `calendar-app/2-write-repair/pages/search.txt:34`: `IconButton "add" tooltip="New event" onTap={editing=""; draftTitle=""; draftCalendar="Studio"; draftStart=dates[active].date; draftEnd=dates[active].date; draftStartTime="09:00"; draftEndTime="10:00";`
- `calendar-app/2-write-repair/pages/week.txt:33`: `IconButton "add" tooltip="New event" onTap={editing=""; draftTitle=""; draftCalendar="Studio"; draftStart=dates[active].date; draftEnd=dates[active].date; draftStartTime="09:00"; draftEndTime="10:00";`
- `calendar-app/2-write-repair/components/Calendar.txt:39`: `Text "{title}" size=9 weight=700 color={find(calendars,c=>c.name==calendar).ink} maxLines={height>=34 ? 2 : 1} overflow=ellipsis show=phone   ||   Text "{title}" size=11 weight=700 color={find(calenda`
- `clip-editor/2-write-repair/pages/editor.txt:69`: `IconButton "keyboard" tooltip="Keyboard shortcuts" onTap={open shortcuts} show=phone   ||   Text.mono "/ 03:12" color=#FF9CA8BA hide=phone`
- `clip-editor/2-write-repair/pages/editor.txt:89`: `Column w=92 fill=#FF242933 show=phone   ||   Column w=150 fill=#FF242933 hide=phone`
- `clip-editor/2-write-repair/pages/editor.txt:103`: `Column w={max(450,zoom*620)} gap=0 show=phone   ||   Column w={max(700,zoom*952)} gap=0 hide=phone`
- `conference/2-write-repair/pages/home.txt:18`: `Column show=phone   ||   Column hide=phone`
- `conference/2-write-repair/pages/schedule.txt:41`: `Column gap=9 show=phone   ||   Column gap=8 hide=phone`
- `food-ordering/2-write-repair/pages/restaurant.txt:21`: `IconButton "more_horiz" show=phone tooltip="Open navigation" onTap={open restaurantNavigation}   ||   Row gap=14 hide=phone`
- `food-ordering/2-write-repair/pages/restaurant.txt:99`: `Box w=96 show=phone onTap={onPhone}   ||   Box w=152 hide=phone onTap={onDesktop}`
- `food-ordering/2-write-repair/pages/restaurant.txt:107`: `Button.outline "Add" show=phone onTap={onPhone}   ||   Button.outline "Add" hide=phone onTap={onDesktop}`
- `magazine/2-write-repair/pages/article.txt:11`: `BookTitle "{stories[storyIndex].title}" size=45 show=phone   ||   BookTitle "{stories[storyIndex].title}" size=61 hide=phone`
- `magazine/2-write-repair/pages/article.txt:20`: `CoastalArt height=195 sky=#FFACC5C5 water=#FF4A7A82 land=#FF213E4B foam=#FFE8E6C7 sun=#FFF1DCAB show=phone   ||   CoastalArt height=308 sky=#FFACC5C5 water=#FF4A7A82 land=#FF213E4B foam=#FFE8E6C7 sun=`
- `magazine/2-write-repair/pages/front.txt:16`: `BookTitle "The marsh remembers" size=47 show=phone   ||   BookTitle "The marsh remembers" size=64 hide=phone`
- `meal-planner/2-write-repair/pages/week.txt:30`: `Column show=phone gap=8   ||   Grid cols=7 keep gap=5 hide=phone`
- `music-player/2-write-repair/pages/album.txt:14`: `CoverArt "{a.mark}" tone={a.tone} shade={a.shade} edge=96 show=phone   ||   CoverArt "{a.mark}" tone={a.tone} shade={a.shade} edge=176 hide=phone`
- `music-player/2-write-repair/pages/album.txt:18`: `Text "{a.title}" color=#FFFFEFDE size=23 weight=800 show=phone   ||   Text "{a.title}" color=#FFFFEFDE size=40 weight=800 hide=phone`
- `music-player/2-write-repair/pages/player.txt:10`: `PlayerSheet @stop start="mini" end="full" show=phone onChange={stop=result}   ||   Column hide=phone`
- `music-player/2-write-repair/pages/player.txt:16`: `CoverArt "{track.mark}" tone={track.tone} shade={track.shade} edge=190 show=phone   ||   CoverArt "{track.mark}" tone={track.tone} shade={track.shade} edge=282 hide=phone`
- `music-player/2-write-repair/components/Halftone.txt:25`: `CoverArt "{mark}" tone={tone} shade={shade} edge=118 show=tablet   ||   CoverArt "{mark}" tone={tone} shade={shade} edge=152 hide=tablet`
- `notes-app/2-write-repair/pages/tags.txt:23`: `Column gap=16 show=tablet   ||   Row gap=18 top hide=tablet`
- `notes-app/2-write-repair/pages/workspace.txt:51`: `IconButton "search" tooltip="Search" show=phone onTap={query=""; cursor=0; open command}   ||   Button.ghost "Search  ⌘ K" hide=phone onTap={query=""; cursor=0; open command}`
- `photo-library/2-write-repair/pages/edit.txt:37`: `AdjustedPhoto src={photos[viewIndex].url} h=401 light={light} contrast={contrast} warmth={warmth} crop={crop} before={before} split={split} show=tablet hide=phone   ||   AdjustedPhoto src={photos[view`
- `photo-library/2-write-repair/pages/edit.txt:38`: `AdjustedPhoto src={photos[viewIndex].url} h=248 light={light} contrast={contrast} warmth={warmth} crop={crop} before={before} split={split} show=phone   ||   AdjustedPhoto src={photos[viewIndex].url} `
- `photo-library/2-write-repair/pages/photos.txt:31`: `Row gap=4 middle show=phone   ||   Row gap=4 middle hide=phone`
- `photo-library/2-write-repair/pages/search.txt:41`: `Column gap=7 show=phone   ||   Grid cols=5 gap=5 hide=phone`
- `photo-library/2-write-repair/pages/search.txt:68`: `Grid cols=3 gap=5 show=phone   ||   Grid cols=5 gap=5 hide=phone`
- `photo-library/2-write-repair/pages/viewer.txt:40`: `Column show=tablet hide=phone   ||   Column hide=tablet`
- `photo-library/2-write-repair/pages/viewer.txt:44`: `Column show=phone   ||   Column show=tablet hide=phone`
- `restaurant/2-write-repair/pages/home.txt:27`: `Stack w=fill h=510 show=phone fill=#FF2E1B13   ||   Stack w=fill h=580 hide=phone fill=#FF2E1B13`
- `scrolly-story/2-write-repair/pages/glacier-lines.txt:34`: `Stack h=884 show=tablet hide=phone center middle fill=#FF193744   ||   Stack h=896 hide=tablet center middle fill=#FF193744`
- `scrolly-story/2-write-repair/pages/glacier-lines.txt:41`: `Stack h=760 show=phone center middle fill=#FF193744   ||   Stack h=884 show=tablet hide=phone center middle fill=#FF193744`
- `scrolly-story/2-write-repair/pages/glacier-lines.txt:66`: `Column show=phone gap=12   ||   Row gap=44 top hide=phone`
- `scrolly-story/2-write-repair/components/Story.txt:5`: `Text "{title}" size=30 weight=600 color=#FF1E3542 font="Noto Serif" show=phone   ||   Text "{title}" size=42 weight=600 color=#FF1E3542 font="Noto Serif" hide=phone`
- `scrolly-story/2-write-repair/components/Story.txt:14`: `Spacer h=56 show=phone   ||   Spacer h=90 hide=phone`
- `seat-booking/2-write-repair/pages/seats.txt:38`: `Row show=phone gap=4 middle   ||   Text "Tab to the plan, then use arrow keys to move. Enter or Space selects a seat." hide=phone color=#FFCAB7C8 size=13`
- `seat-booking/2-write-repair/pages/seats.txt:47`: `Text "Pinch or use + and − to zoom. Drag the zoomed plan to pan." show=phone color=#FFCAB7C8 size=13   ||   Text "Tab to the plan, then use arrow keys to move. Enter or Space selects a seat." hide=pho`
- `spreadsheet/2-write-repair/pages/sheet.txt:67`: `Row gap=5 middle pad=[8,4,8,4] fill=#FFF7F9F8 border-bottom=#FFDEE5E0 show=phone   ||   Row gap=5 middle pad=[12,4,12,4] fill=#FFF7F9F8 border-bottom=#FFDEE5E0 hide=phone`
- `spreadsheet/2-write-repair/components/SheetGrid.txt:10`: `GridViewport letters={take(letters,dimensions[0])} rows={range(dimensions[1])} values={coalesce(workbook[active],seed)} widths={widths} region={region} query={query} firstWidth=144 otherWidth=104 body`
- `spreadsheet/2-write-repair/components/SheetGrid.txt:11`: `GridViewport letters={take(letters,dimensions[0])} rows={range(dimensions[1])} values={coalesce(workbook[active],seed)} widths={widths} region={region} query={query} firstWidth=108 otherWidth=78 bodyH`
- `storefront/2-write-repair/pages/home.txt:17`: `StillLife tone=#FFCCB190 clay=#FF9F5E48 form="bowl" height=190 show=phone   ||   StillLife tone=#FFCCB190 clay=#FF9F5E48 form="bowl" height=322 hide=phone`
- `storefront/2-write-repair/pages/product.txt:17`: `StillLife tone={view==1 ? '#FFDBC6AC' : (view==2 ? '#FFC5A590' : item.tone)} clay={finish=='Kiln dark' ? '#FF4B4D3B' : (finish=='Chalk' ? '#FFEEE0C4' : item.clay)} form={item.form} height=212 show=pho`
- `story-reader/2-write-repair/pages/saved.txt:12`: `IconButton "menu" tooltip="Open navigation" show=phone onTap={open savedNav}   ||   Row gap=10 hide=phone`
- `story-reader/2-write-repair/pages/search.txt:13`: `IconButton "menu" tooltip="Open navigation" show=phone onTap={open searchNav}   ||   Row gap=10 hide=phone`
- `story-reader/2-write-repair/pages/settings.txt:11`: `IconButton "menu" tooltip="Open navigation" show=phone onTap={open settingsNav}   ||   Row gap=10 hide=phone`
- `story-reader/2-write-repair/pages/story.txt:16`: `IconButton "menu" tooltip="Open navigation" show=phone onTap={open storyNav}   ||   Row gap=10 hide=phone`
- `story-reader/2-write-repair/pages/today.txt:19`: `IconButton "menu" tooltip="Open navigation" show=phone onTap={open todayNav}   ||   Row gap=10 hide=phone`
- `story-reader/2-write-repair/pages/today.txt:28`: `Box w=fill h=866 show=tablet hide=phone   ||   Box w=fill h=656 hide=tablet`
- `story-reader/2-write-repair/pages/today.txt:29`: `Box w=fill h=534 show=phone   ||   Box w=fill h=866 show=tablet hide=phone`
- `story-reader/2-write-repair/pages/today.txt:47`: `Column w=fill gap=9 pad=[22,22,25,20] show=phone   ||   Box w=fill h=866 show=tablet hide=phone`
- `studio-portfolio/2-write-repair/pages/contact.txt:14`: `Text "Say hello." size=97 weight=900 color=#FF191A15 show=tablet hide=phone   ||   Text "Say hello." size=146 weight=900 color=#FF191A15 hide=tablet`
- `studio-portfolio/2-write-repair/pages/contact.txt:15`: `Text "Say hello." size=65 weight=900 color=#FF191A15 show=phone   ||   Text "Say hello." size=97 weight=900 color=#FF191A15 show=tablet hide=phone`
- `studio-portfolio/2-write-repair/pages/home.txt:14`: `Text "ODD HOURS." size=96 weight=900 color=#FF191A15 show=tablet hide=phone   ||   Text "ODD HOURS." size=154 weight=900 color=#FF191A15 hide=tablet`
- `studio-portfolio/2-write-repair/pages/home.txt:15`: `Text "ODD" size=83 weight=900 color=#FF191A15 show=phone   ||   Text "ODD HOURS." size=96 weight=900 color=#FF191A15 show=tablet hide=phone`
- `studio-portfolio/2-write-repair/pages/home.txt:16`: `Text "HOURS." size=83 weight=900 color=#FF191A15 show=phone   ||   Text "ODD HOURS." size=96 weight=900 color=#FF191A15 show=tablet hide=phone`
- `studio-portfolio/2-write-repair/pages/project.txt:10`: `Text "{projects[current].name}" size=75 weight=900 color=#FF191A15 show=tablet hide=phone   ||   Text "{projects[current].name}" size=105 weight=900 color=#FF191A15 hide=tablet`
- `studio-portfolio/2-write-repair/pages/project.txt:11`: `Text "{projects[current].name}" size=49 weight=900 color=#FF191A15 show=phone   ||   Text "{projects[current].name}" size=75 weight=900 color=#FF191A15 show=tablet hide=phone`
- `studio-portfolio/2-write-repair/pages/studio.txt:8`: `Text "Odd together." size=79 weight=900 color=#FF191A15 show=tablet hide=phone   ||   Text "Odd together." size=123 weight=900 color=#FF191A15 hide=tablet`
- `studio-portfolio/2-write-repair/pages/studio.txt:9`: `Text "Odd together." size=64 weight=900 color=#FF191A15 show=phone   ||   Text "Odd together." size=79 weight=900 color=#FF191A15 show=tablet hide=phone`
- `studio-portfolio/2-write-repair/pages/work.txt:9`: `Text "Work." size=94 weight=900 color=#FF191A15 show=tablet hide=phone   ||   Text "Work." size=145 weight=900 color=#FF191A15 hide=tablet`
- `studio-portfolio/2-write-repair/pages/work.txt:10`: `Text "Work." size=76 weight=900 color=#FF191A15 show=phone   ||   Text "Work." size=94 weight=900 color=#FF191A15 show=tablet hide=phone`
- `studio-portfolio/2-write-repair/components/OddHours.txt:33`: `Text "PULSE." size=47 color=#FF191A15 weight=900 show=phone   ||   Text "PULSE." size=76 scaleDown=true color=#FF191A15 weight=900 hide=phone`
- `studio-portfolio/2-write-repair/components/OddHours.txt:43`: `Text "AFTER IMAGE" size=37 color=#FFF7F1DA weight=900 show=phone   ||   Text "AFTER" size=57 color=#FFF7F1DA weight=900 hide=phone`
- `studio-portfolio/2-write-repair/components/OddHours.txt:51`: `Text "FORM" size=42 color=#FF191A15 weight=900 show=phone   ||   Text "FORM" size=62 color=#FF191A15 weight=900 hide=phone`
- `team-chat/2-write-repair/pages/conversations.txt:19`: `Icon "forum" color=violet show=phone   ||   Text " /  Studio North" size=13 color=quiet hide=phone`
- `team-chat/2-write-repair/pages/thread.txt:58`: `IconButton "info_outline" tooltip="Conversation details" onTap={open detailsSheet} show=tablet   ||   IconButton "info_outline" tooltip="Conversation details" onTap={showDetails=!showDetails} hide=tab`
- `travel-guide/2-write-repair/pages/city.txt:19`: `Nav sticky show=phone fill=#FFFAF6ED border-bottom=#FFD7CDB9   ||   Nav sticky hide=phone fill=#FFFAF6ED border-bottom=#FFD7CDB9`
- `workout-tracker/2-write-repair/pages/today.txt:15`: `Text "Lower A" size=38 weight=900 color=#FFF7F8F0 show=phone   ||   Text "Lower A" size=52 weight=900 color=#FFF7F8F0 hide=phone`
- `admin-console/3-write-desk/pages/member.txt:31`: `Column pad=16 gap=12 show=phone   ||   Column pad=24 gap=16 hide=phone`
- `calendar-app/3-write-desk/pages/month.txt:69`: `Box h=6 w=6 radius=3 fill=#FF286766 show=phone   ||   Badge.primary "Today" hide=phone`
- `clip-editor/3-write-desk/pages/studio.txt:93`: `Toolbar show=tablet   ||   Row gap=12 top hide=tablet`
- `flashcards/3-write-desk/pages/study.txt:41`: `Text.caption "Tap to reveal" show=phone   ||   Row gap=6 middle hide=phone`
- `food-ordering/3-write-desk/pages/restaurant.txt:73`: `Button "Customize {dish.name}" show=phone onTap={close; open dishPeek}   ||   Button "Customize {dish.name}" hide=phone onTap={close; open dishDialog}`
- `kanban-board/3-write-desk/pages/archive.txt:12`: `Brand "Stack" icon="view_kanban" show=phone   ||   Text.barTitle "Product delivery" hide=phone`
- `kanban-board/3-write-desk/pages/board.txt:17`: `Brand "Stack" icon="view_kanban" show=phone   ||   Text.barTitle "Product delivery" hide=phone`
- `kanban-board/3-write-desk/pages/list.txt:18`: `Brand "Stack" icon="view_kanban" show=phone   ||   Text.barTitle "Product delivery" hide=phone`
- `meal-planner/3-write-desk/pages/week.txt:23`: `Row show=phone between middle   ||   Grid cols=7 keep gap=8 hide=phone`
- `meal-planner/3-write-desk/pages/week.txt:33`: `Column show=phone gap=8   ||   Grid cols=7 keep gap=8 hide=phone`
- `money-tracker/3-write-desk/pages/add-transaction.txt:25`: `Button.primary "Enter transaction" show=phone onTap={posted=coalesce(posted,today()); stop="Compact"; open addSheet}   ||   Button.primary "Enter transaction" hide=phone onTap={posted=coalesce(posted,`
- `music-player/3-write-desk/pages/player.txt:19`: `Column show=phone gap=16   ||   Row gap=42 top hide=phone`
- `music-player/3-write-desk/components/PlayerBar.txt:23`: `Column gap=3 show=phone   ||   Row gap=16 middle hide=phone`
- `notes-app/3-write-desk/pages/workspace.txt:34`: `PhoneNotebooks show=phone visible={mobilePane=="books"} selected={bookId} onPick={bookId=result; mobilePane="list"; selected=[]} onTags={go tags} onTrash={go trash} onSettings={go settings} onFind={q=`
- `notes-app/3-write-desk/pages/workspace.txt:46`: `Main show=phone visible={mobilePane=="list"}   ||   Sidebar w={railWidth} hide=phone`
- `notes-app/3-write-desk/pages/workspace.txt:52`: `Main show=phone visible={mobilePane=="note"}   ||   Sidebar w={railWidth} hide=phone`
- `photo-library/3-write-desk/pages/edit.txt:17`: `CompareSurface picture={find(photos,x=>x.id==currentId)} light={editLight} contrast={editContrast} warmth={editWarmth} crop={editCrop} split={compareAt} original={compareHeld} h=460 onSlide={compareAt`
- `photo-library/3-write-desk/pages/edit.txt:18`: `CompareSurface picture={find(photos,x=>x.id==currentId)} light={editLight} contrast={editContrast} warmth={editWarmth} crop={editCrop} split={compareAt} original={compareHeld} h=260 onSlide={compareAt`
- `photo-library/3-write-desk/pages/viewer.txt:23`: `PaintedPhoto picture={find(photos,x=>x.id==currentId)} light={coalesce(find(edits,x=>x.id==currentId).light,0)} contrast={coalesce(find(edits,x=>x.id==currentId).contrast,0)} warmth={coalesce(find(edi`
- `photo-library/3-write-desk/pages/viewer.txt:24`: `PaintedPhoto picture={find(photos,x=>x.id==currentId)} light={coalesce(find(edits,x=>x.id==currentId).light,0)} contrast={coalesce(find(edits,x=>x.id==currentId).contrast,0)} warmth={coalesce(find(edi`
- `scrolly-story/3-write-desk/pages/glacier-lines.txt:26`: `ParallaxLandscape offset={motion ? scrollY : 0} show=tablet compact=true   ||   ParallaxLandscape offset={motion ? scrollY : 0} hide=tablet`
- `scrolly-story/3-write-desk/pages/glacier-lines.txt:42`: `Column grow show=phone sticky gap=8   ||   Column grow sticky hide=phone gap=12`
- `scrolly-story/3-write-desk/pages/glacier-lines.txt:67`: `Column grow sticky show=phone gap=8   ||   Column grow sticky hide=phone gap=12`
- `scrolly-story/3-write-desk/pages/glacier-lines.txt:92`: `Column grow sticky show=phone gap=8   ||   Column grow sticky hide=phone gap=12`
- `scrolly-story/3-write-desk/pages/glacier-lines.txt:117`: `Column grow sticky show=phone gap=8   ||   Column grow sticky hide=phone gap=12`
- `scrolly-story/3-write-desk/pages/glacier-lines.txt:144`: `Column grow sticky show=phone gap=8   ||   Column grow sticky hide=phone gap=10`
- `scrolly-story/3-write-desk/pages/glacier-lines.txt:260`: `Row show=phone gap=10   ||   Column gap=4 hide=phone`
- `story-reader/3-write-desk/pages/today.txt:32`: `Column grow gap=8 pad=[10,8,10,8] show=phone   ||   Column grow gap=12 pad=[24,12,24,12] hide=phone`
- `story-reader/3-write-desk/components/Dispatch.txt:7`: `IconButton "view_day" tooltip="Today" show=phone selected={current=="Today"} onTap={go today}   ||   Link "Today" hide=phone onTap={go today}`
- `story-reader/3-write-desk/components/Dispatch.txt:8`: `IconButton "bookmark_border" tooltip="Saved" show=phone selected={current=="Saved"} onTap={go saved}   ||   Link "Today" hide=phone onTap={go today}`
- `story-reader/3-write-desk/components/Dispatch.txt:9`: `IconButton "search" tooltip="Search" show=phone selected={current=="Search"} onTap={go search}   ||   Link "Today" hide=phone onTap={go today}`
- `story-reader/3-write-desk/components/Dispatch.txt:10`: `IconButton "settings" tooltip="Settings" show=phone selected={current=="Settings"} onTap={go settings}   ||   Link "Today" hide=phone onTap={go today}`
- `team-chat/3-write-desk/pages/thread.txt:45`: `IconButton "info_outline" tooltip="Conversation details" show=tablet onTap={open detailsSheet}   ||   IconButton "info_outline" tooltip="Conversation details" hide=tablet onTap={detailsVisible=!detail`

## Web (arm 4-web: src/)

| | count |
|---|---|
| @media blocks about width | 231 |
| elements with a width-named class (mobile-nav, phone-only) | 37 |
| @media blocks not about width (motion, colour scheme, print) | 9 |
| a width read in script (matchMedia width, innerWidth <) | 1 |
| Tailwind width prefixes in markup (md:hidden …) | 1 |
| a component named by a width (MobileNav) | 0 |
| builds with a width @media | 30 of 30 |

### Declarations inside the width @media blocks

| kind | count |
|---|---|
| a value (size, padding, font, gap, colour …) | 2867 |
| arrangement (direction, wrap, grid, order, position) | 557 |
| display: other (a part shown, or its layout changed) | 129 |
| display: none (a part hidden) | 96 |

### The arrangement declarations, by property

| property | count |
|---|---|
| `grid-template-columns` | 235 |
| `position` | 47 |
| `right` | 43 |
| `flex-direction` | 35 |
| `left` | 32 |
| `bottom` | 31 |
| `top` | 29 |
| `flex-wrap` | 28 |
| `grid-column` | 27 |
| `inset` | 19 |
| `grid-row` | 15 |
| `transform` | 8 |
| `order` | 5 |
| `grid-template-rows` | 3 |

### The commonest conditions

| condition | blocks |
|---|---|
| `(max-width:600px)` | 33 |
| `(max-width:1050px)` | 25 |
| `(max-width:680px)` | 22 |
| `(max-width:700px)` | 22 |
| `(max-width:1000px)` | 18 |
| `(max-width:640px)` | 15 |
| `(max-width:670px)` | 10 |
| `(max-width:620px)` | 10 |
| `(max-width:560px)` | 10 |
| `(max-width:960px)` | 8 |
| `(max-width:900px)` | 6 |
| `(max-width:760px)` | 6 |
