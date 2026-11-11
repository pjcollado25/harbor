import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/obligation_row.dart';
import '../../../ledger/domain/entities/ledger_entities.dart';
import '../../../ledger/presentation/cubit/ledger_cubit.dart';
import '../../domain/bill_money_status.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  static const _filters = ['All', 'Open', 'Paid', 'Overdue'];

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
      final empty = bills.isEmpty;

      return Scaffold(
        backgroundColor: _canvas,
        body: SafeArea(
          bottom: false,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 126),
            itemCount: 3 + (empty ? 1 : bills.length),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _BillsHeading(
                  subtitle: _listSubtitle(bills.length, snapshot.bills.length),
                  onAddBill: _addBill,
                );
              }
              if (index == 1) {
                return Padding(
                  padding: const EdgeInsets.only(top: 22),
                  child: TextField(
                    controller: _search,
                    onChanged: (value) => setState(() => _query = value),
                    style: const TextStyle(
                      color: Color(0xFFF2F2F7),
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: _surface,
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF8E8E93),
                      ),
                      hintText: 'Search bills',
                      hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                );
              }
              if (index == 2) {
                return Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 12),
                  child: _BillFilters(
                    filters: _filters,
                    selected: _filter,
                    onSelected: (filter) => setState(() => _filter = filter),
                  ),
                );
              }
              if (empty) {
                return _EmptyBills(
                  noBills: snapshot.bills.isEmpty,
                  onAddBill: _addBill,
                );
              }

              final bill = bills[index - 3];
              final status = _statusFor(snapshot, bill);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ObligationRow(
                  key: ValueKey(bill.id),
                  name: bill.name,
                  detail: _billDetail(bill, status),
                  amount: status.displayAmount,
                  currencyCode: snapshot.preferences.currencyCode,
                  category: bill.category,
                  onTap: () => context.push('/bill/${bill.id}'),
                ),
              );
            },
          ),
        ),
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

class _BillsHeading extends StatelessWidget {
  const _BillsHeading({required this.subtitle, required this.onAddBill});
  final String subtitle;
  final VoidCallback onAddBill;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bills',
              style: TextStyle(
                color: Color(0xFFF2F2F7),
                fontSize: 30,
                fontWeight: FontWeight.w700,
                letterSpacing: -.7,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
            ),
          ],
        ),
      ),
      IconButton(
        onPressed: onAddBill,
        tooltip: 'Add bill',
        icon: const Icon(Icons.add_rounded),
        color: const Color(0xFFF2F2F7),
      ),
    ],
  );
}

class _BillFilters extends StatelessWidget {
  const _BillFilters({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final filter in filters)
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () => onSelected(filter),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: selected == filter
                        ? const Color(0xFFF2F2F7)
                        : const Color(0xFF8E8E93),
                    fontSize: 14,
                    fontWeight: selected == filter
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _EmptyBills extends StatelessWidget {
  const _EmptyBills({required this.noBills, required this.onAddBill});
  final bool noBills;
  final VoidCallback onAddBill;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          noBills ? 'No bills yet' : 'No matching bills',
          style: const TextStyle(
            color: Color(0xFFF2F2F7),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          noBills
              ? 'Add the bills you want to keep track of.'
              : 'Try a different search or filter.',
          style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
        ),
        if (noBills)
          TextButton(onPressed: onAddBill, child: const Text('Add a bill')),
      ],
    ),
  );
}

String _billDetail(Bill bill, BillMoneyStatus status) {
  final due = formatDate(bill.dueDate);
  return switch (status.label) {
    'Paid' => 'Paid · $due',
    'Overdue' => 'Overdue · $due',
    _ => 'Due $due',
  };
}

const _canvas = Color(0xFF0A0A0A);
const _surface = Color(0xFF121214);
