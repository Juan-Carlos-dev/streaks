import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../core/constants/app_colors.dart';
import '../providers/user_providers.dart';
import '../providers/habit_providers.dart';

class MainWrapperScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapperScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(gradientControllerProvider);
    ref.watch(nativeWidgetSyncProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      // No bottomNavigationBar — we use a floating overlay via Stack
      body: Stack(
        children: [
          // Content fills the full screen — scrolls under the floating bar
          navigationShell,

          // Floating nav bar overlaid on top
          Consumer(
            builder: (context, ref, child) {
              final showNavBar = ref.watch(showBottomNavBarProvider);
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: 24,
                right: 24,
                bottom: showNavBar ? 18 : -100,
                child: _FloatingNavBar(
                  currentIndex: navigationShell.currentIndex,
                  onTap: (index) => _onTap(context, index),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (icon: CupertinoIcons.house,          activeIcon: CupertinoIcons.house_fill,          label: 'Inicio'),
    (icon: CupertinoIcons.chart_bar,      activeIcon: CupertinoIcons.chart_bar_fill,      label: 'Stats'),
    (icon: CupertinoIcons.calendar,       activeIcon: CupertinoIcons.calendar,            label: 'Calendario'),
    (icon: CupertinoIcons.person,         activeIcon: CupertinoIcons.person_fill,         label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isSelected = currentIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    height: 72,
                    child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 68,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.13)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          isSelected
                              ? ShaderMask(
                                  shaderCallback: (bounds) =>
                                      AppColors.blueGradient.createShader(bounds),
                                  blendMode: BlendMode.srcIn,
                                  child: Icon(
                                    item.activeIcon,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  item.icon,
                                  size: 24,
                                  color: Colors.white,
                                ),
                          const SizedBox(height: 2),
                          isSelected
                              ? ShaderMask(
                                  shaderCallback: (bounds) =>
                                      AppColors.blueGradient.createShader(bounds),
                                  blendMode: BlendMode.srcIn,
                                  child: Text(
                                    item.label,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  item.label,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ));
            }),
          ),
        ),
      ),
    );
  }
}
