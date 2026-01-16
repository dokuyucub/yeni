import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/core.dart';

/// Custom AppBar following Apple design guidelines
/// Provides consistent styling for navigation bars
class DayAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final bool transparent;
  final double elevation;

  const DayAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.onBackPressed,
    this.backgroundColor,
    this.transparent = false,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Text(
        title,
        style: AppTypography.headline(context),
      ),
      centerTitle: centerTitle,
      backgroundColor: transparent
          ? Colors.transparent
          : backgroundColor ?? AppColors.background(context),
      elevation: elevation,
      scrolledUnderElevation: 0,
      leading: showBackButton
          ? DayBackButton(
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : leading,
      actions: actions,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Custom back button with iOS-style chevron
class DayBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final String? label;

  const DayBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.accent;

    if (label != null) {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.only(left: 8),
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chevron_left,
              size: 28,
              color: effectiveColor,
            ),
            Text(
              label!,
              style: AppTypography.body(context).copyWith(
                color: effectiveColor,
              ),
            ),
          ],
        ),
      );
    }

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        Icons.chevron_left,
        size: 28,
        color: effectiveColor,
      ),
    );
  }
}

/// Creates a SliverAppBar with large title following iOS design
/// Use this in a CustomScrollView for scrollable large titles
Widget daySliverAppBar({
  required String title,
  List<Widget>? actions,
  Widget? leading,
  bool showBackButton = false,
  VoidCallback? onBackPressed,
  double expandedHeight = 100,
  bool pinned = true,
  Widget? flexibleContent,
  required BuildContext context,
}) {
  return SliverAppBar(
    expandedHeight: expandedHeight,
    pinned: pinned,
    stretch: true,
    backgroundColor: AppColors.background(context),
    elevation: 0,
    scrolledUnderElevation: 0.5,
    leading: showBackButton
        ? DayBackButton(
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
          )
        : leading,
    actions: actions,
    flexibleSpace: FlexibleSpaceBar(
      titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      title: Text(
        title,
        style: AppTypography.largeTitle(context).copyWith(
          fontSize: 28, // Slightly smaller for app bar
        ),
      ),
      collapseMode: CollapseMode.pin,
      background: flexibleContent,
    ),
  );
}

/// Custom bottom navigation bar following Apple design guidelines
/// Provides consistent styling for tab navigation
class DayBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  const DayBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavBarItemData(
        icon: Icons.today_outlined,
        activeIcon: Icons.today,
        label: 'Today',
      ),
      _NavBarItemData(
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view,
        label: 'Gallery',
      ),
      _NavBarItemData(
        icon: Icons.edit_note_outlined,
        activeIcon: Icons.edit_note,
        label: 'Journal',
      ),
      _NavBarItemData(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface(context),
        border: Border(
          top: BorderSide(
            color: AppColors.separator(context),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: true,
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _NavBarItem(
                icon: items[index].icon,
                activeIcon: items[index].activeIcon,
                label: items[index].label,
                isSelected: currentIndex == index,
                selectedColor: selectedColor ?? AppColors.accent,
                unselectedColor:
                    unselectedColor ?? AppColors.labelTertiary(context),
                onTap: () => onTap(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Data class for navigation bar items
class _NavBarItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavBarItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Private widget for individual navigation bar items
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isSelected ? selectedColor : unselectedColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.95,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  size: 24,
                  color: effectiveColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.caption1(context).copyWith(
                  color: effectiveColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
