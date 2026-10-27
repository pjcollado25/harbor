import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/harbor_toast.dart';
import '../../../ledger/domain/entities/ledger_entities.dart';
import '../../../ledger/presentation/cubit/ledger_cubit.dart';

class PaymentFormPage extends StatefulWidget {
  const PaymentFormPage({super.key, required this.billId});
  final String billId;
  @override
  State<PaymentFormPage> createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends State<PaymentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = dateOnly(DateTime.now());
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<LedgerCubit, LedgerState>(
    builder: (context, state) {
      final matches = state.snapshot.bills.where(
        (bill) => bill.id == widget.billId,
      );
      if (matches.isEmpty)
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('This bill is no longer available.')),
        );
      final bill = matches.first;
      final paid = state.snapshot.payments
          .where((payment) => payment.billId == bill.id)
          .fold<int>(0, (sum, payment) => sum + payment.amount);
      final remaining = (bill.amount - paid).clamp(0, bill.amount).toInt();
      if (_amount.text.isEmpty) _amount.text = remaining.toString();
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: context.pop,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('Record payment'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Due ${formatDate(bill.dueDate, year: true)} · ${formatMoney(remaining, state.snapshot.preferences.currencyCode)} remaining',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: .65),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount paid',
                  prefixText: '₱ ',
                ),
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  return parsed == null || parsed <= 0 || parsed > remaining
                      ? 'Enter an amount up to ${formatMoney(remaining)}.'
                      : null;
                },
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Paid on'),
                subtitle: Text(formatDate(_date, year: true)),
                trailing: const Icon(Icons.calendar_today_rounded),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _note,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 14),
              Text(
                'This payment is recorded from your entry. Harbor does not connect to your bank.',
                style: context.harborMutedText(alpha: 0.6, fontSize: 12),
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: () => _save(bill),
                child: const Text('Confirm payment'),
              ),
            ],
          ),
        ),
      );
    },
  );

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (value != null && mounted) setState(() => _date = dateOnly(value));
  }

  Future<void> _save(Bill bill) async {
    if (!_formKey.currentState!.validate()) return;
    final payment = Payment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      billId: bill.id,
      amount: int.parse(_amount.text),
      date: _date,
      note: _note.text.trim(),
    );
    final success = await context.read<LedgerCubit>().recordPayment(payment);
    if (!mounted) return;
    if (success) {
      context.pop();
      showHarborToast(
        context,
        'Payment recorded',
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => context.read<LedgerCubit>().undoPayment(payment.id),
        ),
      );
    } else {
      showHarborToast(
        context,
        context.read<LedgerCubit>().state.failure ??
            'Could not record payment.',
        isError: true,
      );
    }
  }
}
