import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

class DriverNavItem {
  const DriverNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// شريط التنقل السفلي الداكن العائم (كما في التصميم).
class DriverBottomNav extends StatelessWidget {
  const DriverBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<DriverNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          children: List.generate(items.length, (i) {
            final active = i == selectedIndex;
            final color = active ? DriverUi.gold : DriverUi.navMuted;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(32),
                onTap: () => onSelected(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(items[i].icon, size: 24, color: color),
                    const SizedBox(height: 3),
                    Text(
                      items[i].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
