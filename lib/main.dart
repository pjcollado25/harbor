import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'features/ledger/presentation/cubit/ledger_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await configureDependencies();
  final ledgerCubit = getIt<LedgerCubit>()..load();
  runApp(HarborApp(router: getIt(), ledgerCubit: ledgerCubit));
}
