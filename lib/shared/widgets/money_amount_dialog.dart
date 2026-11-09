import 'package:flutter/material.dart';

/// Peso prefix stays visible before the field is focused.
const moneyAmountDecoration = InputDecoration(
  labelText: 'Amount',
  prefixText: '₱',
  floatingLabelBehavior: FloatingLabelBehavior.always,
);

/// Owns its text controller until the dialog route has finished closing.
Future<int?> showMoneyAmountDialog(
  BuildContext context, {
  required String title,
  String initialAmount = '',
}) {
  return showDialog<int>(
    context: context,
    builder: (context) => _MoneyAmountDialog(
      title: title,
      initialAmount: initialAmount,
    ),
  );
}

class _MoneyAmountDialog extends StatefulWidget {
  const _MoneyAmountDialog({required this.title, required this.initialAmount});

  final String title;
  final String initialAmount;

  @override
  State<_MoneyAmountDialog> createState() => _MoneyAmountDialogState();
}

class _MoneyAmountDialogState extends State<_MoneyAmountDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAmount);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: moneyAmountDecoration,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, int.tryParse(_controller.text)),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
