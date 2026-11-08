import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/harbor_sticky_scroll.dart';
import '../../../ledger/presentation/cubit/ledger_cubit.dart';
import '../../domain/day_plan_item.dart';
import '../../domain/today_plan_builder.dart';
import '../widgets/harbor_day_view.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = dateOnly(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LedgerCubit, LedgerState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final snapshot = state.snapshot;
        final weekDays = weekDatesFor(_selectedDay);
        final daysWithItems = weekDays
            .map(dateOnly)
            .where((day) => dayHasItems(snapshot, day))
            .toSet();
        final items = dayItemsFor(snapshot, _selectedDay);
        final upcoming = nearestUpcoming(snapshot, _selectedDay);

        return Stack(
          children: [
            HarborStickyScrollView(
              title: harborDayPrimaryTitle(_selectedDay),
              subtitle: harborDaySecondaryLine(_selectedDay),
              keepSubtitleWhenCollapsed: true,
              titleFontWeight: FontWeight.w500,
              expandedTitleSize: 20,
              collapsedTitleSize: 16,
              leading: const HarborBrandRow(),
              bottomPadding: dayListBottomPadding(context),
              children: [
                HarborDayView(
                  selectedDay: _selectedDay,
                  weekDays: weekDays,
                  daysWithItems: daysWithItems,
                  items: items,
                  currencyCode: snapshot.preferences.currencyCode,
                  onSelectDay: (day) => setState(() => _selectedDay = day),
                  onAddBill: () => context.push('/bills/new'),
                  onPlanAhead: () => context.push('/bills/new'),
                  upcoming: upcoming,
                  onItemTap: (item) => _openItem(context, item),
                  showBrand: false,
                  showDateHeader: false,
                  showAddBillButton: false,
                ),
              ],
            ),
            Positioned(
              right: 20,
              bottom: MediaQuery.paddingOf(context).bottom + dayFabBottomGap,
              child: HarborAddBillButton(
                expanded: false,
                onPressed: () => context.push('/bills/new'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openItem(BuildContext context, DayPlanItem item) {
    if (item.id.startsWith('bill:')) {
      context.push('/bill/${item.id.substring(5)}');
    } else if (item.id.startsWith('income:')) {
      context.push('/income/new');
    }
  }
}
