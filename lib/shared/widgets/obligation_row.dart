import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';

class ObligationRow extends StatelessWidget {
  const ObligationRow({
    super.key,
    required this.name,
    required this.detail,
    required this.amount,
    required this.currencyCode,
    required this.category,
    this.onTap,
  });

  final String name;
  final String detail;
  final int amount;
  final String currencyCode;
  final String category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    label: '$name. $detail. ${formatMoney(amount, currencyCode)}',
    child: Material(
      color: const Color(0xFF121214),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  _categoryIcon(category),
                  color: const Color(0xFFB0B0B8),
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF2F2F7),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 112),
                child: Text(
                  formatMoney(amount, currencyCode),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Color(0xFFF2F2F7),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

IconData _categoryIcon(String category) => switch (category.toLowerCase()) {
  'housing' || 'home' || 'rent' => Icons.home_outlined,
  'utilities' || 'internet' || 'power' => Icons.bolt_outlined,
  'food' => Icons.restaurant_outlined,
  'transport' => Icons.directions_bus_outlined,
  'subscriptions' => Icons.subscriptions_outlined,
  'health' => Icons.health_and_safety_outlined,
  'insurance' => Icons.shield_outlined,
  _ => Icons.receipt_long_outlined,
};
