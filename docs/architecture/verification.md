# Verification

Run these commands from the repository root:

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
```

For an iOS simulator build, open an installed simulator and run `flutter run -d <simulator-id>`. For a release device build, configure the normal Apple signing team and run `flutter build ios`; signing is machine-specific.

The persistence adapters are hand-written, so code generation is not part of the build. Dependency injection is registered in `lib/core/di/injection.dart`.

## Test coverage

Keep tests close to the layer they verify:

- `test/unit/` — use case validation, entity calculations, repository and adapter behavior.
- `test/bloc/` — loading, successful mutations, failures, and undo through `LedgerCubit`.
- `test/widget/` — critical screen rendering and user actions with a controlled local repository.

The first unit tests cover bill validation and input normalization. Expand coverage as each feature is changed, especially around payment limits, delayed income, reminder privacy, data clearing, and schema migrations.
