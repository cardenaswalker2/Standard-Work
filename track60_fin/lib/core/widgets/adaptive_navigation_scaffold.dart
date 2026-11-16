import 'package:flutter/material.dart';

class AdaptiveNavigationScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigationChanged;
  final List<AdaptiveNavigationItem> items;
  final Widget body;
  final Color primaryColor;
  final Widget? headerLeading;

  const AdaptiveNavigationScaffold({
    super.key,
    required this.currentIndex,
    required this.onNavigationChanged,
    required this.items,
    required this.body,
    this.primaryColor = const Color(0xFF002F6C),
    this.headerLeading,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        if (isDesktop) {
          // VISTA ESCRITORIO / PC: Menú Lateral (Sidebar)
          return Scaffold(
            backgroundColor: const Color(0xFFF1F5F9),
            body: Row(
              children: [
                NavigationRail(
                  backgroundColor: Colors.white,
                  selectedIndex: currentIndex,
                  onDestinationSelected: onNavigationChanged,
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme: IconThemeData(color: primaryColor, size: 26),
                  unselectedIconTheme: IconThemeData(color: Colors.grey.shade500, size: 22),
                  selectedLabelTextStyle: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  unselectedLabelTextStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: headerLeading ??
                        CircleAvatar(
                          backgroundColor: primaryColor,
                          radius: 20,
                          child: const Icon(Icons.factory_rounded, color: Colors.white, size: 20),
                        ),
                  ),
                  destinations: items
                      .map(
                        (item) => NavigationRailDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon ?? item.icon),
                          label: Text(item.label),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFE2E8F0)),
                Expanded(child: body),
              ],
            ),
          );
        }

        // VISTA MÓVIL: Barra Inferior (BottomNavigationBar)
        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          body: body,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onNavigationChanged,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey.shade500,
            selectedFontSize: 11,
            unselectedFontSize: 10,
            type: BottomNavigationBarType.fixed,
            items: items
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Icon(item.selectedIcon ?? item.icon),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class AdaptiveNavigationItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const AdaptiveNavigationItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

