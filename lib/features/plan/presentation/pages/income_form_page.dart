import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/harbor_toast.dart';
import '../../../../features/ledger/domain/entities/ledger_entities.dart';
import '../../../../features/ledger/presentation/cubit/ledger_cubit.dart';

class IncomeFormPage extends StatefulWidget {
  const IncomeFormPage({super.key});
  @override
  State<IncomeFormPage> createState() => _IncomeFormPageState();
}

class _IncomeFormPageState extends State<IncomeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _source = TextEditingController();
  final _amount = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 14));
  IncomeStatus _status = IncomeStatus.expected;
  @override
  void dispose() {
    _source.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: context.pop,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: const Text('Add expected income'),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        children: [
          Text(
            'Keep money you expect separate from money that arrived.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: .65),
            ),
          ),
          const SizedBox(height: 22),
          TextFormField(
            controller: _source,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Client or source',
              hintText: 'e.g. Logo project',
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter an income source.'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _amount,
            keyboardType: TextInputType.number,
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
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Expected date'),
            subtitle: Text(formatDate(_date, year: true)),
            trailing: const Icon(Icons.calendar_today_rounded),
            onTap: _pickDate,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<IncomeStatus>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(
                value: IncomeStatus.expected,
                child: Text('Expected'),
              ),
              DropdownMenuItem(
                value: IncomeStatus.clientSent,
                child: Text('Client says sent'),
              ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _status = value);
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Only mark income received after you confirm it arrived. This is not bank-verified.',
            style: TextStyle(fontSize: 12, color: Colors.white60),
          ),
          const SizedBox(height: 22),
          FilledButton(onPressed: _save, child: const Text('Save income')),
        ],
      ),
    ),
  );

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 20),
    );
    if (result != null && mounted) setState(() => _date = dateOnly(result));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final income = IncomeEvent(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      source: _source.text.trim(),
      amount: int.parse(_amount.text),
      expectedDate: _date,
      status: _status,
    );
    final ok = await context.read<LedgerCubit>().saveIncome(income);
    if (!mounted) return;
    if (ok) {
      context.pop();
    } else {
      showHarborToast(
        context,
        context.read<LedgerCubit>().state.failure ?? 'Could not save income.',
        isError: true,
      );
    }
  }
}
