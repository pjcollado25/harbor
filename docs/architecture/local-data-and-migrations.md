# Local data and migrations

## Storage boundary

Harbor persists the ledger locally with Hive. No bank connection, cloud sync, analytics upload, or payment integration is configured. The app currently opens these versioned boxes:

| Box | Contents |
| --- | --- |
| `harbor_bills_v1` | Bill name, amount, due date, cadence, category, estimate flag, reminder lead time, and active flag |
| `harbor_income_v1` | Income source, expected amount/date, status, and optional received date |
| `harbor_payments_v1` | Payment amount/date and associated bill ID |
| `harbor_settings_v1` | Starting funds, preferences, and optional buffer goal |

The UI export serializes the current snapshot for the user. Settings has an explicit confirmation before clearing all local boxes.

## Adapter contracts

Hive adapters are hand-written in `lib/features/ledger/data/models/ledger_models.dart` and registered in `lib/core/di/injection.dart`:

| Model | Adapter type ID | Field indexes |
| --- | ---: | --- |
| `BillModel` | 0 | 0–8 |
| `IncomeModel` | 1 | 0–5 |
| `PaymentModel` | 2 | 0–4 |

Field indexes and type IDs are persistence contracts. Do not reuse an ID or change an existing index's meaning. Add new fields at a new index and give reads a safe default, following the existing nullable/default patterns. Changing a model's meaning or removing a field needs a deliberate migration.

## Migration approach

The current `_v1` box names establish the first storage schema; there is not yet an automatic migration runner. Before releasing an incompatible schema change:

1. Add a versioned migration step that reads the old box and writes the new representation.
2. Preserve the old data until the new box has been written and verified.
3. Make migration safe to retry after an interrupted app launch.
4. Add migration tests covering existing records, optional fields, and empty boxes.
5. Remove old boxes only after a successful migration and after the retention behavior is understood.

For additive Hive fields, keep the existing type ID and indexes and append the new field index. For a breaking model conversion, prefer a new box version and an explicit converter over silently interpreting old bytes using a new schema.

## Privacy and notifications

Reminder scheduling uses the device notification service only. The privacy setting controls whether local reminder content includes bill details. Data export and deletion are user-initiated from Settings. Any future sync or backup feature requires a separate product and privacy design; it is outside this local-only implementation.
