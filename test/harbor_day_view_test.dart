import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harbor/core/theme/app_theme.dart';
import 'package:harbor/features/dashboard/domain/day_plan_item.dart';
import 'package:harbor/features/dashboard/domain/today_plan_builder.dart';
import 'package:harbor/features/dashboard/presentation/widgets/harbor_day_view.dart';

void main() {
  testWidgets('shows All clear on an empty day with coming up', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final today = DateTime(2026, 3, 2);
    final week = weekDatesFor(today);
    final upcoming = (
      date: DateTime(2026, 3, 4),
      item: const DayPlanItem(
        id: 'bill:rent',
        name: 'Rent',
        amount: 1850,
        kind: DayPlanItemKind.scheduled,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: HarborDayView(
              selectedDay: today,
              weekDays: week,
              daysWithItems: {DateTime(2026, 3, 4)},
              items: const [],
              currencyCode: 'PHP',
              onSelectDay: (_) {},
              onAddBill: () {},
              onPlanAhead: () {},
              upcoming: upcoming,
            ),
          ),
        ),
      ),
    );

    expect(find.text('All clear'), findsOneWidget);
    expect(find.text('Nothing scheduled'), findsOneWidget);
    expect(find.text('Coming up'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('Add a bill'), findsOneWidget);

    final summaryBox = tester.getRect(find.text('Nothing scheduled'));
    final allClearBox = tester.getRect(find.text('All clear'));
    final viewBox = tester.getRect(find.byType(HarborDayView));
    expect(summaryBox.left, lessThan(allClearBox.left));
    expect(allClearBox.center.dx, closeTo(viewBox.center.dx, 4));
  });

  testWidgets('shows timeline rows when the day has items', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final day = DateTime(2026, 3, 4);
    final week = weekDatesFor(day);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: HarborDayView(
              selectedDay: day,
              weekDays: week,
              daysWithItems: {day},
              items: const [
                DayPlanItem(
                  id: 'bill:electric',
                  name: 'Electric',
                  amount: 94,
                  kind: DayPlanItemKind.scheduled,
                ),
              ],
              currencyCode: 'PHP',
              onSelectDay: (_) {},
              onAddBill: () {},
              onPlanAhead: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('1 scheduled'), findsOneWidget);
    expect(find.text('Electric'), findsOneWidget);
    expect(find.text('All clear'), findsNothing);
  });

  testWidgets('highlights days that have scheduled items in the week strip', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final dayWithBill = DateTime(2026, 3, 4);
    final week = weekDatesFor(dayWithBill);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: HarborDayView(
              selectedDay: dayWithBill,
              weekDays: week,
              daysWithItems: {dayWithBill},
              items: const [
                DayPlanItem(
                  id: 'bill:electric',
                  name: 'Electric',
                  amount: 94,
                  kind: DayPlanItemKind.scheduled,
                ),
              ],
              currencyCode: 'PHP',
              onSelectDay: (_) {},
              onAddBill: () {},
              onPlanAhead: () {},
            ),
          ),
        ),
      ),
    );

    final dayText = find.text('${dayWithBill.day}');
    final dayContainer = tester.widget<Container>(
      find.ancestor(of: dayText, matching: find.byType(Container)).first,
    );
    expect(dayContainer.decoration, isA<BoxDecoration>());
    final decoration = dayContainer.decoration! as BoxDecoration;
    expect(decoration.color, isNotNull);
  });
}
