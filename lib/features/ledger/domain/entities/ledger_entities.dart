import 'package:equatable/equatable.dart';

enum BillFrequency { once, weekly, biweekly, monthly, quarterly, yearly }

enum IncomeStatus { expected, clientSent, received }

class Bill extends Equatable {
  const Bill({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    this.frequency = BillFrequency.monthly,
    this.category = 'Other',
    this.isEstimate = false,
    this.reminderDays = 3,
    this.isActive = true,
  });
  final String id;
  final String name;
  final int amount;
  final DateTime dueDate;
  final BillFrequency frequency;
  final String category;
  final bool isEstimate;
  final int reminderDays;
  final bool isActive;

  Bill copyWith({
    String? id,
    String? name,
    int? amount,
    DateTime? dueDate,
    BillFrequency? frequency,
    String? category,
    bool? isEstimate,
    int? reminderDays,
    bool? isActive,
  }) => Bill(
    id: id ?? this.id,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    dueDate: dueDate ?? this.dueDate,
    frequency: frequency ?? this.frequency,
    category: category ?? this.category,
    isEstimate: isEstimate ?? this.isEstimate,
    reminderDays: reminderDays ?? this.reminderDays,
    isActive: isActive ?? this.isActive,
  );
  @override
  List<Object?> get props => [
    id,
    name,
    amount,
    dueDate,
    frequency,
    category,
    isEstimate,
    reminderDays,
    isActive,
  ];
}

class IncomeEvent extends Equatable {
  const IncomeEvent({
    required this.id,
    required this.source,
    required this.amount,
    required this.expectedDate,
    this.status = IncomeStatus.expected,
    this.receivedDate,
  });
  final String id;
  final String source;
  final int amount;
  final DateTime expectedDate;
  final IncomeStatus status;
  final DateTime? receivedDate;

  IncomeEvent copyWith({
    String? id,
    String? source,
    int? amount,
    DateTime? expectedDate,
    IncomeStatus? status,
    DateTime? receivedDate,
  }) => IncomeEvent(
    id: id ?? this.id,
    source: source ?? this.source,
    amount: amount ?? this.amount,
    expectedDate: expectedDate ?? this.expectedDate,
    status: status ?? this.status,
    receivedDate: receivedDate ?? this.receivedDate,
  );
  @override
  List<Object?> get props => [
    id,
    source,
    amount,
    expectedDate,
    status,
    receivedDate,
  ];
}

class Payment extends Equatable {
  const Payment({
    required this.id,
    required this.billId,
    required this.amount,
    required this.date,
    this.note = '',
  });
  final String id;
  final String billId;
  final int amount;
  final DateTime date;
  final String note;
  @override
  List<Object?> get props => [id, billId, amount, date, note];
}

class FundsSnapshot extends Equatable {
  const FundsSnapshot({required this.amount, required this.asOf});
  final int amount;
  final DateTime asOf;
  @override
  List<Object?> get props => [amount, asOf];
}

class UserPreferences extends Equatable {
  const UserPreferences({
    this.darkMode = true,
    this.hideReminderDetails = true,
    this.currencyCode = 'PHP',
  });
  final bool darkMode;
  final bool hideReminderDetails;
  final String currencyCode;

  UserPreferences copyWith({
    bool? darkMode,
    bool? hideReminderDetails,
    String? currencyCode,
  }) => UserPreferences(
    darkMode: darkMode ?? this.darkMode,
    hideReminderDetails: hideReminderDetails ?? this.hideReminderDetails,
    currencyCode: currencyCode ?? this.currencyCode,
  );
  @override
  List<Object?> get props => [darkMode, hideReminderDetails, currencyCode];
}

class LedgerSnapshot extends Equatable {
  const LedgerSnapshot({
    this.bills = const [],
    this.incomes = const [],
    this.payments = const [],
    this.funds,
    this.preferences = const UserPreferences(),
    this.bufferGoal,
  });
  final List<Bill> bills;
  final List<IncomeEvent> incomes;
  final List<Payment> payments;
  final FundsSnapshot? funds;
  final UserPreferences preferences;
  final int? bufferGoal;
  @override
  List<Object?> get props => [
    bills,
    incomes,
    payments,
    funds,
    preferences,
    bufferGoal,
  ];
}
