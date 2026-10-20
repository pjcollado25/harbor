# Harbor

Harbor is an offline-first Flutter companion for planning bills around irregular income. It stores information on device and does not connect to banks or payment services.

## Run locally

Requires Flutter 3.38.1 or newer and Dart 3.12.2 as configured in `pubspec.yaml`.

```sh
flutter pub get
flutter run
```

The app opens in dark mode with a near-black background, blue accents, and a floating glass navigation bar. Its five destinations are Today, Bills, Plan, Activity, and Settings. Settings is represented by a gear icon and the bottom navigation has no visible labels; accessibility labels remain available.

## Capabilities

- Track bills and expected income locally, including bill estimates, recurring cadence, and reminders.
- View upcoming obligations and a monthly or agenda plan.
- Record and undo payments, and adjust an expected income date when it is delayed.
- Set starting funds, currency, optional buffer goal, privacy options, and theme.
- Export a local JSON snapshot or clear Harbor's local data.

## Project structure

- `lib/core/` — dependency setup, navigation, theme, notifications, formatting, and shared UI primitives.
- `lib/features/ledger/` — ledger entities, repository, Hive persistence, use cases, and Cubit state.
- `lib/features/*/presentation/` — Today, Bills, Plan, Activity, and Settings screens.
- `lib/shared/` — reusable app shell and glass components.
- `test/` — unit, bloc, and widget tests.
- `docs/design/` — the eight design and research documents.
- `docs/architecture/` — implementation, persistence, and verification notes.
- `prototype.html` — standalone interactive HTML prototype for comparison.

## Documentation

- [Design package index](docs/design/README.md)
- [Architecture and implementation](docs/architecture/implementation-plan.md)
- [Local data and migrations](docs/architecture/local-data-and-migrations.md)
- [Verification guide](docs/architecture/verification.md)

## Verify

```sh
dart format lib test
flutter analyze
flutter test
```
