import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/mock_data.dart';
import '../gear/gear_screens.dart';
import '../map/live_navigation_screen.dart';
import '../map/offline_maps_screen.dart';
import '../parking/parking_screens.dart';
import 'reviews_screen.dart';

class TrekDetailScreen extends StatefulWidget {
  final Trek trek;
  const TrekDetailScreen({super.key, required this.trek});
  @override
  State<TrekDetailScreen> createState() => _TrekDetailScreenState();
}

class _TrekDetailScreenState extends State<TrekDetailScreen> {
  bool _fav = false;

  Widget _quick(IconData icon, String title, String sub, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(sub, style: AppText.small),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trek;
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(top: 0, left: 0, right: 0, height: 290, child: MountainScene(colors: t.colors)),
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 250),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.place, size: 14, color: AppColors.muted),
                          Text(' ${t.region}   ', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                          const Icon(Icons.star_rounded, size: 16, color: AppColors.accent),
                          Text(' ${t.rating} (${t.reviews})', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                        ]),
                        const SizedBox(height: 18),
                        Row(children: [
                          Expanded(child: StatBox('Distance', t.distance)),
                          const SizedBox(width: 8),
                          Expanded(child: StatBox('Duration', t.duration)),
                          const SizedBox(width: 8),
                          Expanded(child: StatBox('Elevation', t.elevation)),
                          const SizedBox(width: 8),
                          Expanded(child: StatBox('Level', t.difficulty, valueColor: DifficultyBadge.fg(t.difficulty))),
                        ]),
                        const SizedBox(height: 22),
                        const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(t.about, style: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.55)),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: const Color(0xFFFCF0DA), borderRadius: BorderRadius.circular(14)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFF8A5A0B)),
                              const SizedBox(width: 10),
                              Expanded(child: Text('Safety: ${t.safety}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF8A5A0B), height: 1.5))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(children: [
                          _quick(Icons.local_parking, 'Parking', '2 nearby', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParkingFinderScreen(showBack: true)))),
                          const SizedBox(width: 10),
                          _quick(Icons.backpack_outlined, 'Gear shops', '3 nearby', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GearShopsScreen(showBack: true)))),
                        ]),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewsScreen(trek: t))),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                            child: Row(children: [
                              const StarRating(5, size: 18),
                              const SizedBox(width: 12),
                              Text('${t.rating}  ·  ${t.reviews} reviews', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const Spacer(),
                              const Icon(Icons.chevron_right, color: AppColors.muted),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(top: top + 8, left: 24, child: const BackCircle()),
          Positioned(top: top + 8, right: 24, child: BackCircle(icon: _fav ? Icons.favorite : Icons.favorite_border, onTap: () => setState(() => _fav = !_fav))),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(child: AppButton(label: 'Offline map', style: BtnStyle.outline, icon: Icons.download_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineMapsScreen())))),
              const SizedBox(width: 12),
              Expanded(child: AppButton(label: 'Start Trek', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LiveNavigationScreen(trek: t))))),
            ],
          ),
        ),
      ),
    );
  }
}
