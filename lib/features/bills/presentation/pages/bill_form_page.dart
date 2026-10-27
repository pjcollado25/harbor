import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/harbor_toast.dart';
import '../../../ledger/domain/entities/ledger_entities.dart';
import '../../../ledger/presentation/cubit/ledger_cubit.dart';

class BillFormPage extends StatefulWidget {
  const BillFormPage({super.key, this.bill});
  final Bill? bill;
  @override
  State<BillFormPage> createState() => _BillFormPageState();
}

class _BillFormPageState extends State<BillFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late DateTime _dueDate;
  late BillFrequency _frequency;
  late String _category;
  late int _reminderDays;
  late bool _estimate;

  @override
  void initState() {
    super.initState();
    final bill = widget.bill;
    _name = TextEditingController(text: bill?.name ?? '');
    _amount = TextEditingController(text: bill?.amount.toString() ?? '');
    _dueDate = bill?.dueDate ?? DateTime.now().add(const Duration(days: 7));
    _frequency = bill?.frequency ?? BillFrequency.monthly;
    _category = bill?.category ?? 'Utilities';
    _reminderDays = bill?.reminderDays ?? 3;
    _estimate = bill?.isEstimate ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: context.pop,
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Back',
      ),
      title: Text(widget.bill == null ? 'Add a bill' : 'Edit bill'),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            'Enter what you know. You can edit it later.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: .65),
            ),
          ),
          const SizedBox(height: 22),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Bill or payee name',
              hintText: 'e.g. Internet service',
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter a bill name.'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '₱ ',
            ),
            validator: (value) {
              final amount = int.tryParse(value ?? '');
              return amount == null || amount <= 0
                  ? 'Enter an amount greater than zero.'
                  : null;
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Variable amount'),
            subtitle: const Text('This amount is an estimate'),
            value: _estimate,
            onChanged: (value) => setState(() => _estimate = value),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Next due date'),
            subtitle: Text(formatDate(_dueDate, year: true)),
            trailing: const Icon(Icons.calendar_month_rounded),
            onTap: _chooseDate,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<BillFrequency>(
            initialValue: _frequency,
            decoration: const InputDecoration(labelText: 'Frequency'),
            items: BillFrequency.values
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(_frequencyLabel(value)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _frequency = value);
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items:
                const [
                      'Home',
                      'Utilities',
                      'Transport',
                      'Health',
                      'Subscriptions',
                      'Other',
                    ]
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _category = value);
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            initialValue: _reminderDays,
            decoration: const InputDecoration(labelText: 'Reminder'),
            items: const [0, 1, 3, 7]
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(
                      value == 0
                          ? 'No reminder'
                          : '$value ${value == 1 ? 'day' : 'days'} before',
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _reminderDays = value);
            },
          ),
          const SizedBox(height: 10),
          Text(
            'Reminders are scheduled on this device. You can change notification permission in Settings.',
            style: context.harborMutedText(alpha: 0.6, fontSize: 12),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: Text(widget.bill == null ? 'Save bill' : 'Save changes'),
          ),
        ],
      ),
    ),
  );

  Future<void> _chooseDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 20),
    );
    if (date != null && mounted) setState(() => _dueDate = dateOnly(date));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final id =
        widget.bill?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    final bill = Bill(
      id: id,
      name: _name.text,
      amount: int.parse(_amount.text),
      dueDate: _dueDate,
      frequency: _frequency,
      category: _category,
      isEstimate: _estimate,
      reminderDays: _reminderDays,
      isActive: widget.bill?.isActive ?? true,
    );
    final saved = await context.read<LedgerCubit>().saveBill(bill);
    if (!mounted) return;
    if (saved) {
      context.pop();
    } else {
      final message =
          context.read<LedgerCubit>().state.failure ??
          'Could not save this bill.';
      showHarborToast(context, message, isError: true);
    }
  }

  String _frequencyLabel(BillFrequency value) => switch (value) {
    BillFrequency.once => 'Once',
    BillFrequency.weekly => 'Weekly',
    BillFrequency.biweekly => 'Every two weeks',
    BillFrequency.monthly => 'Monthly',
    BillFrequency.quarterly => 'Quarterly',
    BillFrequency.yearly => 'Yearly',
  };
}
