import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/harbor_widgets.dart';
import '../../../ledger/domain/entities/ledger_entities.dart';
import '../../../ledger/presentation/cubit/ledger_cubit.dart';

class BillDetailPage extends StatelessWidget {
  const BillDetailPage({super.key, required this.billId});
  final String billId;

  @override
  Widget build(BuildContext context) => BlocBuilder<LedgerCubit, LedgerState>(
    builder: (context, state) {
      final matches = state.snapshot.bills.where((bill) => bill.id == billId);
      if (matches.isEmpty)
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('This bill is no longer available.')),
        );
      final bill = matches.first;
      final payments =
          state.snapshot.payments
              .where((payment) => payment.billId == bill.id)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));
      final paid = payments.fold<int>(
        0,
        (sum, payment) => sum + payment.amount,
      );
      final remaining = (bill.amount - paid).clamp(0, bill.amount).toInt();
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: context.pop,
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
          ),
          title: const Text('Bill details'),
          actions: [
            IconButton(
              onPressed: () =>
                  context.push('/bill/${bill.id}/edit', extra: bill),
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit bill',
            ),
            IconButton(
              onPressed: () => _delete(context, bill),
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete bill',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            ScreenHeading(title: bill.name, subtitle: bill.category),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next due',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: .6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatDate(bill.dueDate, year: true),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    formatMoney(
                      remaining,
                      state.snapshot.preferences.currencyCode,
                    ),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${bill.isEstimate ? 'Estimated' : 'Fixed'} amount · ${bill.frequency.name}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: .6),
                    ),
                  ),
                  if (paid > 0) ...[
                    const SizedBox(height: 14),
                    Text(
                      '${formatMoney(paid, state.snapshot.preferences.currencyCode)} recorded toward this bill',
                    ),
                  ],
                  const SizedBox(height: 14),
                  StatusTag(
                    remaining == 0
                        ? 'Paid by your entry'
                        : bill.dueDate.isBefore(dateOnly(DateTime.now()))
                        ? 'Overdue'
                        : 'Upcoming',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reminder',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    bill.reminderDays == 0
                        ? 'No reminder'
                        : '${bill.reminderDays} ${bill.reminderDays == 1 ? 'day' : 'days'} before · saved on this device',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: .65),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            if (remaining > 0)
              FilledButton.icon(
                onPressed: () => context.push('/bill/${bill.id}/payment'),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Record payment'),
              ),
            const SizedBox(height: 18),
            const SectionLabel('Payment history'),
            if (payments.isEmpty)
              GlassPanel(
                child: Text(
                  'No payments recorded yet.',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: .65),
                  ),
                ),
              )
            else
              ...payments.map(
                (payment) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassPanel(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 13,
                    ),
                    radius: 18,
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(formatDate(payment.date, year: true)),
                        ),
                        Text(
                          formatMoney(
                            payment.amount,
                            state.snapshot.preferences.currencyCode,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Text(
              'You entered these details. Harbor has not verified them with a bank.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: .55),
              ),
            ),
          ],
        ),
      );
    },
  );

  Future<void> _delete(BuildContext context, Bill bill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${bill.name}?'),
        content: const Text(
          'This removes the bill and its local payment history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final ok = await context.read<LedgerCubit>().deleteBill(bill);
    if (context.mounted && ok) context.pop();
  }
}
