import 'package:flutter_test/flutter_test.dart';

import 'package:harbor/core/errors/result.dart';
import 'package:harbor/features/ledger/domain/entities/ledger_entities.dart';
import 'package:harbor/features/ledger/domain/repositories/ledger_repository.dart';
import 'package:harbor/features/ledger/domain/usecases/ledger_use_cases.dart';

class _LedgerRepository implements LedgerRepository {
  Bill? savedBill;

  @override
  Future<Result<LedgerSnapshot>> load() async =>
      const Success(LedgerSnapshot());
  @override
  Future<Result<void>> saveBill(Bill bill) async {
    savedBill = bill;
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteBill(String id) async => const Success(null);
  @override
  Future<Result<void>> saveIncome(IncomeEvent income) async =>
      const Success(null);
  @override
  Future<Result<void>> deleteIncome(String id) async => const Success(null);
  @override
  Future<Result<void>> savePayment(Payment payment) async =>
      const Success(null);
  @override
  Future<Result<void>> deletePayment(String id) async => const Success(null);
  @override
  Future<Result<void>> saveFunds(FundsSnapshot snapshot) async =>
      const Success(null);
  @override
  Future<Result<void>> savePreferences(UserPreferences preferences) async =>
      const Success(null);
  @override
  Future<Result<void>> saveBufferGoal(int? amount) async => const Success(null);
  @override
  Future<Result<void>> clearAll() async => const Success(null);
}

void main() {
  group('SaveBill', () {
    final repo = _LedgerRepository();
    final saveBill = SaveBill(repo);

    test('rejects blank bill names', () async {
      final result = await saveBill(
        Bill(id: 'bill-1', name: '  ', amount: 100, dueDate: DateTime(2026)),
      );
      expect(result, isA<Failed<void>>());
      expect(repo.savedBill, isNull);
    });

    test('trims the bill name before saving', () async {
      final result = await saveBill(
        Bill(
          id: 'bill-1',
          name: '  Rent  ',
          amount: 100,
          dueDate: DateTime(2026),
        ),
      );
      expect(result, isA<Success<void>>());
      expect(repo.savedBill?.name, 'Rent');
    });
  });
}
