---
name: Verdant
version: 1.0.0
description: Organic wellness and food. Sage and clay on warm paper, serif titles, pill shapes.
---

# Verdant design kit

## Brand

Personality: warm, grounded, unhurried
Voice: friendly and encouraging; full sentences; first person plural ("we")
Tone: gentle; celebrates small progress

Verdant is for wellness, recipes and slow living. Generous space, soft natural colors, rounded shapes.

Do:
- Leave room to breathe: prefer one column with large spacing.
- Use gentle encouragement in empty states.

Don't:
- Use pure black text or harsh red.
- Crowd more than four actions on a screen.

## Colors

| Token | Light | Dark | Usage |
|---|---|---|---|
| primary | #3F6B4F | #9BC7A7 | Primary actions, active nav |
| onPrimary | #FFFFFF | #10261A | Text on primary |
| secondary | #E8D5C0 | #4A3B2C | Secondary buttons, chips |
| onSecondary | #4A2F1B | #F3E6D6 | Text on secondary |
| background | #FBF7F0 | #141A16 | Page background (paper) |
| surface | #FFFFFF | #1D2520 | Cards, sheets |
| surfaceVariant | #F1EBE0 | #28322B | Placeholders, quiet fills |
| onSurface | #2B2A26 | #EDEAE3 | Text |
| onSurfaceVariant | #6B675D | #B5B0A4 | Secondary text |
| outline | #E4DCCD | #36423A | Borders |
| error | #B5452F | #F0A08E | Errors |
| onError | #FFFFFF | #3A1209 | Text on error |
| success | #3F6B4F | #9BC7A7 | Success |
| warning | #B7791F | #E9B872 | Warnings |
| accent | #C8714B | #E9A27F | Highlights, favorites, ratings |

## Typography

| Token | Family | Size | Weight | Line height | Letter spacing | Case | Usage |
|---|---|---|---|---|---|---|---|
| display | DM Serif Display | 42 | 400 | 1.1 | -0.5 | - | Hero titles |
| headline | DM Serif Display | 32 | 400 | 1.15 | -0.3 | - | Screen titles on desktop |
| title | DM Serif Display | 24 | 400 | 1.2 | 0 | - | Screen titles on mobile, card titles |
| subtitle | Nunito Sans | 17 | 700 | 1.35 | 0 | - | Row titles, section titles |
| body | Nunito Sans | 16 | 400 | 1.6 | 0 | - | Text |
| label | Nunito Sans | 15 | 700 | 1.2 | 0.2 | - | Buttons, chips, labels |
| caption | Nunito Sans | 13 | 600 | 1.4 | 0.2 | - | Metadata |

## Spacing

| Token | Value |
|---|---|
| xs | 4 |
| sm | 8 |
| md | 16 |
| lg | 24 |
| xl | 40 |
| xxl | 64 |

## Radius

| Token | Value |
|---|---|
| sm | 10 |
| md | 16 |
| lg | 24 |
| pill | 999 |

## Elevation

| Token | Shadow |
|---|---|
| flat | none |
| low | 0 2 10 0 #3F3A2E/8 |
| medium | 0 8 24 -6 #3F3A2E/14 |
| high | 0 16 40 -8 #3F3A2E/20 |

## Components

### Button

Height: 52
Radius: pill
Padding x: lg
Text: label
Icon size: 20

| Variant | Fill | Text | Border |
|---|---|---|---|
| primary | primary | onPrimary | none |
| secondary | secondary | onSecondary | none |
| outline | none | primary | primary |
| ghost | none | primary | none |
| destructive | error | onError | none |

### Card

Fill: surface
Border: none
Radius: lg
Padding: lg
Gap: sm
Shadow: low

### List row

Min height: 64
Padding x: md
Padding y: sm
Gap: md
Title: subtitle
Subtitle: caption
Leading size: 48
Icon color: primary
Divider: no

### Input

Height: 52
Fill: surfaceVariant
Border: none
Focus border: primary
Radius: md
Padding x: md
Text: body
Label: label
Label color: onSurface
Hint color: onSurfaceVariant

### App bar

Height: 64
Fill: background
Title: title
Icon color: onSurface
Border: none
Align: start

### Nav bar

Mobile: bottom
Desktop: sidebar
Fill: surface
Active: primary
Inactive: onSurfaceVariant
Indicator: secondary
Height: 72
Width: 240

### Chip

Fill: surfaceVariant
Text: onSurface
Selected fill: primary
Selected text: onPrimary
Radius: pill
Height: 36
Text style: label

### Badge

Fill: accent
Text: onPrimary
Radius: pill
Text style: caption

### Avatar

Size: 48
Radius: pill

### Banner

Radius: md
Padding: md

| Tone | Fill | Text |
|---|---|---|
| info | secondary | onSecondary |
| success | primary | onPrimary |
| warning | warning | onPrimary |
| error | error | onError |

### Switch

Active: primary
Inactive: outline

### Divider

Color: outline
Thickness: 1

## Layout

| Breakpoint | Min width | Columns | Margin | Gutter | Max content |
|---|---|---|---|---|---|
| mobile | 0 | 4 | md | md | 600 |
| tablet | 600 | 8 | lg | lg | 880 |
| desktop | 1024 | 12 | xl | lg | 1080 |

Section gap: xl
Section title: subtitle
Form width: 420

Rules:
- One column on mobile; at most two content columns on desktop.

## Motion

| Token | Duration | Curve | Usage |
|---|---|---|---|
| fast | 160ms | easeOut | Press and hover |
| standard | 280ms | easeInOut | State changes |
| emphasized | 480ms | spring | Celebrations, completing a goal |

## Imagery

Style: natural light food and plant photography; warm tones
Radius: lg
Placeholder: surfaceVariant
Hero aspect: 3:2
Cover aspect: 4:5

## Iconography

Set: Material Symbols
Style: rounded
Size: 24
Color: primary

## Accessibility

Min contrast: 4.5
Min touch target: 48

Rules:
- Serif display type is only used at 24px and above.
