import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum GuestStatus {
  accepted,
  declined,
  pending,
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  final GuestStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;
    String label;

    switch (status) {
      case GuestStatus.accepted:
        textColor = AppColors.success;
        bgColor = AppColors.success.withOpacity(0.08);
        label = 'ACCEPTED';
        break;
      case GuestStatus.declined:
        textColor = AppColors.danger;
        bgColor = AppColors.danger.withOpacity(0.08);
        label = 'DECLINED';
        break;
      case GuestStatus.pending:
        textColor = AppColors.pending;
        bgColor = AppColors.pending.withOpacity(0.08);
        label = 'PENDING';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          color: textColor,
          fontSize: compact ? 9 : 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
