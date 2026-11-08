import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/day_plan_item.dart';
import '../../domain/today_plan_builder.dart';

/// Single brand accent — logo dot only (RGB 0.36, 0.63, 1.0).
const harborBrandDot = Color.fromRGBO(92, 161, 255, 1);

Color harborCalmGreen(BuildContext context) =>
    Colors.green.withValues(alpha: 0.8);

String harborDayPrimaryTitle(DateTime selectedDay) {
  final today = dateOnly(DateTime.now());
  if (dateOnly(selectedDay) == today) return 'Today';
  return DateFormat('EEEE').format(selectedDay);
}

String harborDaySecondaryLine(DateTime selectedDay) =>
    DateFormat('EEEE, MMMM d').format(selectedDay);

class HarborBrandRow extends StatelessWidget {
  const HarborBrandRow({super.key});

  @override
  Widget build(BuildContext context) {
    final tertiary = HarborDayView._tertiary(context);
    return _BrandRow(color: tertiary);
  }
}

class HarborDayView extends StatelessWidget {
  const HarborDayView({
    super.key,
    required this.selectedDay,
    required this.weekDays,
    required this.daysWithItems,
    required this.items,
    required this.currencyCode,
    required this.onSelectDay,
    required this.onAddBill,
    required this.onPlanAhead,
    this.upcoming,
    this.onItemTap,
    this.showBrand = true,
    this.showDateHeader = true,
    this.showAddBillButton = true,
  });

  final DateTime selectedDay;
  final List<DateTime> weekDays;
  final Set<DateTime> daysWithItems;
  final List<DayPlanItem> items;
  final String currencyCode;
  final ValueChanged<DateTime> onSelectDay;
  final VoidCallback onAddBill;
  final VoidCallback onPlanAhead;
  final UpcomingPlanEntry? upcoming;
  final ValueChanged<DayPlanItem>? onItemTap;
  final bool showBrand;
  final bool showDateHeader;
  final bool showAddBillButton;

  static const _weekdayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final tertiary = _tertiary(context);
    final quaternary = _quaternary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBrand) ...[
          _BrandRow(color: tertiary),
          const SizedBox(height: 22),
        ],
        if (showDateHeader) ...[
          _DateHeader(selectedDay: selectedDay),
          const SizedBox(height: 24),
        ],
        _WeekStrip(
          weekDays: weekDays,
          selectedDay: selectedDay,
          daysWithItems: daysWithItems,
          onSelectDay: onSelectDay,
          tertiary: tertiary,
        ),
        const SizedBox(height: 24),
        _SummaryLine(items: items, currencyCode: currencyCode, tertiary: tertiary),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeOut,
          layoutBuilder: (currentChild, _) => SizedBox(
            width: double.infinity,
            child: Align(
              alignment: Alignment.topLeft,
              child: currentChild,
            ),
          ),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: items.isEmpty
              ? _EmptyDayState(
                  key: ValueKey('empty-${selectedDay.toIso8601String()}'),
                  selectedDay: selectedDay,
                  upcoming: upcoming,
                  currencyCode: currencyCode,
                  onPlanAhead: onPlanAhead,
                  quaternary: quaternary,
                )
              : _DayTimeline(
                  key: ValueKey('timeline-${selectedDay.toIso8601String()}'),
                  items: items,
                  currencyCode: currencyCode,
                  onItemTap: onItemTap,
                ),
        ),
        if (showAddBillButton) ...[
          const SizedBox(height: 28),
          HarborAddBillButton(onPressed: onAddBill),
        ],
      ],
    );
  }

  static Color _tertiary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45);

  static Color _quaternary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.32);
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: harborBrandDot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'HARBOR',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: 3,
              color: color,
            ),
          ),
        ],
      );
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.selectedDay});
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context) {
    final primaryTitle = harborDayPrimaryTitle(selectedDay);
    final secondary = harborDaySecondaryLine(selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          primaryTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          secondary,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: HarborDayView._tertiary(context),
          ),
        ),
      ],
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.weekDays,
    required this.selectedDay,
    required this.daysWithItems,
    required this.onSelectDay,
    required this.tertiary,
  });

  final List<DateTime> weekDays;
  final DateTime selectedDay;
  final Set<DateTime> daysWithItems;
  final ValueChanged<DateTime> onSelectDay;
  final Color tertiary;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;
    final today = dateOnly(DateTime.now());

    return Row(
      children: [
        for (var index = 0; index < weekDays.length; index++)
          Expanded(
            child: _WeekDayCell(
              date: weekDays[index],
              letter: HarborDayView._weekdayLetters[index],
              isSelected: dateOnly(weekDays[index]) == dateOnly(selectedDay),
              isToday: dateOnly(weekDays[index]) == today,
              hasItems: daysWithItems.contains(dateOnly(weekDays[index])),
              onTap: () => onSelectDay(dateOnly(weekDays[index])),
              tertiary: tertiary,
              onSurface: onSurface,
              surface: surface,
            ),
          ),
      ],
    );
  }
}

class _WeekDayCell extends StatelessWidget {
  const _WeekDayCell({
    required this.date,
    required this.letter,
    required this.isSelected,
    required this.isToday,
    required this.hasItems,
    required this.onTap,
    required this.tertiary,
    required this.onSurface,
    required this.surface,
  });

  final DateTime date;
  final String letter;
  final bool isSelected;
  final bool isToday;
  final bool hasItems;
  final VoidCallback onTap;
  final Color tertiary;
  final Color onSurface;
  final Color surface;

  BoxDecoration _dayDecoration() {
    if (isSelected) {
      return BoxDecoration(color: onSurface, shape: BoxShape.circle);
    }
    if (hasItems) {
      return BoxDecoration(
        shape: BoxShape.circle,
        color: onSurface.withValues(alpha: 0.08),
        border: Border.all(color: onSurface.withValues(alpha: 0.22)),
      );
    }
    if (isToday) {
      return BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: onSurface.withValues(alpha: 0.38), width: 1.5),
      );
    }
    return const BoxDecoration();
  }

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Column(
            children: [
              Text(
                letter,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected ? onSurface : tertiary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: _dayDecoration(),
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w500
                        : FontWeight.w400,
                    color: isSelected ? surface : onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: hasItems ? onSurface.withValues(alpha: 0.45) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      );
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.items,
    required this.currencyCode,
    required this.tertiary,
  });

  final List<DayPlanItem> items;
  final String currencyCode;
  final Color tertiary;

  @override
  Widget build(BuildContext context) {
    final summary = daySummary(items, currencyCode);
    final detailStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: summary.lead),
          if (summary.detail != null) ...[
            const TextSpan(text: ' · '),
            TextSpan(text: summary.detail, style: detailStyle),
          ],
        ],
      ),
      style: TextStyle(fontSize: 15, height: 1.35, color: tertiary),
    );
  }
}

class _DayTimeline extends StatelessWidget {
  const _DayTimeline({
    super.key,
    required this.items,
    required this.currencyCode,
    this.onItemTap,
  });

  final List<DayPlanItem> items;
  final String currencyCode;
  final ValueChanged<DayPlanItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    final divider = Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).dividerColor,
    );

    return Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _TimelineRow(
            item: items[index],
            currencyCode: currencyCode,
            onTap: onItemTap == null ? null : () => onItemTap!(items[index]),
          ),
          if (index < items.length - 1) divider,
        ],
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.item,
    required this.currencyCode,
    this.onTap,
  });

  final DayPlanItem item;
  final String currencyCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tertiary = HarborDayView._tertiary(context);
    final secondary = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62);
    final paid = item.kind == DayPlanItemKind.paid;
    final income = item.kind == DayPlanItemKind.income;
    final amountText = income
        ? '+${formatMoney(item.amount, currencyCode)}'
        : formatMoney(item.amount, currencyCode);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Icon(
              paid ? Icons.check_circle : Icons.circle_outlined,
              size: 18,
              color: paid ? harborCalmGreen(context) : tertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 15)),
                  if (item.tagLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.tagLabel!,
                      style: TextStyle(fontSize: 12, color: secondary),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              amountText,
              style: TextStyle(
                fontSize: 15,
                color: income ? harborCalmGreen(context) : null,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDayState extends StatelessWidget {
  const _EmptyDayState({
    super.key,
    required this.selectedDay,
    required this.upcoming,
    required this.currencyCode,
    required this.onPlanAhead,
    required this.quaternary,
  });

  final DateTime selectedDay;
  final UpcomingPlanEntry? upcoming;
  final String currencyCode;
  final VoidCallback onPlanAhead;
  final Color quaternary;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62);
    final tertiary = HarborDayView._tertiary(context);
    final weekday = DateFormat('EEEE').format(selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 48),
              const _AllClearMark(),
              const SizedBox(height: 16),
              const Text(
                'All clear',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Nothing needs your attention on $weekday.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: secondary),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onPlanAhead,
                style: OutlinedButton.styleFrom(
                  foregroundColor: secondary,
                  side: BorderSide(color: tertiary),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Plan ahead',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
        if (upcoming != null) ...[
          const SizedBox(height: 28),
          Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor),
          const SizedBox(height: 12),
          Text(
            'Coming up',
            style: TextStyle(fontSize: 12, color: quaternary),
          ),
          const SizedBox(height: 12),
          _UpcomingRow(entry: upcoming!, currencyCode: currencyCode),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _AllClearMark extends StatelessWidget {
  const _AllClearMark();

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62);
    final tertiary = HarborDayView._tertiary(context);

    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(72, 72),
            painter: _DashedCirclePainter(color: tertiary),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: secondary, width: 1.2),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.check, size: 14, color: secondary),
          ),
        ],
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    const dash = 2.0;
    const gap = 6.0;
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * 3.141592653589793 * radius;
    final dashCount = (circumference / (dash + gap)).floor();

    for (var i = 0; i < dashCount; i++) {
      final startAngle = (i * (dash + gap)) / radius;
      final sweep = dash / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 0.6),
        startAngle,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.entry, required this.currencyCode});
  final UpcomingPlanEntry entry;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62);
    final income = entry.item.kind == DayPlanItemKind.income;
    final subtitle = DateFormat('EEEE, MMMM d').format(entry.date);
    final amount = income
        ? '+${formatMoney(entry.item.amount, currencyCode)}'
        : formatMoney(entry.item.amount, currencyCode);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.item.name, style: const TextStyle(fontSize: 15)),
              Text(subtitle, style: TextStyle(fontSize: 14, color: secondary)),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 15,
            color: income ? harborCalmGreen(context) : null,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class HarborAddBillButton extends StatelessWidget {
  const HarborAddBillButton({
    super.key,
    required this.onPressed,
    this.expanded = true,
  });

  final VoidCallback onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    const background = Colors.white;
    const foreground = Color(0xFF1C2836);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          minimumSize: expanded ? const Size.fromHeight(48) : const Size(0, 44),
          padding: EdgeInsets.symmetric(
            horizontal: expanded ? 20 : 16,
            vertical: expanded ? 14 : 10,
          ),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Add a bill'),
      ),
    );
  }
}

