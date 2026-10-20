# 07 — Interactive prototype

## Prototype status

The [editable Figma file](https://www.figma.com/design/2bdYwU0SN4q6aBctNmoK2Q) contains the mobile screens in iPhone-style frames, linked prototype destinations, and separate recovery states. The Figma click-through demonstrates the primary navigation, bill creation, bill details, reminder setup, payment confirmation/Undo, and the delayed-income scenario. The local HTML prototype defaults to dark mode, shows an iPhone-style device frame on wider screens, and includes a light/dark toggle. Glass styling appears on the floating navigation and key summary surfaces; Figma's screen frames still show the earlier light visual treatment. Figma fields are visual examples; use the local HTML prototype for functional form and scenario behavior.

The included [prototype.html](../../prototype.html) is a self-contained, responsive click-through designed around a 390 px mobile screen. It supports bill search and filters, required-field validation that retains entered values, bill details, reminder selection, partial/full payment recording with Undo, activity review, agenda/month calendar switching with date selection, and a five-day delayed-income scenario with Undo. The floating navigation, feature card, summary metrics, segmented controls, secondary actions, and Undo toast use layered glass effects; money values and labels remain high-contrast, with an opaque fallback for reduced-transparency settings. The phone frame includes a bezel, Dynamic Island, side keys, and home indicator. It is not connected to financial accounts or notification services, and neither the concept nor prototype has been user-tested. Sample data is fictional and uses Philippine pesos solely to make the prototype concrete; it is not a market claim.

## Figma page and frame setup

The selected Figma team allows three actual pages, so the eight documentation sections are grouped as named boards and frames:

1. **01 — Research + strategy:** research/evidence and product strategy/user-journey boards.
2. **02 — Structure + system:** information architecture/wireframes, design foundations/tokens, and component/state boards.
3. **03 — Screens + validation:** 13 primary mobile screens and three recovery states, each presented in an iPhone-style frame, plus the usability-testing and iteration board.

The screen artboards are 390×844 inside 414×872 device presentations with a dark bezel, Dynamic Island, and side controls. The frame names identify the screen/task; recovery states are separate named frames. The local HTML prototype is optimized for the same mobile width and also adapts to narrower screens.

## Click path inventory

| Flow | Start | Actions | Result / recovery |
|---|---|---|---|
| Add a recurring bill | Today or Bills | Add bill → name/amount/due date/frequency/reminder → Save | New bill appears in Bills and Today. Invalid required fields keep the draft and show inline errors. |
| View next deadline | Today | Open next due row → bill details | Due date, amount, status, recurrence, and reminder are visible. |
| Set a reminder | Bill detail | Reminder settings → choose lead time and privacy → Save | Confirmation describes schedule. Permission explanation precedes any system permission request in a native build. |
| Record a payment | Bill detail or Today | Record payment → amount/date → Confirm | Paid/partial state and history update. Toast offers Undo. |
| Review income vs. obligations | Today | Plan → agenda/month | Starting funds, received amounts, expected items, and obligations are differentiated by source/status. |
| Understand changing forecast | Plan | Open income event → move expected date | Affected dates and planned gap update with assumptions shown; Undo restores the original date. |
| Recover from error/action | Add or payment form | Submit incomplete form, or confirm then Undo | Validation retains entered values. Undo reverses only the latest occurrence record. |
| Review progress and insights | Activity | Review / History / Progress sections | Summary uses only known fictional events; progress stays optional and secondary. |

## Interaction wiring notes

Use the Today screen as the visual starting point. The Figma reactions navigate between named screen frames; the local HTML prototype supplies editable fields, state changes, validation, and recovery behavior. Primary Figma paths include Add a bill → Bill added, Today → Bill details → Reminder, Bill details → Record payment → Success/Undo, and Plan → delayed-income state → Undo or Review affected bills. Navigation labels connect the core Today, Plan, Bills, and Activity screens.

## Handoff content

The prototype and design package are separate from the existing Pinoy Fit Hub product code. The Figma design file is editable in Pj’s Company. Research evidence is secondary-source desk research; participant interviews and usability sessions remain planned work. No research outcome or usability claim is represented as validated.
