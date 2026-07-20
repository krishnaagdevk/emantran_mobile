import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AsymmetricBottomNavBar extends StatelessWidget {
  const AsymmetricBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddEventPressed,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddEventPressed;

  @override
  Widget build(BuildContext context) {
    // We adjust bottom padding for devices with notch (iOS home indicator / Android guest bars)
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1.2,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1E1B1A),
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 12,
        top: 12,
        bottom: bottomPadding > 0 ? bottomPadding : 12,
      ),
      child: Row(
        children: [
          // 1. Far-left Coral Pill: "+ Add Event"
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: onAddEventPressed,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.cta, // #EF8A62
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x28EF8A62),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 20),
                    SizedBox(width: 6),
                    Text(
                      'ADD EVENT',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 2. Right side: 4 beautifully-spaced navigation items
          Expanded(
            flex: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.grid_view_outlined, Icons.grid_view_rounded),
                _buildNavItem(1, Icons.forum_outlined, Icons.forum_rounded),
                _buildNavItem(2, Icons.import_contacts_outlined, Icons.import_contacts_rounded),
                _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon) {
    final isSelected = currentIndex == index;
    
    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          child: Icon(
            isSelected ? filledIcon : outlineIcon,
            color: isSelected ? AppColors.cta : AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
