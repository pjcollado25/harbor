import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/harbor_widgets.dart';
import '../../../ledger/domain/entities/ledger_entities.dart';
import '../../../ledger/presentation/cubit/ledger_cubit.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<LedgerCubit, LedgerState>(
    builder: (context, state) {
      final snapshot = state.snapshot;
      final today = dateOnly(DateTime.now());
      final openBills =
          snapshot.bills
              .where((bill) => bill.isActive && _remaining(snapshot, bill) > 0)
              .toList()
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      final next = openBills.isEmpty ? null : openBills.first;
      final next14 = openBills
          .where(
            (bill) =>
                bill.dueDate.difference(today).inDays <= 14 &&
                !bill.dueDate.isBefore(today),
          )
          .toList();
      final planned =
          (snapshot.funds?.amount ?? 0) +
          snapshot.incomes
              .where((income) => income.status == IncomeStatus.received)
              .fold<int>(0, (sum, income) => sum + income.amount) -
          openBills.fold<int>(
            0,
            (sum, bill) => sum + _remaining(snapshot, bill),
          );
      final expected =
          snapshot.incomes
              .where((income) => income.status != IncomeStatus.received)
              .toList()
            ..sort((a, b) => a.expectedDate.compareTo(b.expectedDate));
      if (state.isLoading)
        return const Center(child: CircularProgressIndicator());
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        children: [
          const _Wordmark(),
          const SizedBox(height: 16),
          Text(
            'Today',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatLongDate(today),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: .62),
            ),
          ),
          const SizedBox(height: 22),
          if (next == null)
            HarborEmptyState(
              title: 'Start with what’s due',
              body:
                  'Add a bill or expected payment to build your local plan. Your details stay on this device.',
              actionLabel: 'Add a bill',
              onAction: () => context.push('/bills/new'),
            )
          else ...[
            SectionLabel('Next due'),
            GlassPanel(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              next.name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${formatLongDate(next.dueDate)} · ${next.isEstimate ? 'Estimate' : 'Fixed amount'}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: .65),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Text(
                          formatMoney(
                            _remaining(snapshot, next),
                            snapshot.preferences.currencyCode,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  StatusTag(
                    next.dueDate.isBefore(today)
                        ? 'Overdue'
                        : 'Due in ${next.dueDate.difference(today).inDays} days',
                    icon: next.dueDate.isBefore(today)
                        ? Icons.error_outline_rounded
                        : Icons.calendar_today_rounded,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.push('/bill/${next.id}'),
                          child: const Text('View bill'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () =>
                              context.push('/bill/${next.id}/payment'),
                          child: const Text('Record payment'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          SectionLabel(
            'In the next 14 days',
            action: 'See all',
            onAction: () => context.go('/bills'),
          ),
          if (next14.isEmpty)
            const GlassPanel(
              child: Text(
                'Nothing is due in the next 14 days.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          else ...[
            for (final bill in next14.take(4))
              _BillPreview(
                bill: bill,
                amount: _remaining(snapshot, bill),
                currency: snapshot.preferences.currencyCode,
              ),
            const SizedBox(height: 4),
            Text(
              '${next14.length} bills · ${formatMoney(next14.fold<int>(0, (sum, bill) => sum + _remaining(snapshot, bill)), snapshot.preferences.currencyCode)} planned',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: .65),
              ),
            ),
          ],
          if (snapshot.funds != null) ...[
            const SizedBox(height: 22),
            SectionLabel('Planned after known commitments'),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatMoney(planned, snapshot.preferences.currencyCode),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${formatMoney(snapshot.funds!.amount, snapshot.preferences.currencyCode)} starting funds entered by you · ${formatDate(snapshot.funds!.asOf)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: .62),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'A plan estimate, not a bank balance.',
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          SectionLabel(
            'Expected income',
            action: 'Add',
            onAction: () => context.push('/income/new'),
          ),
          if (expected.isEmpty)
            GlassPanel(
              child: Row(
                children: [
                  const Icon(
                    Icons.south_west_rounded,
                    color: Color(0xFF73B3FF),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No expected payments yet. Add one to explore how a date change affects your plan.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )
          else
            for (final income in expected.take(3))
              _IncomePreview(
                income: income,
                currency: snapshot.preferences.currencyCode,
              ),
          if (snapshot.bills.isNotEmpty) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.push('/bills/new'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add a bill'),
            ),
          ],
        ],
      );
    },
  );

  static int _remaining(LedgerSnapshot snapshot, Bill bill) {
    final paid = snapshot.payments
        .where((payment) => payment.billId == bill.id)
        .fold<int>(0, (sum, payment) => sum + payment.amount);
    return (bill.amount - paid).clamp(0, bill.amount);
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(Icons.water_drop_rounded, color: Color(0xFF73B3FF), size: 16),
      const SizedBox(width: 6),
      Text(
        'HARBOR',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
    ],
  );
}

class _BillPreview extends StatelessWidget {
  const _BillPreview({
    required this.bill,
    required this.amount,
    required this.currency,
  });
  final Bill bill;
  final int amount;
  final String currency;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: InkWell(
      onTap: () => context.push('/bill/${bill.id}'),
      borderRadius: BorderRadius.circular(18),
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        radius: 18,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${formatDate(bill.dueDate)} · ${bill.isEstimate ? 'estimate' : bill.category}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: .6),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 2,
              child: Text(
                formatMoney(amount, currency),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    ),
  );
}

class _IncomePreview extends StatelessWidget {
  const _IncomePreview({required this.income, required this.currency});
  final IncomeEvent income;
  final String currency;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      radius: 18,
      child: Row(
        children: [
          const Icon(
            Icons.south_west_rounded,
            color: Color(0xFF73B3FF),
            size: 19,
          ),
          const SizedBox(width: 11),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  income.source,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  '${formatDate(income.expectedDate)} · ${income.status == IncomeStatus.clientSent ? 'Client says sent' : 'Expected'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: .6),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Text(
              formatMoney(income.amount, currency),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ),
  );
}
