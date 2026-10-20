import '../../../../core/errors/result.dart';
import '../entities/ledger_entities.dart';

abstract interface class LedgerRepository {
  Future<Result<LedgerSnapshot>> load();
  Future<Result<void>> saveBill(Bill bill);
  Future<Result<void>> deleteBill(String id);
  Future<Result<void>> saveIncome(IncomeEvent income);
  Future<Result<void>> deleteIncome(String id);
  Future<Result<void>> savePayment(Payment payment);
  Future<Result<void>> deletePayment(String id);
  Future<Result<void>> saveFunds(FundsSnapshot snapshot);
  Future<Result<void>> savePreferences(UserPreferences preferences);
  Future<Result<void>> saveBufferGoal(int? amount);
  Future<Result<void>> clearAll();
}
