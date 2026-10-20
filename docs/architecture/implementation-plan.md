# Architecture and implementation

## Product boundary

Harbor is a personal cash-flow planning app for people with irregular income. The current app works without accounts, backend services, or network access. It helps a person record what they expect to receive, compare it with upcoming bills, record payments, and keep a small cash buffer in mind. Amounts and dates remain editable estimates; an expected payment is not treated as cash received.

## Structure

The app uses a feature-first layout with a domain/data/presentation split for the ledger:

- **Domain:** immutable ledger entities, repository and reminder interfaces, and validation/business use cases.
- **Data:** Hive models and adapters, a local data source, and a repository that maps persistence errors to `Result` failures.
- **Presentation:** one `LedgerCubit` exposes ledger state and operations to feature screens.
- **Core:** GetIt registration, `go_router` navigation, theme, formatting, error result types, and local notification scheduling.
- **Shared UI:** glass surfaces and the app shell with the five icon-only destinations.

Screens are grouped under `lib/features/` by user-facing destination. This keeps navigation and visual components independent from storage details while allowing the Today, Bills, Plan, Activity, and Settings screens to share one local ledger state.

## Main flows

1. At startup, Hive is initialized, adapters and boxes are registered, dependencies are configured, and the ledger Cubit loads a snapshot.
2. Screens submit changes through Cubit methods. Use cases validate values before repository operations.
3. The repository maps domain entities to Hive models. A successful mutation reloads the ledger snapshot so all destinations stay in sync.
4. Bill reminders are scheduled through a local notification interface. Permission is requested by the user from Settings; notification content follows the privacy preference.
5. Settings can export a JSON snapshot or clear local ledger and settings data.

## Design direction

Follow the latest product direction in the design docs and current prototype: iPhone-centered layouts, dark mode by default, black/near-black surfaces, blue accent, and a restrained floating glass bottom bar. Keep bottom navigation icon-only while preserving accessible names and tooltips. Settings uses a gear icon. Glass is limited to navigation and selected summary surfaces so text remains readable.

## Scope notes

All financial information is entered manually and remains on device. Local notifications are reminders only; they do not make or confirm payments. The current ledger models a bill's cadence, but each bill has one current due date and payment totals are attached to that bill record. Advancing a paid recurring bill into a new dated occurrence is a future enhancement. Do not imply that the current prototype provides a full accounting or forecasting engine.
