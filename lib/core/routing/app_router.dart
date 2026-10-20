import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/activity/presentation/pages/activity_page.dart';
import '../../features/bills/presentation/pages/bill_detail_page.dart';
import '../../features/bills/presentation/pages/bill_form_page.dart';
import '../../features/bills/presentation/pages/bills_page.dart';
import '../../features/bills/presentation/pages/payment_form_page.dart';
import '../../features/dashboard/presentation/pages/today_page.dart';
import '../../features/ledger/domain/entities/ledger_entities.dart';
import '../../features/ledger/presentation/cubit/ledger_cubit.dart';
import '../../features/plan/presentation/pages/income_form_page.dart';
import '../../features/plan/presentation/pages/plan_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../shared/widgets/harbor_shell.dart';

GoRouter createAppRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute(
      builder: (context, state, shell) => HarborShell(navigationShell: shell),
      navigatorContainerBuilder: (context, shell, children) =>
          _FadingBranchContainer(
            currentIndex: shell.currentIndex,
            children: children,
          ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const TodayPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/plan',
              builder: (context, state) => const PlanPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bills',
              builder: (context, state) => const BillsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/activity',
              builder: (context, state) => const ActivityPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/bills/new',
      builder: (context, state) => const BillFormPage(),
    ),
    GoRoute(
      path: '/bill/:id',
      builder: (context, state) =>
          BillDetailPage(billId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/bill/:id/edit',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final extra = state.extra;
        final bills = context.read<LedgerCubit>().state.snapshot.bills.where(
          (bill) => bill.id == id,
        );
        final bill = extra is Bill
            ? extra
            : bills.isEmpty
            ? null
            : bills.first;
        return bill == null
            ? const _MissingRoute(title: 'Bill not found')
            : BillFormPage(bill: bill);
      },
    ),
    GoRoute(
      path: '/bill/:id/payment',
      builder: (context, state) =>
          PaymentFormPage(billId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/income/new',
      builder: (context, state) => const IncomeFormPage(),
    ),
  ],
  errorBuilder: (context, state) =>
      _MissingRoute(title: 'Page not found', message: state.error?.toString()),
);

class _FadingBranchContainer extends StatefulWidget {
  const _FadingBranchContainer({
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  State<_FadingBranchContainer> createState() => _FadingBranchContainerState();
}

class _FadingBranchContainerState extends State<_FadingBranchContainer> {
  @override
  Widget build(BuildContext context) => ClipRect(
    child: Stack(
      children: [
        for (var index = 0; index < widget.children.length; index++)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: index == widget.currentIndex ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: AnimatedScale(
                scale: index == widget.currentIndex ? 1 : .99,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: IgnorePointer(
                  ignoring: index != widget.currentIndex,
                  child: TickerMode(
                    enabled: index == widget.currentIndex,
                    child: widget.children[index],
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _MissingRoute extends StatelessWidget {
  const _MissingRoute({required this.title, this.message});
  final String title;
  final String? message;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (message != null) Text(message!),
            const SizedBox(height: 12),
            FilledButton(onPressed: context.pop, child: const Text('Go back')),
          ],
        ),
      ),
    ),
  );
}
