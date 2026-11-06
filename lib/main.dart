import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'features/ledger/data/datasources/ledger_local_data_source.dart';
import 'features/ledger/data/demo_ledger_seed.dart';
import 'features/ledger/presentation/cubit/ledger_cubit.dart';

/// Set via `scripts/run_simulator_with_demo.sh` — not used in normal app runs.
const _seedDemo = bool.fromEnvironment('HARBOR_SEED_DEMO');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await configureDependencies();
  if (kDebugMode && _seedDemo) {
    await writeGeneratedDemoLedger(
      getIt<LedgerLocalDataSource>(),
      replace: true,
    );
  }
  final ledgerCubit = getIt<LedgerCubit>()..load();
  runApp(HarborApp(router: getIt(), ledgerCubit: ledgerCubit));
}
