# 03 — Information architecture and wireframes

## Navigation recommendation

Use four primary destinations: **Today**, **Plan**, **Bills**, and **Activity**. Settings stays behind the profile/menu button. Do not promote Insights or Progress to separate tabs: they are periodic review tasks and should sit inside Activity. Calendar and forecast share Plan because both answer “what happens when?” The destination labels stay concrete.

| Candidate destination | Decision | Reason |
|---|---|---|
| Home | Keep as **Today** | High-frequency scan: next due item, near-term obligations, and one next action. “Today” describes the user's immediate task. |
| Calendar | Merge into **Plan** | Monthly/agenda dates and cash-flow scenarios use the same events and time horizon. |
| Bills | Keep | Repeated task and canonical obligation management location. |
| Insights | Nest under **Activity → Review** | Less frequent summary; avoid an empty/low-value tab during early use. |
| Progress | Nest under **Activity → Your progress** | Secondary optional reflection, never compete with due tasks. |

Tabs appear in a floating bottom bar on primary pages. Selected state uses an icon, label, and shape/weight change; color is supplemental. The local prototype uses a restrained glass material on this navigation layer, with opaque fallback and scroll clearance. Add actions are contextual on Today/Bills, not a permanent central floating button.

## Object model and status language

- **Starting funds snapshot:** amount the user entered, currency, and “as of” date/time. Not verified by a bank.
- **Income event:** amount, expected date, source/memo, confidence state, and received amount/date if confirmed by the user.
- **Bill occurrence:** scheduled date, amount (fixed or estimated), frequency rule, status, and any actual payment record.
- **Forecast day:** starting funds snapshot + user-confirmed receipts before that date − known bill occurrences before that date. It is a *plan estimate*, not a current balance or advice.

Status labels are always words with icons: Expected (clock outline), Client says sent (paper plane/processing), Received (check and “you marked received”), Due soon (calendar), Paid (check), Overdue (alert dot + text). Color never carries state alone.

## Low-fidelity wireframes — priority journeys

These establish structure before polish. Bracketed areas are tappable components; vertical placement is approximate. Build these first in Figma and review against Page 02 before the high-fidelity screens.

### A. Today / next payment

    ┌─────────────────────────────┐
    │ Harbor            [profile] │
    │ Tuesday, 20 October         │
    │                             │
    │ NEXT DUE                    │
    │ Internet                    │
    │ ₱1,899 · in 3 days          │
    │ [View bill]     [Mark paid] │
    │                             │
    │ IN THE NEXT 14 DAYS         │
    │ 3 bills · ₱8,740 planned    │
    │ [Rent       Oct 25  ₱6,000] │
    │ [Internet   Oct 23  ₱1,899] │
    │ [Power      Oct 29  estimate]│
    │ [See all bills]             │
    │                             │
    │ EXPECTED INCOME             │
    │ ₱14,000 · 28 Oct            │
    │ Expected · entered by you   │
    │ [Review plan]               │
    │                             │
    │ [Today] [Plan] [Bills] [Activity]│
    └─────────────────────────────┘

### B. Add a recurring bill

    ┌─────────────────────────────┐
    │ [Back]       New bill       │
    │ Name                        │
    │ [Internet service_________] │
    │ Amount                      │
    │ [₱ 1,899________] [Variable]│
    │ Due date                    │
    │ [23 October 2026  ▾]        │
    │ Frequency                   │
    │ [Monthly          ▾]        │
    │ Category                    │
    │ [Home & utilities ▾]        │
    │ Remind me                   │
    │ [3 days before     ▾]       │
    │                             │
    │ [Save bill]                 │
    └─────────────────────────────┘

### C. Delayed income and changed forecast

    ┌─────────────────────────────┐
    │ [Back]      Income detail   │
    │ Logo project · ₱14,000      │
    │ Expected · 28 October       │
    │ You entered this estimate   │
    │ [Change date] [Mark received]│
    │                             │
    │ IF THIS ARRIVES 5 DAYS LATER│
    │ Oct 23 Internet   covered*  │
    │ Oct 25 Rent       needs review│
    │ Oct 29 Power      needs review│
    │ *Using starting funds entered│
    │ by you on 20 Oct.           │
    │                             │
    │ [View plan] [Keep current]  │
    └─────────────────────────────┘

### D. Record a payment, recover

    ┌─────────────────────────────┐
    │ Record payment              │
    │ Rent · due 25 Oct           │
    │ Amount paid                 │
    │ [₱ 6,000________]           │
    │ Paid on                     │
    │ [20 Oct 2026____]           │
    │ [Confirm payment]           │
    │                             │
    │ Payment recorded            │
    │ [Undo]      [Done]          │
    └─────────────────────────────┘

## Navigation and screen map

    Today ── Bill detail ── Record payment ── Confirmation / Undo
      │           └──────── Reminder settings
      ├── Add bill ── Save ── Bill detail
      └── Plan ── Agenda / Month ── Income detail ── Change date
           └── Forecast explanation ── affected obligations
    Bills ── search / filters ── Add or edit bill
    Activity ── Payment history
        ├── Review (insights)
        └── Your progress (optional goal)
    Profile/menu ── Settings / privacy / notification preferences

