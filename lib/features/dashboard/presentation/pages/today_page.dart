import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/harbor_sticky_scroll.dart';
import '../../../../shared/widgets/obligation_row.dart';
import '../../../ledger/domain/entities/ledger_entities.dart';
import '../../../ledger/presentation/cubit/ledger_cubit.dart';
import '../../domain/today_plan_builder.dart';
import '../widgets/available_buffer_card.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<LedgerCubit, LedgerState>(
    builder: (context, state) {
      if (state.isLoading) {
        return const Scaffold(
          backgroundColor: _canvas,
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF8E8E93)),
          ),
        );
      }

      final snapshot = state.snapshot;
      final today = dateOnly(DateTime.now());
      final windowEnd = today.add(const Duration(days: 30));
      final bills = snapshot.bills.where((bill) {
        final due = dateOnly(bill.dueDate);
        return bill.isActive &&
            !due.isAfter(windowEnd) &&
            billRemaining(snapshot, bill) > 0;
      }).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      final nearTermBills = bills
          .where(
            (bill) => !dateOnly(
              bill.dueDate,
            ).isAfter(today.add(const Duration(days: 7))),
          )
          .toList();
      final nearTermAmount = nearTermBills.fold<int>(
        0,
        (total, bill) => total + billRemaining(snapshot, bill),
      );
      final bufferSubtitle = _bufferSubtitle(
        funds: snapshot.funds?.amount ?? 0,
        currencyCode: snapshot.preferences.currencyCode,
        bills: bills,
        nearTermBills: nearTermBills,
        nearTermAmount: nearTermAmount,
      );
      final rowCount = bills.isEmpty ? 1 : bills.length;

      return Scaffold(
        backgroundColor: _canvas,
        body: HarborStickyScrollView(
          title: 'Today',
          subtitle: DateFormat('EEEE, MMMM d').format(DateTime.now()),
          trailing: IconButton(
            onPressed: () => context.push('/bills/new'),
            tooltip: 'Add a bill',
            icon: const Icon(Icons.add_rounded),
          ),
          horizontalPadding: 20,
          bottomPadding: 126,
          expandedTitleSize: 30,
          collapsedTitleSize: 18,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              sliver: SliverToBoxAdapter(
                child: AvailableBufferCard(
                  amount: snapshot.funds?.amount ?? 0,
                  currencyCode: snapshot.preferences.currencyCode,
                  subtitle: bufferSubtitle,
                ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 30, 20, 12),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Upcoming obligations',
                  style: TextStyle(
                    color: Color(0xFFF2F2F7),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.builder(
                itemCount: rowCount + 1,
                itemBuilder: (context, billIndex) {
                  if (billIndex < rowCount) {
                    if (bills.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'No upcoming obligations',
                          style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 14,
                          ),
                        ),
                      );
                    }
                    final bill = bills[billIndex];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ObligationRow(
                        key: ValueKey(bill.id),
                        name: bill.name,
                        detail: _dueDescription(bill.dueDate, today),
                        amount: billRemaining(snapshot, bill),
                        currencyCode: snapshot.preferences.currencyCode,
                        category: bill.category,
                        onTap: () => context.push('/bill/${bill.id}'),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => context.push('/bills/new'),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add a bill'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFB0B0B8),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

String _dueDescription(DateTime dueDate, DateTime today) {
  final due = dateOnly(dueDate);
  if (due.isBefore(today)) return 'Overdue · ${formatDate(dueDate)}';
  if (due == today) return 'Due today';
  if (due == today.add(const Duration(days: 1))) return 'Due tomorrow';
  return 'Due ${formatDate(dueDate)}';
}

String _bufferSubtitle({
  required int funds,
  required String currencyCode,
  required List<Bill> bills,
  required List<Bill> nearTermBills,
  required int nearTermAmount,
}) {
  final billCount = bills.length;
  final countLabel =
      '$billCount ${billCount == 1 ? 'bill' : 'bills'} remaining';
  if (nearTermBills.isEmpty) {
    return '$countLabel · No bills due in the next 7 days';
  }
  if (funds <= 0) {
    return '$countLabel · Add starting funds to plan upcoming bills';
  }

  final dueThrough = nearTermBills
      .map((bill) => dateOnly(bill.dueDate))
      .reduce((a, b) => a.isAfter(b) ? a : b);
  final remaining = funds - nearTermAmount;
  final dueText = dueThrough.isBefore(dateOnly(DateTime.now()))
      ? 'overdue bills'
      : 'bills through ${DateFormat('EEEE').format(dueThrough)}';
  if (remaining >= 0) {
    return '$countLabel · Entered funds cover $dueText';
  }
  return '$countLabel · ${formatMoney(remaining.abs(), currencyCode)} short for $dueText';
}

const _canvas = Color(0xFF0A0A0A);
