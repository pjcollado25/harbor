import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/harbor_sticky_scroll.dart';
import '../../../../shared/widgets/harbor_widgets.dart';
import '../../../ledger/domain/entities/ledger_entities.dart';
import '../../../ledger/presentation/cubit/ledger_cubit.dart';
import '../../domain/bill_money_status.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});
  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  String _filter = 'All';
  String _query = '';
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _addBill() async {
    await context.push('/bills/new');
    if (!mounted) return;
    _search.clear();
    setState(() {
      _filter = 'All';
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<LedgerCubit, LedgerState>(
    builder: (context, state) {
      final snapshot = state.snapshot;
      final bills = snapshot.bills.where((bill) {
        final status = _statusFor(snapshot, bill).label;
        return (_filter == 'All' ||
                (_filter == 'Open' ? status != 'Paid' : status == _filter)) &&
            bill.name.toLowerCase().contains(_query.toLowerCase());
      }).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return HarborStickyScrollView(
        title: 'Bills',
        subtitle: _listSubtitle(bills.length, snapshot.bills.length),
        trailing: IconButton.filledTonal(
          onPressed: _addBill,
          icon: const Icon(Icons.add_rounded),
          tooltip: 'Add bill',
        ),
        children: [
          TextField(
            controller: _search,
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
                  ? 'Add the obligations you want to keep track of. Drop27Payment stores them only on this device.'
                  : 'Try a different search or filter.',
              actionLabel: snapshot.bills.isEmpty ? 'Add a bill' : null,
              onAction: snapshot.bills.isEmpty ? _addBill : null,
            )
          else
            ...bills.map(
              (bill) => _BillListItem(
                bill: bill,
                status: _statusFor(snapshot, bill),
                currency: snapshot.preferences.currencyCode,
              ),
            ),
        ],
      );
    },
  );

  BillMoneyStatus _statusFor(LedgerSnapshot snapshot, Bill bill) {
    final paid = snapshot.payments
        .where((payment) => payment.billId == bill.id)
        .fold<int>(0, (sum, payment) => sum + payment.amount);
    return billMoneyStatus(bill, paid, DateTime.now());
  }

  String _listSubtitle(int shown, int total) {
    if (_query.isNotEmpty || _filter != 'All') {
      if (shown == 0) return 'No matching bills';
      return shown == 1 ? '1 bill' : '$shown bills';
    }
    return total == 1 ? '1 bill' : '$total bills';
  }
}

class _BillListItem extends StatelessWidget {
  const _BillListItem({
    required this.bill,
    required this.status,
    required this.currency,
  });
  final Bill bill;
  final BillMoneyStatus status;
  final String currency;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Semantics(
        button: true,
        excludeSemantics: true,
        label:
            '${bill.name}. ${status.label}. ${formatMoney(status.displayAmount, currency)}',
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
                        formatMoney(status.displayAmount, currency),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: status.isPaid
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
