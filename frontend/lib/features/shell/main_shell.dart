import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../treks/home_screen.dart';
import '../map/map_screen.dart';
import '../gear/gear_screens.dart';
import '../parking/parking_screens.dart';
import '../profile/profile_screens.dart';

/// Opens the main app (with bottom navigation) and clears earlier screens.
void goToMain(BuildContext context) {
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainShell()), (r) => false);
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _i = 0;

  static const _labels = ['Explore', 'Map', 'Gear', 'Parking', 'Profile'];
  static const _icons = [Icons.explore_outlined, Icons.map_outlined, Icons.backpack_outlined, Icons.local_parking, Icons.person_outline];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _i,
        children: const [HomeScreen(), MapScreen(), GearShopsScreen(), ParkingFinderScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(5, (i) {
                final on = i == _i;
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _i = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_icons[i], size: 24, color: on ? AppColors.primary : AppColors.muted),
                        const SizedBox(height: 3),
                        Text(_labels[i], style: TextStyle(fontSize: 11, fontWeight: on ? FontWeight.w600 : FontWeight.w500, color: on ? AppColors.primary : AppColors.muted)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
