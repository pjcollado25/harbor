# 08 — Usability testing and iteration

## Research plan

### Discovery interviews

Run 8–10 moderated 45-minute interviews as a first qualitative pass. Recruit client-service freelancers who personally manage recurring household bills and have variable payment dates. Include a mix of occupations, income stability, ages, disability/accessibility needs, payment rails, and household responsibilities. Include at least two people with cross-border clients and at least two platform workers as contrast cases; do not merge their findings into the primary segment without evidence.

Ask participants to walk through the last time an expected payment moved, how they knew a bill was due, what they currently check, what they do when cash and commitments do not line up, and what they trust in a forecast. Use recent examples, not hypothetical preference questions. Do not ask for account credentials or collect exact balances unless essential and consented.

### Usability round 1

After interview synthesis, test a low-fidelity prototype with 5–6 participants from the primary segment. Moderate remotely or in person, 45–60 minutes, using realistic tasks and fictional values. Ask participants to think aloud, but score task completion independently of facilitator prompts.

### Iterate, then round 2

Prioritize issues by severity, frequency, and harm if misunderstood. Revise the prototype. Repeat with 5–6 participants, including people who did not see the first version where possible. A later quantitative claim needs an appropriately recruited, powered sample; these small rounds identify usability problems and do not estimate population rates.

## Task script

1. “You have a monthly internet bill due next week. Add it with a reminder three days before.”
2. “You are checking what needs attention. Show the next payment and tell me when it is due.”
3. “Your client expected to pay this week says the transfer will arrive five days later. Show me what changes in your plan.”
4. “The rent payment has left your account. Record it, then undo it because you selected the wrong amount.”
5. “A bill reminder appears on your phone while it is locked. Find where you would change how much detail it reveals.”
6. “Review what you have recorded this month. Tell me which income is already received and which is still only expected.”
7. “Look at the progress area. Tell me whether missing a goal or a week causes a penalty.”

Do not give hints about the difference between actual and expected until the comprehension question is asked.

## Success criteria, set before sessions

| Measure | Round 1 target | What to record |
|---|---|---|
| Task completion | At least 5 of 6 participants complete each critical task without moderator help. | Complete / partial / not completed; assistance and workaround. |
| Critical error | Zero participants treat expected income as cash already received after reading the dashboard/forecast. | Participant explanation and screen path. Any instance blocks release of that concept pending revision. |
| Status comprehension | At least 5 of 6 correctly explain Expected, Client says sent, Received, and user-entered starting funds. | Verbatim paraphrase; label confusion. |
| Bill entry | At least 5 of 6 create a recurring bill with correct amount, date, frequency, and reminder. | Field errors, validation, time, backtracking. |
| Payment recovery | At least 5 of 6 record and reverse/correct the intended payment without losing unrelated bill data. | Mis-taps, accidental deletion concerns, confidence in recovery. |
| Forecast comprehension | At least 5 of 6 identify the changed event, affected obligation date, and assumptions/source snapshot. | Correct/incorrect explanation and missing assumptions. |
| Emotional safety | No repeated shame/blame interpretation; any such reaction is reviewed before next round. | Language, tone, participant comments; do not infer wellbeing impact from a short test. |
| Friction | Median completion time under 2 minutes for bill creation and under 90 seconds for recording a payment after the correct bill is open. | Time on task; treat as directional, not a benchmark claim. |

Targets are decision thresholds for this concept test, not evidence already achieved or industry standards.

## Observation sheet

For each participant, capture consented audio/video or detailed notes, participant code and relevant segment traits, task completion, time on task, errors, first-click path, backtracking, comprehension answers, emotional signals, and direct quotes. Separate observed behavior from interpretation. Avoid recording financial data not needed for the task. Delete recordings on the agreed retention schedule.

## Analysis and iteration backlog

1. **P0 — Prevent expected income from reading as available cash.** Add explicit source/status labels, date, and “planned estimate” wording; remove residual estimate if starting funds/commitments are incomplete.
2. **P0 — Make correction safe.** Keep Undo available after recording, clarify series vs. one occurrence edits, and preserve draft values on error.
3. **P1 — Reduce setup effort.** Simplify first-run setup only after observed friction; evaluate adding the highest-frequency bill first.
4. **P1 — Improve calendar scanning.** Test Agenda as default and use event text/shape in month view for overlapping items.
5. **P1 — Make reminder privacy legible.** Test lock-screen preview comprehension and permission timing.
6. **P2 — Validate progress content.** Remove or retain optional goal/patterns based on observed pressure and usefulness; no streaks.
7. **P2 — Validate regional scope.** Decide currency conversion, date localization, payment rail, and data protection needs by launch market before technical design.

## Reporting standard

After each round, report participant count and recruitment criteria, method, tasks, completion/errors/time/comprehension, themes with evidence, limitations, and the specific design changes made. Until those sessions happen, the design remains a **research-informed, unvalidated concept**; do not describe it as user-friendly, proven, or validated.
