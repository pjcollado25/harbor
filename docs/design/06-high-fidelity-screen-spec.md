# 06 — High-fidelity mobile screens

The visual specifications below are ready to build as Figma frames using Page 04 tokens and Page 05 components. The local HTML prototype only implements a subset of the 13 screens; it does not substitute for these screen designs.

## Screen specifications

### 1. Onboarding and initial preferences

- **Purpose / primary task:** establish locale and a useful first plan without demanding bank access.
- **Hierarchy:** “Make a plan around what changes” → country/currency and date/week preference → optional starting funds snapshot → continue → privacy summary.
- **Components:** progress indicator, locale picker, currency picker, date preference, optional amount field, privacy note, primary action.
- **Interactions:** skip starting funds; choose currency; continue to Add first bill; back retains selections. Never request notification permission during initial onboarding.
- **States:** locale not selected; invalid currency; starting funds omitted; save error.
- **Accessibility:** field labels persist; searchable locale list; amount reads currency; describe why starting funds are optional.

### 2. Home dashboard / Today

- **Purpose / primary task:** answer “what needs my attention next?”
- **Hierarchy:** local date and greeting → next bill with name/amount/days to due → next 14-day obligation total and compact list → expected income with confidence → one next action → optional progress summary.
- **Components:** Next due module, obligation rows, income event row, primary/secondary action, floating glass bottom navigation (opaque fallback for reduced transparency).
- **Interactions:** open bill, mark paid, see all bills, review plan, add bill. “Remaining planned funds” appears only when a dated starting funds snapshot and sufficiently complete known commitments exist; label “Planned after known commitments.”
- **States:** empty setup, no bill due, overdue, missing starting funds, multiple same-day bills, partially entered forecast.
- **Accessibility:** order follows visual hierarchy; amount and due date are spoken with bill name; action labels identify object.

### 3. Bills list and filtering

- **Purpose / primary task:** locate an obligation and understand its status.
- **Hierarchy:** title and next-due total → search → filter chips (All, Upcoming, Due soon, Overdue, Paid) → grouped rows by date/status → Add bill.
- **Components:** search field, filter chips, bill rows, month total, contextual add button.
- **Interactions:** filters compose; clear filters; sort by due date by default; row opens details; long list supports scroll and keeps search accessible.
- **States:** loading, empty, no search results, overdue, partially paid, variable estimate.
- **Accessibility:** filters expose selected state; rows do not depend on color; provide “Clear filters.”

### 4. Add or edit bill

- **Purpose / primary task:** record a recurring or one-time obligation accurately.
- **Hierarchy:** title → name → amount + fixed/variable selector → next due date → frequency → category → reminder → save.
- **Components:** text/amount fields, date picker, frequency selector, category selector, reminder selector, sticky save action.
- **Interactions:** variable amount can be edited per occurrence; frequency options include once/weekly/biweekly/monthly/quarterly/yearly/custom day; edit applies to “this occurrence” or “this and future” with explanation.
- **States:** blank, field errors, date in past, variable amount, unsaved changes, save error.
- **Accessibility:** persistent labels, keyboard order, announce errors, date picker has text-entry alternative.

### 5. Bill details

- **Purpose / primary task:** inspect this occurrence and decide whether to pay, reschedule, or edit.
- **Hierarchy:** bill name/category → due date/status → amount and fixed/estimate note → recurrence rule → reminder → recent payments → actions.
- **Components:** bill summary, status label, recurrence description, reminder row, action buttons, payment history list.
- **Interactions:** Edit, Record payment, Reschedule, pause future occurrences, delete (confirm scope). Changing one date offers “Only this date” or “This and future dates.”
- **States:** due soon, overdue, paid, partial, variable amount, missing amount, recurrence paused.
- **Accessibility:** explain whether each change affects one occurrence or the series; delete confirm names the bill.

### 6. Payment recording and confirmation

- **Purpose / primary task:** record a full or partial payment and recover from mistakes.
- **Hierarchy:** bill/occurrence → amount paid → date → optional note → confirm; success screen shows recorded amount/date and remaining balance if partial.
- **Components:** amount/date fields, confirmation action, success feedback, Undo and Done.
- **Interactions:** payment can be below the estimate; user confirms partial. Undo restores prior status. Correction creates an audit entry with a reason/date.
- **States:** invalid amount, partial, save error, success, undo success.
- **Accessibility:** announce success once; distinguish “payment recorded by you” from externally verified receipt.

### 7. Calendar and agenda

- **Purpose / primary task:** scan upcoming bills and expected income by date.
- **Hierarchy:** month selector + Agenda/Month switch → month grid or dated agenda → daily event list.
- **Components:** segmented control, month grid, event markers with symbol and label, agenda rows, date detail.
- **Interactions:** tap date to reveal events; overlapping events count indicator opens all events; drag/reschedule is not used in MVP (avoids accidental date changes); explicit edit flow changes date.
- **States:** empty month, multiple same-day obligations, overlapping expected income, rescheduled event, overdue event.
- **Accessibility:** Agenda is the equivalent accessible list; month grid announces date and event count; symbols and labels accompany color.

### 8. Reminder settings

- **Purpose / primary task:** choose a useful reminder cadence and protect private details.
- **Hierarchy:** reminder schedule → per-bill choices → device notification status → preview privacy.
- **Components:** reminder offset selector (day of / 1 / 3 / 7 days / custom), local-time selector, permission explainer, privacy-preview toggle.
- **Interactions:** set first reminder before permission request; explain benefit and request OS permission; allow Not now; snooze options (later today, tomorrow, choose date).
- **States:** enabled, permission denied, no reminders, duplicate reminder prevented, rescheduled.
- **Accessibility:** permission copy states exactly what appears; preview can be tested with sensitive details hidden.

### 9. Cash-flow planning and forecast explanation

- **Purpose / primary task:** understand the plan and see how a changed expected payment affects known commitments.
- **Hierarchy:** time window → starting funds snapshot with date/source → known outflows and received income → expected income by confidence → planned funds after known commitments (only if computable) → scenario control → assumptions.
- **Components:** timeline/agenda switch, scenario selector (Current plan / Income arrives later), event rows, equation/explanation, unknown-data list.
- **Interactions:** choose a payment event and move its date; compare current and delayed scenario; choose which event moves; see affected obligations. Any estimate change is undoable.
- **States:** no balance snapshot, unknown bill amount, no income entered, changed event, shortfall in plan, complete-looking data.
- **Accessibility:** never use a single line chart alone; table and narrative state the date, amount, and source of each event.

### 10. Financial insights

- **Purpose / primary task:** review known monthly/annual obligations and material changes.
- **Hierarchy:** period selector → total known recurring obligations → comparisons → notable bill changes → commitments vs. entered/received income.
- **Components:** summary rows, small direct-label bar chart, comparison period selector, “why this changed” list.
- **Interactions:** tap metric to filter payment history; change period; view source bills. Avoid charts without an actionable interpretation.
- **States:** insufficient history, partial categories, changed recurrence, unusual amount estimate.
- **Accessibility:** provide a summary sentence and data table; use direct labels and consistent axes.

### 11. Goals and achievements

- **Purpose / primary task:** optionally set a personal buffer milestone and review progress without pressure.
- **Hierarchy:** optional goal → current entered progress → next achievable step → quiet acknowledgement.
- **Components:** goal amount/date, simple progress line, edit/pause/remove actions, milestone text.
- **Interactions:** set a goal only after the user chooses it; no daily streak; pause freely; progress uses user-entered snapshot or recorded events only.
- **States:** no goal, paused goal, progress changed, missed target date. Missed target text is neutral (“Review your target date?”).
- **Accessibility:** percentages paired with actual amount; no confetti/motion required; progress not the only way to read state.

### 12. Payment history

- **Purpose / primary task:** find what was recorded and correct an error.
- **Hierarchy:** period/filter → payment and received-income ledger → item details → correction history.
- **Components:** date groups, payment rows, filters for bills/income/adjustments, receipt note, correction action.
- **Interactions:** open source bill/income event; correct amount/date with confirmation; export is later scope unless privacy needs require MVP export.
- **States:** empty, filtered empty, partial payment, corrected entry.
- **Accessibility:** semantic list with date and amount in each row; corrections are announced and explained.

### 13. Settings, privacy, and notification preferences

- **Purpose / primary task:** change locale, notification behavior, privacy controls, or account/data choices.
- **Hierarchy:** profile/locale → notification preferences → lock-screen privacy → data export/delete → privacy explanation.
- **Components:** settings rows, toggle, locale picker, confirmation sheet, privacy copy.
- **Interactions:** update notification schedule; hide amount/payee previews; export/delete data with explicit confirmation; clear local data after delete.
- **States:** OS permission denied, export preparing/error, delete confirmation, save error.
- **Accessibility:** destructive action is separated and named; plain language explains saved data and deletion consequence; every toggle has an explicit label.

## High-fidelity review checklist

Check all 13 screens at 390 × 844 and 360 × 800, then test the narrow 320 px constraint and 200% text scaling. Verify date/currency localization, component variants, source labeling, keyboard overlap, focus order, empty/error/overdue states, and text contrast before claiming implementation readiness. No usability claim is made until Page 08 testing is complete.
