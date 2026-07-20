import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SplitPillDateSelector extends StatelessWidget {
  const SplitPillDateSelector({
    super.key,
    required this.selectedDateText,
    required this.onTap,
  });

  final String selectedDateText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          color: AppColors.surface,
          boxShadow: const [
            BoxShadow(
              color: Color(0x051E1B1A),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Left block: Deep Purple with monospace date
            Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: const BoxDecoration(
                color: AppColors.primary, // #372475
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(23),
                  bottomLeft: Radius.circular(23),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                selectedDateText.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            
            // Right block: White with pencil icon
            Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(23),
                  bottomRight: Radius.circular(23),
                ),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
