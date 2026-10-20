# 05 — Components and interaction states

## Naming and Figma conventions

Use component names in Title Case with slash groups: **Navigation/Bottom Bar**, **Bill/Occurrence Row**, **Income/Confidence Label**, **Forecast/Scenario Line**, **Form/Amount Field**, **Feedback/Undo Toast**. Properties use sentence case and stable values: State = Default/Pressed/Focused/Disabled/Error; Tone = Neutral/Success/Warning/Danger; Size = Compact/Default/Large. Use Auto Layout and explicit min sizes; do not detach instances in screens.

## Component inventory

| Component | Properties / variants | Behavior and resizing |
|---|---|---|
| Navigation/Bottom Bar | Active = Today/Plan/Bills/Activity; theme = Dark/Light; material = Glass/Opaque fallback | Floating inset capsule with a warm translucent fill, blur, light keyline, and soft shadow; four equal-width targets with persistent labels, a forest-tinted selected capsule, safe-area clearance, and an opaque reduced-transparency fallback. |
| Action/Button | Kind = Primary/Secondary/Tertiary/Destructive; State = Default/Pressed/Focused/Disabled/Loading; Size = Default/Compact | Label + optional leading/trailing icon; min height 48 px (compact 44 px). Full-width in sheets; hug content in inline layouts. Loading preserves width and accessible name. |
| Bill/Occurrence Row | Status = Upcoming/DueSoon/Overdue/Paid/Partial; Amount = Fixed/Estimate/Unknown; density = Standard/Compact | Flexible name column; amount column right aligned; date/status remain visible below name at narrow widths. Entire row opens detail; trailing action has its own 44 px target. |
| Income/Event Row | Confidence = Expected/SaysSent/Received; source = Named/Unspecified | Show amount, date, and text status. Received requires a distinct “You marked received” source note unless a future integration verifies it. |
| Status/Label | Tone = Neutral/Success/Warning/Danger/Info; Icon = On/Off | Always include visible text in financial status use; color and icon supplement it. |
| Form/Text Field | State = Empty/Focused/Filled/Error/Disabled; Leading icon = Optional | Persistent label, optional helper/error, 48 px minimum. Error is below field and programmatically associated. |
| Form/Amount Field | Currency = local; Estimate = Fixed/Variable | Locale-aware entry, clear currency label; accepts zero only when allowed by field spec (normally no); variable estimate retains “estimate” in summary. |
| Control/Segmented Switch | View = Agenda/Month, Scenario = Expected/Income delayed | Two or three options maximum; semantic selection state and focus. Horizontally scroll only if the full label cannot fit. |
| Forecast/Scenario Line | State = Actual/Expected/Changed/Obligation; confidence = explicit | Date axis + event label + amount; actual and planned line patterns differ; includes text summary and table alternative. |
| Feedback/Undo Toast | Tone = Success/Error/Info; Action = Undo/Retry/None | Lives at bottom above nav; minimum 4-second visibility and remains until action/timeout; screen reader announces politely. |
| Sheet/Confirmation | Type = ConfirmPayment/UnsavedChanges/Delete | Clear title, consequence summary, safe cancel, and one emphasized action. No destructive action on a swipe-only gesture. |
| Empty/State | Context = Bills/Income/History/Insights | Explains why empty and one useful next step; no decorative illustration required. |

## Form validation and error recovery

- Required fields show inline “Add a bill name” or “Enter an amount” on save, focus the first invalid field, and preserve all valid values.
- Date must parse in the selected locale. A past date is allowed for an existing overdue bill but requires confirmation when creating a new due event.
- Recurrence requires a start date and frequency. Month-end behavior is stated (e.g. “31st, or last day in shorter months”).
- Amount must be greater than zero for a bill/income event. Decimal precision follows the currency. If a variable bill has no known amount, let the user save it as “Amount not set” and exclude it from totals with a visible count.
- Reject ambiguous time-only reminders until a local time zone is available; explain device time will be used.
- Do not block data entry on notification permission denial. Save first, then show settings with “Not now.”
- Failed save preserves entered data and offers Retry. Payment correction retains the original event in history and writes a correction entry; never silently overwrite.
- Confirmation supports Undo and an edit/correction route. Undo reverses the occurrence/payment event and restores its prior status, not the whole bill series.

## Reminder logic

One scheduled notification per event per configured reminder offset. If a user changes the due date, cancel future reminders for the old date and schedule one for the new date. Mark Paid, snooze, or reschedule cancels the pending reminder for that occurrence. Deduplicate by event ID + occurrence date + reminder offset. Default lock-screen copy hides payee and amount; the user can opt in per device. Notification permission is requested only after a user sets their first reminder, with a short explanation and “Not now.”

## Interaction state matrix

| Context | State | Presentation / next step |
|---|---|---|
| Bills | Loading | Skeleton rows with stable shape; avoid fabricated zero totals. |
| Bills | Empty | “Add a bill to see what’s coming up.” Button opens Add bill. |
| Bill | Overdue | Neutral direct text: “Due 2 days ago”; show date and action to record or reschedule, no warning shame copy. |
| Forecast | Missing starting funds | Show bill and income schedule only; say “Add starting funds to estimate planned funds after commitments.” Do not render a residual figure. |
| Forecast | Partial data | “Based on 3 bills and 1 expected payment you entered.” List missing/unknown amount items; no confidence percentage. |
| Forecast | Changed | Highlight changed date/event and explain which dates are affected; offer “Undo change.” |
| Form | Error | Inline field error plus summary if multiple errors; focus invalid item; keep prior input. |
| Payment | Success | Confirmation, payment date/amount, “Undo,” then Done. |
| Reminder | Permission denied | Explain reminders are off and provide device Settings path; rest of app remains usable. |
| Activity | No history | Explain history starts after the first recorded payment/receipt; link to add a bill or income. |
| Network/storage | Save error | “We couldn’t save this change.” Retry and keep draft; do not imply successful persistence. |

## Accessibility acceptance notes

Every control needs a programmatic name, role, selected/disabled state, and a visible focus indicator. Announce errors when they appear and payment success once. Keep toast Undo reachable via keyboard/switch access. Calendar events have text labels in agenda mode. Forecast line and chart always have a readable textual explanation and a table. Tap targets remain 44 × 44 px at the narrow layout. Text scaling changes layout height, never clips amounts or status. 

