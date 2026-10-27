import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/harbor_sticky_scroll.dart';
import '../../../../shared/widgets/harbor_toast.dart';
import '../../../../shared/widgets/harbor_widgets.dart';
import '../../../ledger/domain/entities/ledger_entities.dart';
import '../../../ledger/presentation/cubit/ledger_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => BlocConsumer<LedgerCubit, LedgerState>(
    listenWhen: (before, after) =>
        before.message != after.message || before.failure != after.failure,
    listener: (context, state) {
      final text = state.failure ?? state.message;
      if (text != null)
        showHarborToast(context, text, isError: state.failure != null);
    },
    builder: (context, state) {
      final prefs = state.snapshot.preferences;
      return HarborStickyScrollView(
        title: 'Settings',
        subtitle: 'Manage how Harbor looks and works',
        children: [
          SectionLabel('Appearance'),
          GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark mode'),
                  subtitle: const Text('Use Harbor with a dark appearance'),
                  value: prefs.darkMode,
                  onChanged: (value) => context
                      .read<LedgerCubit>()
                      .updatePreferences(prefs.copyWith(darkMode: value)),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.visibility_off_outlined),
                  title: const Text('Hide reminder details'),
                  subtitle: const Text('Keep bill names off the lock screen'),
                  value: prefs.hideReminderDetails,
                  onChanged: (value) =>
                      context.read<LedgerCubit>().updatePreferences(
                        prefs.copyWith(hideReminderDetails: value),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionLabel('Reminders'),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bill reminders',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Harbor can remind you before bills are due. Reminders stay on this device.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: .65),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: state.isSaving
                      ? null
                      : () => context
                            .read<LedgerCubit>()
                            .requestReminderPermission(),
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('Turn on reminders'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionLabel('Plan settings'),
          GlassPanel(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Starting amount'),
                  subtitle: Text(
                    state.snapshot.funds == null
                        ? 'No starting amount entered'
                        : '${formatMoney(state.snapshot.funds!.amount, prefs.currencyCode)} · ${formatDate(state.snapshot.funds!.asOf, year: true)}',
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _editFunds(context, state.snapshot.funds),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: prefs.currencyCode,
                  decoration: const InputDecoration(labelText: 'Currency'),
                  items: const ['PHP', 'USD', 'EUR', 'AUD', 'CAD']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null)
                      context.read<LedgerCubit>().updatePreferences(
                        prefs.copyWith(currencyCode: value),
                      );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionLabel('Your information'),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your information stays on this device',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Your bills, payments, and expected income are saved on this device. Harbor never connects to your bank.',
                  style: TextStyle(fontSize: 12, height: 1.45),
                ),
                const SizedBox(height: 13),
                OutlinedButton.icon(
                  onPressed: () => _export(context, state.snapshot),
                  icon: const Icon(Icons.copy_all_outlined),
                  label: const Text('Copy a backup'),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Paste it into a note to keep a copy.',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _deleteAll(context),
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: const Text('Clear all app data'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          if (state.failure != null) ...[
            const SizedBox(height: 12),
            Text(
              state.failure!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Harbor · Your plan, your pace',
              style: context.harborMutedText(alpha: 0.54, fontSize: 12),
            ),
          ),
        ],
      );
    },
  );

  Future<void> _editFunds(BuildContext context, FundsSnapshot? current) async {
    final controller = TextEditingController(
      text: current?.amount.toString() ?? '',
    );
    final amount = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Starting amount'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '₱ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (amount != null && context.mounted)
      await context.read<LedgerCubit>().saveFunds(
        FundsSnapshot(amount: amount, asOf: dateOnly(DateTime.now())),
      );
  }

  Future<void> _export(BuildContext context, LedgerSnapshot snapshot) async {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'currency': snapshot.preferences.currencyCode,
      'funds': snapshot.funds == null
          ? null
          : {
              'amount': snapshot.funds!.amount,
              'asOf': snapshot.funds!.asOf.toIso8601String(),
            },
      'bills': snapshot.bills
          .map(
            (bill) => {
              'id': bill.id,
              'name': bill.name,
              'amount': bill.amount,
              'dueDate': bill.dueDate.toIso8601String(),
              'frequency': bill.frequency.name,
              'category': bill.category,
              'estimate': bill.isEstimate,
              'reminderDays': bill.reminderDays,
            },
          )
          .toList(),
      'income': snapshot.incomes
          .map(
            (income) => {
              'id': income.id,
              'source': income.source,
              'amount': income.amount,
              'expectedDate': income.expectedDate.toIso8601String(),
              'status': income.status.name,
              'receivedDate': income.receivedDate?.toIso8601String(),
            },
          )
          .toList(),
      'payments': snapshot.payments
          .map(
            (payment) => {
              'id': payment.id,
              'billId': payment.billId,
              'amount': payment.amount,
              'date': payment.date.toIso8601String(),
              'note': payment.note,
            },
          )
          .toList(),
    };
    await Clipboard.setData(
      ClipboardData(text: const JsonEncoder.withIndent('  ').convert(data)),
    );
    if (context.mounted)
      showHarborToast(
        context,
        'Backup copied. Paste it into a note to save it.',
      );
  }

  Future<void> _deleteAll(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all Harbor data?'),
        content: const Text(
          'This removes your bills, payments, expected income, and settings from this device. You can’t undo this.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep my data'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear data'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted)
      await context.read<LedgerCubit>().clearLocalData();
  }
}
