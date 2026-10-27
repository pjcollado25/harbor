import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/harbor_sticky_scroll.dart';
import '../../../../shared/widgets/harbor_widgets.dart';
import '../../../ledger/domain/entities/ledger_entities.dart';
import '../../../ledger/presentation/cubit/ledger_cubit.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<LedgerCubit, LedgerState>(
    builder: (context, state) {
      final snapshot = state.snapshot;
      final payments = [...snapshot.payments]
        ..sort((a, b) => b.date.compareTo(a.date));
      final received =
          snapshot.incomes
              .where((income) => income.status == IncomeStatus.received)
              .toList()
            ..sort(
              (a, b) => (b.receivedDate ?? b.expectedDate).compareTo(
                a.receivedDate ?? a.expectedDate,
              ),
            );
      final monthTotal = payments
          .where(
            (payment) =>
                payment.date.month == DateTime.now().month &&
                payment.date.year == DateTime.now().year,
          )
          .fold<int>(0, (sum, payment) => sum + payment.amount);
      final recurringTotal = snapshot.bills
          .where(
            (bill) => bill.isActive && bill.frequency != BillFrequency.once,
          )
          .fold<int>(0, (sum, bill) => sum + bill.amount);
      return HarborStickyScrollView(
        title: 'Activity',
        subtitle: 'Payments and income you recorded',
        children: [
          SectionLabel('This month'),
          Row(
            children: [
              Expanded(
                child: GlassPanel(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payments',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        formatMoney(
                          monthTotal,
                          snapshot.preferences.currencyCode,
                        ),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${payments.length} entries',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: .58),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlassPanel(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Known monthly bills',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        formatMoney(
                          recurringTotal,
                          snapshot.preferences.currencyCode,
                        ),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Listed recurring amounts',
                        style: context.harborMutedText(
                          alpha: 0.54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionLabel('Recorded payments'),
          if (payments.isEmpty)
            const HarborEmptyState(
              title: 'No payments recorded',
              body: 'When you record a bill payment, it will appear here.',
            )
          else
            ...payments.take(12).map((payment) {
              final bills = snapshot.bills.where(
                (bill) => bill.id == payment.billId,
              );
              final name = bills.isEmpty ? 'Bill' : bills.first.name;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  radius: 18,
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 19,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${formatDate(payment.date, year: true)} · recorded by you',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: .6),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Text(
                          formatMoney(
                            payment.amount,
                            snapshot.preferences.currencyCode,
                          ),
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
            }),
          if (received.isNotEmpty) ...[
            const SizedBox(height: 18),
            SectionLabel('Income marked received'),
            ...received.map(
              (income) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  radius: 18,
                  child: Row(
                    children: [
                      Icon(
                        Icons.south_west_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 19,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              income.source,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Marked received by you · ${formatDate(income.receivedDate ?? income.expectedDate)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: .6),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Text(
                          formatMoney(
                            income.amount,
                            snapshot.preferences.currencyCode,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SectionLabel('Your plan, your pace'),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Optional buffer goal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  snapshot.bufferGoal == null
                      ? 'Set a personal amount if it helps. No streaks or penalties.'
                      : 'Your entered goal is ${formatMoney(snapshot.bufferGoal!, snapshot.preferences.currencyCode)}.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: .65),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => _editGoal(context, snapshot.bufferGoal),
                      child: Text(
                        snapshot.bufferGoal == null ? 'Set goal' : 'Edit goal',
                      ),
                    ),
                    if (snapshot.bufferGoal != null)
                      TextButton(
                        onPressed: () =>
                            context.read<LedgerCubit>().saveBufferGoal(null),
                        child: const Text('Remove'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    },
  );

  Future<void> _editGoal(BuildContext context, int? current) async {
    final controller = TextEditingController(text: current?.toString() ?? '');
    final amount = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Optional buffer goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '₱ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (amount != null && context.mounted)
      await context.read<LedgerCubit>().saveBufferGoal(amount);
  }
}
