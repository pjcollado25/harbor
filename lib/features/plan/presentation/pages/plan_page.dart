import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/harbor_sticky_scroll.dart';
import '../../../../shared/widgets/harbor_widgets.dart';
import '../../../bills/domain/bill_money_status.dart';
import '../../../ledger/domain/entities/ledger_entities.dart';
import '../../../ledger/presentation/cubit/ledger_cubit.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});
  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  bool _monthView = false;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = dateOnly(DateTime.now());
  IncomeEvent? _previewIncome;

  @override
  Widget build(BuildContext context) => BlocBuilder<LedgerCubit, LedgerState>(
    builder: (context, state) {
      final snapshot = state.snapshot;
      final events = <_PlanEvent>[
        ...snapshot.bills
            .where((bill) => bill.isActive)
            .where((bill) {
              final paid = snapshot.payments
                  .where((payment) => payment.billId == bill.id)
                  .fold<int>(0, (sum, payment) => sum + payment.amount);
              return !billMoneyStatus(bill, paid, DateTime.now()).isPaid;
            })
            .map(
              (bill) => _planBill(snapshot, bill, () {
                context.push('/bill/${bill.id}');
              }),
            ),
        ...snapshot.incomes.map(
          (income) => _PlanEvent(
            date: _shownIncomeDate(income),
            title: income.source,
            subtitle: _incomeStatus(income.status),
            amount: income.amount,
            isIncome: true,
            onTap: () => _showIncomeActions(context, income),
          ),
        ),
      ]..sort((a, b) => a.date.compareTo(b.date));
      final selectedEvents = events
          .where(
            (event) =>
                event.date.year == _selectedDay.year &&
                event.date.month == _selectedDay.month &&
                event.date.day == _selectedDay.day,
          )
          .toList();
      final expectedIncomes =
          snapshot.incomes
              .where((income) => income.status == IncomeStatus.expected)
              .toList()
            ..sort((a, b) => a.expectedDate.compareTo(b.expectedDate));
      final scenarioIncome = expectedIncomes.isEmpty
          ? null
          : expectedIncomes.firstWhere(
              (income) => income.id == _previewIncome?.id,
              orElse: () => expectedIncomes.first,
            );
      final previewing = _previewIncome?.id == scenarioIncome?.id;
      final shownScenarioDate = scenarioIncome == null
          ? null
          : _shownIncomeDate(scenarioIncome);
      return HarborStickyScrollView(
        title: 'Plan',
        subtitle: 'Bills and income still ahead',
        trailing: IconButton.filledTonal(
          onPressed: () => context.push('/income/new'),
          icon: const Icon(Icons.add_rounded),
          tooltip: 'Add expected income',
        ),
        children: [
          GlassPanel(
            padding: const EdgeInsets.all(5),
            radius: 18,
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Agenda'),
                  icon: Icon(Icons.view_agenda_outlined),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Month'),
                  icon: Icon(Icons.calendar_month_outlined),
                ),
              ],
              selected: {_monthView},
              onSelectionChanged: (value) =>
                  setState(() => _monthView = value.first),
            ),
          ),
          const SizedBox(height: 16),
          if (_monthView) ...[
            _monthGrid(events),
            const SizedBox(height: 12),
            SectionLabel(formatDate(_selectedDay, year: true)),
            if (selectedEvents.isEmpty)
              GlassPanel(
                child: Text(
                  'No listed events on this date.',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: .6),
                  ),
                ),
              )
            else
              ...selectedEvents.map(
                (event) => _EventTile(
                  event: event,
                  currency: snapshot.preferences.currencyCode,
                  showDate: false,
                ),
              ),
          ] else if (events.isEmpty)
            const HarborEmptyState(
              title: 'Your plan is clear',
              body:
                  'Add a bill or expected payment to see your dates together.',
              actionLabel: 'Add expected income',
            )
          else ...[
            SectionLabel('Upcoming events'),
            ...events
                .where(
                  (event) => !event.date.isBefore(dateOnly(DateTime.now())),
                )
                .take(12)
                .map(
                  (event) => _EventTile(
                    event: event,
                    currency: snapshot.preferences.currencyCode,
                  ),
                ),
          ],
          const SizedBox(height: 20),
          SectionLabel('Plan assumptions'),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Starting funds',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  snapshot.funds == null
                      ? 'No starting funds snapshot entered.'
                      : '${formatMoney(snapshot.funds!.amount, snapshot.preferences.currencyCode)} entered by you · ${formatDate(snapshot.funds!.asOf, year: true)}',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: .68),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Expected income is not counted as available funds. This view uses only your entries and is not a bank balance or prediction.',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          if (scenarioIncome != null) ...[
            const SizedBox(height: 20),
            SectionLabel('Try a scenario'),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StatusTag(
                    'What if income arrives later?',
                    icon: Icons.compare_arrows_rounded,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${scenarioIncome.source} · ${formatDate(shownScenarioDate!, year: true)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Compare the known obligations if this expected payment moves five days later.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: .65),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: previewing
                              ? () => setState(() => _previewIncome = null)
                              : null,
                          child: const Text('Undo'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed:
                              scenarioIncome.status != IncomeStatus.expected
                              ? null
                              : previewing
                              ? () async {
                                  final ok = await context
                                      .read<LedgerCubit>()
                                      .delayIncome(scenarioIncome);
                                  if (ok && mounted) {
                                    setState(() => _previewIncome = null);
                                  }
                                }
                              : () => setState(
                                  () => _previewIncome = scenarioIncome,
                                ),
                          child: Text(
                            previewing ? 'Save new date' : 'Move 5 days later',
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (previewing) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'This is a preview. Save it to keep the new date.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    },
  );

  Widget _monthGrid(List<_PlanEvent> events) {
    final first = DateTime(_month.year, _month.month, 1);
    final start = first.subtract(Duration(days: first.weekday - 1));
    final days = List.generate(42, (index) => start.add(Duration(days: index)));
    return GlassPanel(
      padding: const EdgeInsets.all(13),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() {
                  _month = DateTime(_month.year, _month.month - 1);
                  _selectedDay = _month;
                }),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    DateFormat('MMMM yyyy').format(_month),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _month = DateTime(_month.year, _month.month + 1);
                  _selectedDay = _month;
                }),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: .55),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 5),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.08,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final hasEvents = events.any(
                (event) =>
                    event.date.year == day.year &&
                    event.date.month == day.month &&
                    event.date.day == day.day,
              );
              final inMonth = day.month == _month.month;
              final selected =
                  day.year == _selectedDay.year &&
                  day.month == _selectedDay.month &&
                  day.day == _selectedDay.day;
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _selectedDay = day),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: .22)
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        border: selected
                            ? Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: .55),
                              )
                            : null,
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: inMonth
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: .28),
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (hasEvents)
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showIncomeActions(
    BuildContext context,
    IncomeEvent income,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              title: Text(
                income.source,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${formatMoney(income.amount)} · ${_incomeStatus(income.status)}',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_calendar_outlined),
              title: const Text('Move expected date 5 days later'),
              onTap: () => Navigator.pop(context, 'delay'),
            ),
            if (income.status != IncomeStatus.received)
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('Mark received'),
                onTap: () => Navigator.pop(context, 'received'),
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete income event'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    switch (action) {
      case 'delay':
        await context.read<LedgerCubit>().delayIncome(income);
        break;
      case 'received':
        await context.read<LedgerCubit>().markIncomeReceived(income);
        break;
      case 'delete':
        await context.read<LedgerCubit>().deleteIncome(income.id);
        break;
    }
  }

  static _PlanEvent _planBill(
    LedgerSnapshot snapshot,
    Bill bill,
    VoidCallback onTap,
  ) {
    final paid = snapshot.payments
        .where((payment) => payment.billId == bill.id)
        .fold<int>(0, (sum, payment) => sum + payment.amount);
    final money = billMoneyStatus(bill, paid, DateTime.now());
    return _PlanEvent(
      date: bill.dueDate,
      title: bill.name,
      subtitle: money.isPaid
          ? 'Paid · ${bill.frequency.name}'
          : '${bill.isEstimate ? 'Estimate' : 'Bill'} · ${bill.frequency.name}',
      amount: money.displayAmount,
      isIncome: false,
      onTap: onTap,
    );
  }

  DateTime _shownIncomeDate(IncomeEvent income) {
    if (_previewIncome?.id == income.id) {
      return income.expectedDate.add(const Duration(days: 5));
    }
    return income.expectedDate;
  }

  static String _incomeStatus(IncomeStatus value) => switch (value) {
    IncomeStatus.expected => 'Expected · entered by you',
    IncomeStatus.clientSent => 'Client says sent',
    IncomeStatus.received => 'Received · marked by you',
  };
}

class _PlanEvent {
  const _PlanEvent({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.onTap,
  });
  final DateTime date;
  final String title;
  final String subtitle;
  final int amount;
  final bool isIncome;
  final VoidCallback onTap;
}

class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.event,
    required this.currency,
    this.showDate = true,
  });
  final _PlanEvent event;
  final String currency;
  final bool showDate;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Semantics(
      button: true,
      label:
          '${event.title}. ${showDate ? '${formatDate(event.date)}. ' : ''}${event.subtitle}. ${formatMoney(event.amount, currency)}',
      excludeSemantics: true,
      child: InkWell(
        onTap: event.onTap,
        borderRadius: BorderRadius.circular(18),
        child: GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          radius: 18,
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  event.isIncome
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      showDate
                          ? '${formatDate(event.date)} · ${event.subtitle}'
                          : event.subtitle,
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
                  formatMoney(event.amount, currency),
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
  );
}
