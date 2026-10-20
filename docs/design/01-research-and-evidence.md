# 01 — Research and evidence

## Research boundary

This is desk research, not a completed discovery study. External findings are established only within the limits of their source. Product-specific needs such as desired forecast language, acceptable data entry burden, reminder timing, and the emotional effect of progress mechanics remain hypotheses until tested with target users. No primary interviews or usability sessions have been conducted for this concept.

Freelancing is not one labor market. Country, occupation, client type, payment platform, banking access, income level, household obligations, and tax rules all change the planning problem. “Independent worker” also includes people whose work is mediated by digital platforms; that population should not be treated as interchangeable with client-service freelancers.

## Evidence register

| Finding or claim | Source and date | Implication for product design | Confidence and remaining gaps |
|---|---|---|---|
| Financial account ownership and digital payment access vary substantially by country and population. Global Findex 2021 reported account ownership for 76% of adults globally, up from 68% in 2017. | World Bank, *The Global Findex Database 2021*, published July 2022. [Report](https://documents.worldbank.org/en/publication/documents-reports/documentdetail/099818107072234182) · [headline findings](https://www.worldbank.org/en/news/press-release/2022/06/29/covid-19-drives-global-surge-in-use-of-digital-payments) | Do not assume a connected bank account, one dominant payment rail, or universal access to push notifications. Support manual entry and make currency, date, and region preferences explicit. | **High** for the reported population and year. This is broad financial-inclusion context, not evidence about freelancer preferences or current access in every launch market. |
| Labor income volatility is not confined to platform work; in JPMorgan Chase Institute's U.S. account data, 86% of month-to-month take-home-pay volatility came from pay variation within distinct jobs. The report also found platform work was a secondary income source for most measured participants. | JPMorgan Chase Institute, *Paychecks, Paydays, and the Online Platform Economy*, 2019; high-frequency anonymized data from 1 million Chase customers (Oct 2012–Sep 2015) and 260,000 platform earners. [Report and methods](https://www.jpmorganchase.com/institute/all-topics/labor-markets-and-workforce/report-paychecks-paydays-and-the-online-platform-economy) | Forecasts should explain that timing and amounts can move, and avoid assuming every independent worker relies on a single full-time freelance income stream. Let users model more than one income source. | **High** within the sampled U.S. Chase population; **low** for global freelancers specifically. Old data and bank-customer selection limit generalization. |
| 32% of freelancers in IPSE's Q1 2024 Freelancer Confidence Index said a client had delayed payment in the previous 12 months. | IPSE, 2 May 2024, citing its Q1 2024 Freelancer Confidence Index. [Article](https://www.ipse.co.uk/articles/heres-how-clients-get-away-with-paying-freelancers-later) | An expected invoice must not be presented as spendable cash. Include a fast way to move an income event when it is delayed and show the downstream effect on planned obligations. | **Medium**: directly freelancer-specific and recent, but the article does not expose the full sampling frame or questionnaire; UK evidence only. |
| A cross-country survey reached more than 2,000 freelancers in 122 countries, but participants were all Payoneer customers. | Payoneer, *2023 Freelancer Insights Report*, published 2023. [Report overview and sampling note](https://www.payoneer.com/resources/business/the-payoneer-2023-freelancer-insights-report/) | Global research should combine sources and recruit outside one payment provider. Treat payment methods and income expectations as country-specific interview prompts. | **Medium** for sample reach; **low** for population representativeness because the provider recruited its own customers. The report overview alone does not validate product feature preferences. |
| Large personal-finance products already combine recurring bill lists or calendars, reminders, and payment tracking. Monarch describes calendar/list views and reminders; YNAB supports scheduled repeating transactions, while its support page says it does not offer a dedicated bill calendar. | Monarch recurring feature page (accessed 20 Oct 2026). [Monarch](https://www.monarchmoney.com/features/recurring) · YNAB support, “Scheduled Transactions,” updated 10 Jul 2026. [YNAB](https://support.ynab.com/scheduled-transactions-a-guide-BygrAIFA9) | A bill list alone is not distinctive. Differentiate around a legible timeline that relates **actual funds**, **expected income**, and obligations, with explicit confidence and editability. | **High** for public feature descriptions; **low** as evidence of customer satisfaction or unmet demand. Feature sets change. |
| Invoice/accounting software focuses on invoicing, receivables, and business records; it is adjacent to but not identical with household obligation planning. | Product-category observation; verify in market interviews. Wave product overview (accessed 20 Oct 2026). [Wave](https://www.waveapps.com/) | Keep the MVP focused on “what is due and when can I responsibly plan for it?” rather than rebuilding invoicing, tax preparation, bookkeeping, or invoice chasing. | **Medium** as a category distinction; needs a live competitor audit and user workflow interviews before positioning is locked. |

### Facts, hypotheses, and validated findings

- **Established external facts:** only the source-scoped claims in the evidence register.
- **Product hypotheses:** users will prefer a cash-flow companion over a standalone bill tracker; they will understand three income states; a dated “what changed?” explanation will earn trust; manual inputs can be light enough for weekly use.
- **Validated through Harbor research:** none. No participant data exists yet.

## Market and workflow questions still open

Research next across at least three contrasts: (1) client-service freelancers vs. platform workers, (2) one predictable retainer vs. many variable projects, and (3) one local currency/payment rail vs. cross-border payouts and conversion. Ask how work is invoiced and paid, how delayed payments are noticed, what is recorded where, how obligations are timed, and what decisions users make when income slips. Do not infer these answers from account-ownership statistics.

## Competitor landscape and opportunity

| Category / example | Existing strength | Gap to investigate |
|---|---|---|
| Broad personal-finance managers (e.g. Monarch) | Aggregated account views, recurring bill calendars/lists, reminders, reports. | Does a user with volatile income understand whether the forecast includes cash already received or only projected events? How well do tools work when account linking is unavailable or undesired? |
| Envelope / zero-based planners (e.g. YNAB) | Repeating transactions and a method for assigning money as it arrives; adaptable to variable pay cycles. | Can the user quickly see the dated relationship between uncertain client payment timing and due dates without reconstructing it across registers/categories? A dedicated bill calendar is not listed in YNAB's support material. |
| Invoicing and accounting tools (e.g. Wave) | Client invoices, payment collection workflows, and business records. | They may not be the preferred place for household bills, reminder control, or a calm personal “next decision” view. Validate rather than assume. |

**Opportunity hypothesis:** join the planning gap between “invoice expected” and “bill due” using an explainable calendar and cash-flow range. User controls estimates. Every forecast change identifies the source event and its confidence. The product does not promise to predict a client's payment date.

## Visual references to study

These are references for interaction qualities, not templates to copy.

1. **Monarch recurring view** — learn from offering both a scan-friendly list and calendar for the same obligations, and exposing reminders in context. Avoid its broad wealth-dashboard scope for this MVP. [Reference](https://www.monarchmoney.com/features/recurring)
2. **YNAB scheduled transactions** — learn from direct control over repeat frequency and manual correction when reality differs from the plan. Avoid importing its budgeting vocabulary where a new user only needs to know what is due next. [Reference](https://support.ynab.com/scheduled-transactions-a-guide-BygrAIFA9)
3. **Apple Calendar** — study its familiar month/agenda switch, date navigation, and event scan patterns as a platform convention; use only after reviewing the current mobile UI on the target device during Figma production. [Product page](https://www.apple.com/ios/calendar/)

