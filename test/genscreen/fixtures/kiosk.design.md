---
name: Kiosk
version: 1.0.0
description: Loud neo-brutalist retail. Black ink borders, hard offset shadows, acid yellow.
---

# Kiosk design kit

## Brand

Personality: loud, honest, a little cheeky
Voice: short and punchy; second person; capitalized labels
Tone: confident and funny, never rude

Kiosk is a streetwear shop that looks like a printed zine. Thick black outlines and hard shadows instead of soft depth.

Do:
- Use big type and hard edges.
- Keep copy to one line where you can.

Don't:
- Use soft blurred shadows or gradients.
- Round corners more than the kit's radius tokens.

## Colors

| Token | Light | Dark | Usage |
|---|---|---|---|
| primary | #FFD400 | #FFD400 | Primary buttons, highlights, active nav |
| onPrimary | #0A0A0A | #0A0A0A | Text on primary |
| secondary | #FF5CA8 | #FF5CA8 | Secondary buttons, badges, sale tags |
| onSecondary | #0A0A0A | #0A0A0A | Text on secondary |
| background | #F4F1E8 | #121212 | Page background (newsprint) |
| surface | #FFFFFF | #1C1C1C | Cards, inputs, bars |
| surfaceVariant | #E9E4D4 | #2A2A2A | Placeholders, skeletons |
| onSurface | #0A0A0A | #F4F1E8 | Text |
| onSurfaceVariant | #4A4740 | #B8B2A2 | Secondary text |
| outline | #0A0A0A | #F4F1E8 | Every border (2px) |
| error | #E5261F | #FF6B5E | Errors |
| onError | #FFFFFF | #0A0A0A | Text on error |
| success | #1DB954 | #1DB954 | Success |
| warning | #FF8A00 | #FF8A00 | Warnings |

## Typography

| Token | Family | Size | Weight | Line height | Letter spacing | Case | Usage |
|---|---|---|---|---|---|---|---|
| display | Space Grotesk | 44 | 700 | 1 | -1.5 | upper | Hero headlines |
| headline | Space Grotesk | 32 | 700 | 1.05 | -1 | upper | Screen titles on desktop |
| title | Space Grotesk | 22 | 700 | 1.15 | -0.5 | upper | Screen titles on mobile, card titles |
| subtitle | Space Grotesk | 16 | 700 | 1.3 | 0 | - | Row titles, section titles |
| body | IBM Plex Sans | 15 | 400 | 1.5 | 0 | - | Text |
| label | Space Grotesk | 14 | 700 | 1.1 | 0.5 | upper | Buttons, chips, tabs, labels |
| caption | IBM Plex Mono | 12 | 500 | 1.4 | 0 | - | Prices, SKUs, metadata |

## Spacing

| Token | Value |
|---|---|
| xs | 4 |
| sm | 8 |
| md | 14 |
| lg | 20 |
| xl | 28 |
| xxl | 44 |

## Radius

| Token | Value |
|---|---|
| none | 0 |
| sm | 4 |
| md | 6 |
| pill | 999 |

## Elevation

| Token | Shadow |
|---|---|
| flat | none |
| low | 3 3 0 0 #0A0A0A |
| medium | 5 5 0 0 #0A0A0A |
| high | 8 8 0 0 #0A0A0A |

## Components

### Button

Height: 52
Radius: sm
Padding x: lg
Text: label
Icon size: 20
Shadow: low

| Variant | Fill | Text | Border |
|---|---|---|---|
| primary | primary | onPrimary | outline |
| secondary | secondary | onSecondary | outline |
| outline | surface | onSurface | outline |
| ghost | none | onSurface | none |
| destructive | error | onError | outline |

Rules:
- Every button has a 2px black border and a hard shadow except ghost.

### Card

Fill: surface
Border: outline
Border width: 2
Radius: sm
Padding: md
Gap: sm
Shadow: medium

### List row

Min height: 60
Padding x: md
Padding y: sm
Gap: md
Title: subtitle
Subtitle: caption
Leading size: 44
Icon color: onSurface
Divider: yes

### Input

Height: 52
Fill: surface
Border: outline
Border width: 2
Focus border: secondary
Radius: sm
Padding x: md
Text: body
Label: label
Label color: onSurface
Hint color: onSurfaceVariant

### App bar

Height: 64
Fill: primary
Title: title
Icon color: onPrimary
Border: outline
Align: center

### Nav bar

Mobile: bottom
Desktop: top
Fill: surface
Active: onSurface
Inactive: onSurfaceVariant
Indicator: primary
Height: 68

### Chip

Fill: surface
Text: onSurface
Selected fill: primary
Selected text: onPrimary
Radius: pill
Height: 34
Border: outline
Text style: label

### Badge

Fill: secondary
Text: onSecondary
Radius: sm
Text style: caption

### Avatar

Size: 44
Radius: sm

### Banner

Radius: sm
Padding: md

| Tone | Fill | Text |
|---|---|---|
| info | primary | onPrimary |
| success | success | onSurface |
| warning | warning | onSurface |
| error | error | onError |

### Switch

Active: onSurface
Inactive: surfaceVariant

### Divider

Color: outline
Thickness: 2

## Layout

| Breakpoint | Min width | Columns | Margin | Gutter | Max content |
|---|---|---|---|---|---|
| mobile | 0 | 4 | md | md | 600 |
| tablet | 600 | 8 | lg | lg | 900 |
| desktop | 1024 | 12 | xl | lg | 1240 |

Section gap: xl
Section title: title
Form width: 460
Product grid: 2 columns on mobile, 4 on desktop

Rules:
- Grids over lists for products.
- Align everything to the left edge of the column.

## Motion

| Token | Duration | Curve | Usage |
|---|---|---|---|
| fast | 90ms | linear | Press: shadow collapses as the button moves 3px |
| standard | 180ms | easeOut | State changes |
| emphasized | 300ms | easeOutBack | Sheets and toasts snap in |

Rules:
- Snappy, never floaty.

## Imagery

Style: flash photography on flat color; product cut-outs
Radius: none
Placeholder: surfaceVariant
Hero aspect: 4:3
Cover aspect: 1:1

## Iconography

Set: Material Symbols
Style: sharp
Size: 24
Color: onSurface

## Accessibility

Min contrast: 4.5
Min touch target: 48

Rules:
- Yellow is never used for text on white.
