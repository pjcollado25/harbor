enum DayPlanItemKind { scheduled, income, paid }

class DayPlanItem {
  const DayPlanItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.kind,
  });

  final String id;
  final String name;
  final int amount;
  final DayPlanItemKind kind;

  String? get tagLabel => switch (kind) {
        DayPlanItemKind.paid => 'paid',
        DayPlanItemKind.income => 'incoming',
        DayPlanItemKind.scheduled => null,
      };
}
