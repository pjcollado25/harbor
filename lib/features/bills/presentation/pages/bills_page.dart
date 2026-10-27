import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/harbor_sticky_scroll.dart';
import '../../../../shared/widgets/harbor_widgets.dart';
import '../../../ledger/domain/entities/ledger_entities.dart';
import '../../../ledger/presentation/cubit/ledger_cubit.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});
  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  String _filter = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) => BlocBuilder<LedgerCubit, LedgerState>(
    builder: (context, state) {
      final snapshot = state.snapshot;
      final bills = snapshot.bills.where((bill) {
        final paid = snapshot.payments
            .where((payment) => payment.billId == bill.id)
            .fold<int>(0, (sum, payment) => sum + payment.amount);
        final status = paid >= bill.amount
            ? 'Paid'
            : bill.dueDate.isBefore(dateOnly(DateTime.now()))
            ? 'Overdue'
            : 'Upcoming';
        return (_filter == 'All' ||
                (_filter == 'Open' ? status != 'Paid' : status == _filter)) &&
            bill.name.toLowerCase().contains(_query.toLowerCase());
      }).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return HarborStickyScrollView(
        title: 'Bills',
        subtitle:
            '${snapshot.bills.length} listed obligation${snapshot.bills.length == 1 ? '' : 's'}',
        trailing: IconButton.filledTonal(
          onPressed: () => context.push('/bills/new'),
          icon: const Icon(Icons.add_rounded),
          tooltip: 'Add bill',
        ),
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Search bills',
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 13),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Open', 'Paid', 'Overdue']
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: _filter == filter,
                        onSelected: (_) => setState(() => _filter = filter),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          if (bills.isEmpty)
            HarborEmptyState(
              title: snapshot.bills.isEmpty
                  ? 'No bills yet'
                  : 'No matching bills',
              body: snapshot.bills.isEmpty
                  ? 'Add the obligations you want to keep track of. Harbor stores them only on this device.'
                  : 'Try a different search or filter.',
              actionLabel: snapshot.bills.isEmpty ? 'Add a bill' : null,
              onAction: snapshot.bills.isEmpty
                  ? () => context.push('/bills/new')
                  : null,
            )
          else
            ...bills.map(
              (bill) => _BillListItem(
                bill: bill,
                paid: snapshot.payments
                    .where((payment) => payment.billId == bill.id)
                    .fold<int>(0, (sum, payment) => sum + payment.amount),
                currency: snapshot.preferences.currencyCode,
              ),
            ),
        ],
      );
    },
  );
}

class _BillListItem extends StatelessWidget {
  const _BillListItem({
    required this.bill,
    required this.paid,
    required this.currency,
  });
  final Bill bill;
  final int paid;
  final String currency;
  @override
  Widget build(BuildContext context) {
    final remaining = (bill.amount - paid).clamp(0, bill.amount).toInt();
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        onTap: () => context.push('/bill/${bill.id}'),
        borderRadius: BorderRadius.circular(18),
        child: GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          radius: 18,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _categoryIcon(bill.category),
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatDate(bill.dueDate, year: true)} · ${bill.isEstimate ? 'Estimate' : bill.frequency.name}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: .62),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatMoney(remaining, currency),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      remaining == 0
                          ? 'Paid'
                          : paid > 0
                          ? 'Part paid'
                          : 'Due',
                      style: TextStyle(
                        fontSize: 11,
                        color: remaining == 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: .58),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _categoryIcon(String category) => switch (category.toLowerCase()) {
  'home' || 'rent' => Icons.home_outlined,
  'utilities' || 'internet' || 'power' => Icons.bolt_rounded,
  'transport' => Icons.directions_bus_outlined,
  _ => Icons.receipt_long_outlined,
};
