import 'package:flutter/material.dart';

import '../data/models.dart';

String money(double v) => v.toStringAsFixed(2);

String signed(double v) => '${v > 0 ? '+' : ''}${v.toStringAsFixed(2)}';

String dateStr(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String statusLabel(BetStatus s) {
  switch (s) {
    case BetStatus.pending:
      return 'Pending';
    case BetStatus.won:
      return 'Won';
    case BetStatus.lost:
      return 'Lost';
    case BetStatus.voided:
      return 'Void';
  }
}

Color plColor(BuildContext context, double v) {
  if (v > 0) return Colors.green.shade600;
  if (v < 0) return Colors.red.shade500;
  return Theme.of(context).colorScheme.onSurfaceVariant;
}

double? parseNumber(String text) =>
    double.tryParse(text.trim().replaceAll(',', '.'));
