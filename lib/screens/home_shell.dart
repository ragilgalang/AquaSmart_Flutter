import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'dashboard_screen.dart';
import 'riwayat_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // IndexedStack menjaga stream Firebase di Dashboard tetap hidup saat pindah tab
      body: IndexedStack(
        index: _index,
        children: const [DashboardScreen(), RiwayatScreen()],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: AppColors.background,
                indicatorColor: AppColors.mint,
                surfaceTintColor: Colors.transparent,
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final isSelected = states.contains(WidgetState.selected);
                  return TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                  );
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final isSelected = states.contains(WidgetState.selected);
                  return IconThemeData(
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                    size: 24,
                  );
                }),
              ),
              child: NavigationBar(
                height: 64,
                elevation: 0,
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.grid_view_outlined),
                    selectedIcon: Icon(Icons.grid_view_rounded),
                    label: 'Dashboard',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.show_chart_rounded),
                    selectedIcon: Icon(Icons.show_chart_rounded),
                    label: 'Riwayat',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
