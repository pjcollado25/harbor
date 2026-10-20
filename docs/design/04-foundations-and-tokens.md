# 04 — Foundations and design tokens

## Art direction: “a clear working ledger”

Harbor should feel like a dependable pocket ledger organized for decisions: a deep charcoal-green canvas, soft forest glows, clear numbers, a quiet sans-serif for forms, and one small clay accent for dates or a changed forecast. The prototype defaults to dark mode and retains a light-mode toggle. Use glass on the floating tab bar and selected summary surfaces to add depth while keeping amounts, labels, and form controls easy to read. Preserve the calm editorial character through date labels (“Due in 3 days”), concise reassurance, and a purposeful forecast timeline. Honor system text sizing, reduced transparency, and reduced motion.

## Reference qualities

See the three product examples and notes on Page 01: Monarch for event list/calendar switching, YNAB for direct schedule editing, and Apple Calendar for familiar date navigation. Apple's current tab-bar guidance recommends visible labels and describes iPhone tab bars as floating above content on a Liquid Glass background. Its Liquid Glass guidance reserves the material for the top navigation layer, calls for distinct separation from the content layer, and advises against overuse. [Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars) · [Adopting Liquid Glass](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass) · [WWDC25: Build a UIKit app with the new design](https://developer.apple.com/videos/wwdc2025/284/). Borrow platform behavior only. Harbor’s “working ledger” composition is its own direction and should not copy brand color, illustration, or component styling from any reference.

### Glass surfaces and navigation

- Use an inset dark-glass tab bar above the iPhone safe area, with a fine light edge, backdrop blur/saturation, a soft highlight, and an active-tab capsule. Keep all four labels (Today, Plan, Bills, Activity) visible and crisp; color supplements the label and icon.
- Extend the glass treatment to the next-due feature card, summary metrics, segmented controls, secondary actions, and Undo toast. Keep form fields more opaque than the cards, and preserve high contrast for amounts, dates, and status labels.
- Use the Liquid Glass principle of distinct navigation and content layers as the guide; glass on summary panels is a restrained Harbor-specific extension. Avoid adding blur to every small row or text group.
- Preserve at least 44 × 44 px per tab, add scroll clearance after the last item, and place Undo feedback above the bar. Use opaque materials when blur is unsupported or reduced transparency is requested.
- The local HTML preview now contains dark mode, the phone device frame, and the extended glass treatment; the current Figma screen frames still show the earlier light visual design.

## Mobile frame, grid, and resizing

- Primary screen: **390 × 844 px** inside a **414 × 872 px** iPhone-style device frame; create review variants at **360 × 800** and **430 × 932**. Keep core content usable down to **320 px** width. On wider browsers the HTML prototype shows the full bezel, Dynamic Island, side keys, and home indicator; on phone-sized browsers the page uses the available screen.
- Respect safe areas. Content uses a 20 px side inset at 390 px width; 16 px at widths below 360. The floating bottom navigation sits 12 px above the device safe area; leave at least 20 px of unobstructed scroll space after the last content item.
- Four-column mobile grid, 12 px gutters, fluid columns. Forms use full-width fields. Data rows keep the amount right aligned and allow the name to wrap.
- Use Auto Layout for all stacks, lists, buttons, form rows, and navigation. Cards/rows hug content vertically, expand when text scales, and fill the available width. Buttons have minimum 48 px tap height; touch targets should be at least 44 × 44 px.
- Avoid fixed-height text containers. At 200% text scaling, allow scroll and wrap; sticky actions move above the keyboard and never cover errors or the final field.

## Spacing and shape

Spacing tokens (px): **space-1 4**, **space-2 8**, **space-3 12**, **space-4 16**, **space-5 20**, **space-6 24**, **space-8 32**, **space-10 40**, **space-12 48**, **space-16 64**. Use 8/16/24/32 for primary composition; 4/12 only for compact internal alignment.

Radii: **radius-sm 8** (fields/chips), **radius-md 12** (grouped surfaces), **radius-lg 18** (cards/sheets), **radius-nav 27** (floating nav), **radius-pill 999** (small filter chips). Border width 1 px. Shadows are reserved for an overlay/sheet and the floating nav; normal content surfaces are separated by background shift or divider.

## Typography

Use **DM Sans** for readable product UI and **DM Serif Display** for the single editorial moment on Today and screen titles. If custom fonts cannot load, fall back to system sans and Georgia, respectively. Confirm licenses and availability in the Figma file before handoff.

| Token | Typeface / size / line height | Use |
|---|---|---|
| display | DM Serif Display 30 / 36, regular | Today’s dated greeting or a single key total; not every page |
| title-1 | DM Sans 24 / 32, semibold | Page title |
| title-2 | DM Sans 20 / 28, semibold | Section heading |
| title-3 | DM Sans 17 / 24, semibold | Bill name / sheet title |
| body | DM Sans 16 / 24, regular | Default reading and field value |
| body-sm | DM Sans 14 / 20, regular | Supporting details |
| label | DM Sans 12 / 16, semibold, tracking +0.3 | Overline and uppercase micro-label |
| amount-lg | DM Sans 28 / 34, semibold, tabular numerals | Primary amount |
| amount-sm | DM Sans 16 / 24, semibold, tabular numerals | Row amount |

Use locale-aware number formatting and tabular numerals for aligned amounts. Never shrink a value below 14 px to fit; wrap, abbreviate the label, or let the amount occupy its own line.

## Color tokens and semantic roles

The table below shows the light-mode values. The prototype defaults to dark mode and maps the same semantic roles to a dark palette; the theme toggle switches between them.

| Token | Hex | Role |
|---|---|---|
| canvas | #F4F1E8 | Warm page background |
| surface | #FFFDF8 | Main content and sheets |
| surface-muted | #ECE9E0 | Selected/quiet group background |
| ink | #22312C | Main text |
| ink-muted | #58655F | Secondary text |
| line | #D6D4CA | Dividers and field borders |
| forest | #254C3C | Primary actions and selected nav |
| forest-soft | #E5EEE8 | Quiet positive state background |
| clay | #B85038 | Accent for dates, small markers, and changed data |
| success-ink | #205A42 | Paid / received label |
| success-bg | #E6F1E9 | Positive state background |
| warning-ink | #70500C | Due soon / uncertain change label |
| warning-bg | #F6EDCF | Warning background |
| danger-ink | #8A342D | Overdue / error label |
| danger-bg | #F8E6E3 | Error background |
| disabled-ink | #7E837F | Disabled text |
| disabled-bg | #E7E6E1 | Disabled surface |

Color is never the only status cue. Pair semantic color with text and an icon; provide a legend in the forecast. Target WCAG 2.2 AA contrast for text and controls; verify all final pairs, especially interactive focus and disabled states. Primary control uses forest on the canvas or surface; clay is not used for small text on a light surface.

| Dark token | Hex | Role |
|---|---|---|
| canvas | #0C100E | Default dark page background |
| surface | #17211B | Dark card and form base |
| surface-muted | #202B24 | Quiet group background |
| ink | #F0F5F0 | Main text |
| ink-muted | #B0BBB3 | Secondary text |
| line | #34423A | Dividers and field borders |
| forest | #9FDBB1 | Primary action and selected navigation |
| forest-soft | #203B2B | Quiet positive state background |
| clay | #F0A28E | Date and changed-data accent |
| success-ink | #A6DCB6 | Paid / received label |
| success-bg | #193526 | Positive state background |
| warning-ink | #F0CC75 | Due soon / uncertain change label |
| warning-bg | #3B321D | Warning background |
| danger-ink | #F0A29A | Overdue / error label |
| danger-bg | #412522 | Error background |

Glass surfaces use a deep green-black fill (**rgba(13,20,16,.82)** for navigation), a pale keyline, **24 px blur + 175% saturation**, a small directional highlight, and a soft shadow. The light theme uses warm translucent glass. Keep figures and labels crisp; use more opaque fields and opaque fallbacks when blur is unsupported or reduced transparency is requested. The main navigation and selected summary surfaces carry the glass treatment; small ledger rows stay clear and quiet.

## Iconography and motion

Use a single 24 px line icon set with 1.75 px stroke, rounded joins, and filled state only for selected navigation. Icons supplement visible labels. Avoid emoji and merchant logos as the only way to identify a bill. Motion is short and functional: 120–180 ms state transition, no bouncing number animation. Respect reduced motion; undo uses a stable toast, not a disappearing animation.

## Accessibility and localization baseline

- Minimum body size 14 px and 16 px for core form/body copy; support system text scaling to 200% without clipping.
- Visible labels persist when fields have values; placeholders are examples only. Focus is visible and keyboard order follows the screen.
- Status chips announce their text; charts include a screen-reader summary and data table. Provide an agenda/list alternative to the month grid.
- Do not use red/green alone. Date and amount formats, currency placement, pluralization, and week starts follow the selected locale.
- Protect financial detail in notification preview by default: “A bill is coming up” with optional user opt-in to show the payee/amount.
- The local prototype defaults to the dark palette and retains a light alternative through a visible theme toggle. Recheck contrast and device-specific material behavior before a native release.

