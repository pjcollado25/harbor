import 'package:hive/hive.dart';

import '../../domain/entities/ledger_entities.dart';

class BillModel {
  const BillModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.frequency,
    required this.category,
    required this.isEstimate,
    required this.reminderDays,
    required this.isActive,
  });
  final String id;
  final String name;
  final int amount;
  final DateTime dueDate;
  final String frequency;
  final String category;
  final bool isEstimate;
  final int reminderDays;
  final bool isActive;

  factory BillModel.fromEntity(Bill value) => BillModel(
    id: value.id,
    name: value.name,
    amount: value.amount,
    dueDate: value.dueDate,
    frequency: value.frequency.name,
    category: value.category,
    isEstimate: value.isEstimate,
    reminderDays: value.reminderDays,
    isActive: value.isActive,
  );
  Bill toEntity() => Bill(
    id: id,
    name: name,
    amount: amount,
    dueDate: dueDate,
    frequency: BillFrequency.values.firstWhere(
      (value) => value.name == frequency,
      orElse: () => BillFrequency.monthly,
    ),
    category: category,
    isEstimate: isEstimate,
    reminderDays: reminderDays,
    isActive: isActive,
  );
}

class IncomeModel {
  const IncomeModel({
    required this.id,
    required this.source,
    required this.amount,
    required this.expectedDate,
    required this.status,
    this.receivedDate,
  });
  final String id;
  final String source;
  final int amount;
  final DateTime expectedDate;
  final String status;
  final DateTime? receivedDate;

  factory IncomeModel.fromEntity(IncomeEvent value) => IncomeModel(
    id: value.id,
    source: value.source,
    amount: value.amount,
    expectedDate: value.expectedDate,
    status: value.status.name,
    receivedDate: value.receivedDate,
  );
  IncomeEvent toEntity() => IncomeEvent(
    id: id,
    source: source,
    amount: amount,
    expectedDate: expectedDate,
    status: IncomeStatus.values.firstWhere(
      (value) => value.name == status,
      orElse: () => IncomeStatus.expected,
    ),
    receivedDate: receivedDate,
  );
}

class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.billId,
    required this.amount,
    required this.date,
    required this.note,
  });
  final String id;
  final String billId;
  final int amount;
  final DateTime date;
  final String note;

  factory PaymentModel.fromEntity(Payment value) => PaymentModel(
    id: value.id,
    billId: value.billId,
    amount: value.amount,
    date: value.date,
    note: value.note,
  );
  Payment toEntity() =>
      Payment(id: id, billId: billId, amount: amount, date: date, note: note);
}

class BillModelAdapter extends TypeAdapter<BillModel> {
  @override
  final int typeId = 0;
  @override
  BillModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0, n = reader.readByte(); i < n; i++)
        reader.readByte(): reader.read(),
    };
    return BillModel(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: fields[2] as int,
      dueDate: fields[3] as DateTime,
      frequency: fields[4] as String,
      category: fields[5] as String? ?? 'Other',
      isEstimate: fields[6] as bool? ?? false,
      reminderDays: fields[7] as int? ?? 3,
      isActive: fields[8] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, BillModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.frequency)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.isEstimate)
      ..writeByte(7)
      ..write(obj.reminderDays)
      ..writeByte(8)
      ..write(obj.isActive);
  }
}

class IncomeModelAdapter extends TypeAdapter<IncomeModel> {
  @override
  final int typeId = 1;
  @override
  IncomeModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0, n = reader.readByte(); i < n; i++)
        reader.readByte(): reader.read(),
    };
    return IncomeModel(
      id: fields[0] as String,
      source: fields[1] as String,
      amount: fields[2] as int,
      expectedDate: fields[3] as DateTime,
      status: fields[4] as String,
      receivedDate: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, IncomeModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.source)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.expectedDate)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.receivedDate);
  }
}

class PaymentModelAdapter extends TypeAdapter<PaymentModel> {
  @override
  final int typeId = 2;
  @override
  PaymentModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0, n = reader.readByte(); i < n; i++)
        reader.readByte(): reader.read(),
    };
    return PaymentModel(
      id: fields[0] as String,
      billId: fields[1] as String,
      amount: fields[2] as int,
      date: fields[3] as DateTime,
      note: fields[4] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, PaymentModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.billId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.note);
  }
}
