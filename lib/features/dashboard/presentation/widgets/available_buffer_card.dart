import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';

class AvailableBufferCard extends StatelessWidget {
  const AvailableBufferCard({
    super.key,
    required this.amount,
    required this.currencyCode,
    required this.subtitle,
  });

  final int amount;
  final String currencyCode;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: const Color(0xFF121214),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Buffer',
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          formatMoney(amount, currencyCode),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFF2F2F7),
            fontSize: 38,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.2,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}
