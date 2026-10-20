# 02 — Product strategy and user journeys

## Positioning decision

**Recommendation: position Harbor as an irregular-income cash-flow companion.** Bills are its first core object; the user-facing promise is to help plan around uncertain dates and obligations. A bill tracker can say what is due. A cash-flow companion can also show which income is already received, which is still expected, and what changes if a date moves. This is a desk-research hypothesis, not a validated market preference.

**Value proposition:** “See what is due, what money has actually arrived, and how your plan changes when expected income moves.”

**Differentiation hypothesis:** transparent, user-editable event confidence and a dated forecast that never calls expected income “available.” No black-box score, no automatic “safe to spend” claim, and no requirement to link a bank account to get a useful first view.

## Candidate primary segment

Independent client-service professionals who earn from one or more clients through projects or retainers, have no reliable payroll date, manage household obligations themselves, and currently check several sources (bank/payment app, calendar, invoice tool, notes, or spreadsheet) to answer “what must be paid before the next likely deposit?” Start with adults who can use a chosen digital reminder channel and are comfortable entering a small set of dates manually.

This is a testable segment definition, not a persona validated by interviews. Platform workers, seasonal workers, microbusinesses with payroll, people managing shared household money, and people without reliable digital access need separate research before their workflows are folded into one experience.

## Jobs to be done

- When an obligation is approaching, help me see its amount, date, and status so I can decide what to do next.
- When a client payment is delayed or uncertain, help me move the expected date and understand which plans are affected.
- When money arrives, help me record what actually cleared and distinguish it from what I was told to expect.
- When a bill amount varies, let me use an estimate now and correct it when the actual amount is known.
- When I need a reminder, let me choose a useful time and recover if I snooze, reschedule, or mark something incorrectly.

## Core journeys

### 1. Set up a usable plan

Choose country/locale, currency, and week/date format → add an optional starting balance with “entered by you” label and as-of date → add the first recurring bill → add any known expected income with status and date → see the first forecast with assumptions. Account linking is not required.

### 2. Check the next obligation

Open Today → read next due bill and days remaining → inspect the short list and total due → open bill details → record paid or change date/amount → see the remaining planned commitments update → undo or correct a mistaken action.

### 3. Respond to delayed income

Open Plan → choose an expected income event → change its date or status → see a plain-language summary of affected commitments and revised minimum/likely/if-delayed paths → decide whether to reschedule a bill or leave the plan unchanged. No recommendation to borrow or skip essentials.

### 4. Review habits without pressure

Open Activity → filter received income and recorded payments → inspect monthly obligation totals and recurring changes → optionally set a personal buffer goal → mark milestones as private, neutral acknowledgements. No streak loss for missed weeks.

## MVP scope

**Include (candidate scope pending discovery):**

- Manual bill creation/editing for one-time and recurring dates, variable amount estimate, frequency, category, payment status, and flexible next-date edit.
- Manual expected-income events with amount, date, source label, and explicit state: **Expected**, **Client says sent**, or **Received**. “Received” only after user confirmation; a receipt is not a bank-verified balance.
- Optional user-entered current funds snapshot with timestamp, visually separate from projected events.
- A 30-day event timeline and an explainable baseline / income-late scenario. Show known commitments and user-entered estimates; no probabilistic predictions in MVP.
- Local reminders, per event, with snooze/reschedule and duplicate suppression.
- Payment record, confirmation, undo, correction, and activity history.
- Locale-aware dates and one plan currency. If an income amount is foreign currency, MVP asks the user to enter a base-currency estimate; it does not silently convert.
- Data export/delete controls and a plain-language privacy summary before financial inputs.

**Defer until evidence supports the cost:** open-banking integrations; automatic invoice ingestion/chasing; payment execution/autopay; tax planning; shared household/teams; multi-currency live conversion; AI-derived payment probabilities; credit/loan suggestions; gamified streaks; advanced annual forecasting; broad bookkeeping and investment tracking.

## Risks, assumptions, and validation questions

| Risk or assumption | Validation question / response |
|---|---|
| Manual setup creates too much work. | How many existing bills and income events do people actually maintain? Compare a 3-event setup against import/linking expectations. |
| Event confidence labels are understood. | Ask participants to explain “Expected,” “Client says sent,” “Received,” and “Starting funds entered by you” in their own words. |
| A forecast helps decision-making rather than increasing anxiety. | Observe whether users can name what changed and choose a next step; ask whether the presentation feels judgmental or falsely certain. |
| People want forecasted residual funds. | Test whether “planned funds after known commitments” is useful and whether the phrase is clearly understood as a plan, not a bank balance. Hide it if source data is too incomplete. |
| One currency per plan is acceptable. | Recruit people who receive cross-border payments and learn the minimum viable currency conversion workflow. |
| Reminders reduce misses without becoming nagging. | Compare user-selected schedules and snooze behavior; check for duplicates and sensitive lock-screen content. |
| Progress is motivating. | Test optional monthly review/buffer progress with a neutral default; remove achievement prompts if users feel blamed. |
| Regional compliance and privacy needs are manageable. | Select launch markets before implementation; review data retention, notification, accessibility, and financial-services obligations for each. |
