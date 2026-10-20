import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/ledger_entities.dart';
import '../../domain/usecases/ledger_use_cases.dart';

class LedgerState extends Equatable {
  const LedgerState({
    this.isLoading = true,
    this.isSaving = false,
    this.snapshot = const LedgerSnapshot(),
    this.message,
    this.failure,
  });
  final bool isLoading;
  final bool isSaving;
  final LedgerSnapshot snapshot;
  final String? message;
  final String? failure;

  LedgerState copyWith({
    bool? isLoading,
    bool? isSaving,
    LedgerSnapshot? snapshot,
    String? message,
    String? failure,
  }) => LedgerState(
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    snapshot: snapshot ?? this.snapshot,
    message: message,
    failure: failure,
  );
  @override
  List<Object?> get props => [isLoading, isSaving, snapshot, message, failure];
}

class LedgerCubit extends Cubit<LedgerState> {
  LedgerCubit({
    required LoadLedger loadLedger,
    required SaveBill saveBill,
    required DeleteBill deleteBill,
    required SaveIncome saveIncome,
    required DeleteIncome deleteIncome,
    required RecordPayment recordPayment,
    required UndoPayment undoPayment,
    required SaveFunds saveFunds,
    required SavePreferences savePreferences,
    required SaveBufferGoal saveBufferGoal,
    required ScheduleBillReminder scheduleReminder,
    required CancelBillReminder cancelReminder,
    required RequestReminderPermission requestPermission,
    required CheckReminderPermission checkReminderPermission,
    required OpenReminderSettings openReminderSettings,
    required ClearLocalData clearLocalData,
  }) : _loadLedger = loadLedger,
       _saveBill = saveBill,
       _deleteBill = deleteBill,
       _saveIncome = saveIncome,
       _deleteIncome = deleteIncome,
       _recordPayment = recordPayment,
       _undoPayment = undoPayment,
       _saveFunds = saveFunds,
       _savePreferences = savePreferences,
       _saveBufferGoal = saveBufferGoal,
       _scheduleReminder = scheduleReminder,
       _cancelReminder = cancelReminder,
       _requestPermission = requestPermission,
       _checkReminderPermission = checkReminderPermission,
       _openReminderSettings = openReminderSettings,
       _clearLocalData = clearLocalData,
       super(const LedgerState());

  final LoadLedger _loadLedger;
  final SaveBill _saveBill;
  final DeleteBill _deleteBill;
  final SaveIncome _saveIncome;
  final DeleteIncome _deleteIncome;
  final RecordPayment _recordPayment;
  final UndoPayment _undoPayment;
  final SaveFunds _saveFunds;
  final SavePreferences _savePreferences;
  final SaveBufferGoal _saveBufferGoal;
  final ScheduleBillReminder _scheduleReminder;
  final CancelBillReminder _cancelReminder;
  final RequestReminderPermission _requestPermission;
  final CheckReminderPermission _checkReminderPermission;
  final OpenReminderSettings _openReminderSettings;
  final ClearLocalData _clearLocalData;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final result = await _loadLedger();
    switch (result) {
      case Success<LedgerSnapshot>(:final value):
        emit(state.copyWith(isLoading: false, snapshot: value));
      case Failed<LedgerSnapshot>(:final failure):
        emit(state.copyWith(isLoading: false, failure: failure.message));
    }
  }

  Future<bool> saveBill(Bill bill) async {
    emit(state.copyWith(isSaving: true));
    final result = await _saveBill(bill);
    if (result case Failed<void>(:final failure)) {
      emit(state.copyWith(isSaving: false, failure: failure.message));
      return false;
    }
    final reminder = await _scheduleReminder(
      bill,
      hideDetails: state.snapshot.preferences.hideReminderDetails,
    );
    final note = reminder is Failed<void>
        ? 'Bill saved. ${reminder.failure.message}'
        : 'Bill saved';
    return _reloadAfterMutation(note);
  }

  Future<bool> deleteBill(Bill bill) async {
    emit(state.copyWith(isSaving: true));
    final result = await _deleteBill(bill.id);
    if (result case Failed<void>(:final failure)) {
      emit(state.copyWith(isSaving: false, failure: failure.message));
      return false;
    }
    final reminder = await _cancelReminder(bill.id);
    return _reloadAfterMutation(
      reminder is Failed<void>
          ? 'Bill deleted; its reminder may still be active.'
          : 'Bill deleted',
    );
  }

  Future<bool> saveIncome(IncomeEvent income) async {
    emit(state.copyWith(isSaving: true));
    final result = await _saveIncome(income);
    return _finish(result, 'Income updated');
  }

  Future<bool> deleteIncome(String id) async {
    emit(state.copyWith(isSaving: true));
    return _finish(await _deleteIncome(id), 'Income removed');
  }

  Future<bool> recordPayment(Payment payment) async {
    emit(state.copyWith(isSaving: true));
    return _finish(await _recordPayment(payment), 'Payment recorded');
  }

  Future<bool> undoPayment(String paymentId) async {
    emit(state.copyWith(isSaving: true));
    return _finish(await _undoPayment(paymentId), 'Payment undone');
  }

  Future<bool> saveFunds(FundsSnapshot snapshot) async {
    emit(state.copyWith(isSaving: true));
    return _finish(await _saveFunds(snapshot), 'Starting funds updated');
  }

  Future<bool> updatePreferences(UserPreferences preferences) async {
    final privacyChanged =
        state.snapshot.preferences.hideReminderDetails !=
        preferences.hideReminderDetails;
    emit(state.copyWith(isSaving: true));
    final result = await _savePreferences(preferences);
    final saved = await _finish(result, 'Settings saved');
    if (saved && privacyChanged) {
      for (final bill in state.snapshot.bills) {
        await _scheduleReminder(
          bill,
          hideDetails: preferences.hideReminderDetails,
        );
      }
    }
    return saved;
  }

  Future<bool> saveBufferGoal(int? amount) async {
    emit(state.copyWith(isSaving: true));
    return _finish(
      await _saveBufferGoal(amount),
      amount == null ? 'Goal removed' : 'Goal saved',
    );
  }

  Future<bool> clearLocalData() async {
    emit(state.copyWith(isSaving: true));
    return _finish(
      await _clearLocalData(),
      'All local Harbor data was deleted',
    );
  }

  Future<bool> requestReminderPermission() async {
    emit(state.copyWith(isSaving: true));
    return _finish(await _requestPermission(), 'Reminder permission updated');
  }

  Future<bool> checkReminderPermission() => _checkReminderPermission();

  Future<void> openReminderSettings() => _openReminderSettings();

  Future<bool> delayIncome(IncomeEvent income, {int days = 5}) => saveIncome(
    income.copyWith(
      expectedDate: income.expectedDate.add(Duration(days: days)),
    ),
  );

  Future<bool> markIncomeReceived(
    IncomeEvent income, {
    DateTime? receivedDate,
  }) => saveIncome(
    income.copyWith(
      status: IncomeStatus.received,
      receivedDate: receivedDate ?? DateTime.now(),
    ),
  );

  Future<bool> _finish(Result<void> result, String message) async {
    if (result case Failed<void>(:final failure)) {
      emit(state.copyWith(isSaving: false, failure: failure.message));
      return false;
    }
    return _reloadAfterMutation(message);
  }

  Future<bool> _reloadAfterMutation(String message) async {
    final loaded = await _loadLedger();
    switch (loaded) {
      case Success<LedgerSnapshot>(:final value):
        emit(
          state.copyWith(
            isLoading: false,
            isSaving: false,
            snapshot: value,
            message: message,
          ),
        );
        return true;
      case Failed<LedgerSnapshot>(:final failure):
        emit(
          state.copyWith(
            isLoading: false,
            isSaving: false,
            failure: failure.message,
          ),
        );
        return false;
    }
  }
}
