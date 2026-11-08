import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/api.dart';
import '../../data/models.dart';
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

  @override
  void initState() {
    super.initState();
    Api.saved().then((list) {
      if (mounted) setState(() => _fav = list.any((s) => s.id == widget.trek.id));
    }, onError: (_) {}); // heart just stays empty if this fails
  }

  Future<void> _toggleFav() async {
    final on = !_fav;
    setState(() => _fav = on);
    try {
      await (on ? Api.put('/saved/${widget.trek.id}') : Api.delete('/saved/${widget.trek.id}'));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _fav = !on);
      showMessage(context, e.message);
    }
  }

  void _push(Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  Widget _stat(IconData icon, String value, String label, {Color? color}) {
    return Expanded(
      child: Column(children: [
        Icon(icon, size: 22, color: color ?? AppColors.primary),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: AppText.small),
      ]),
    );
  }

  Widget _tab(String label, {VoidCallback? onTap}) {
    final on = onTap == null; // Overview is the current section, the others open their own screen
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(color: on ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: on ? Colors.white : AppColors.muted)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trek;
    final top = MediaQuery.of(context).padding.top;
    const divider = SizedBox(height: 40, child: VerticalDivider(color: AppColors.border, width: 1));
    return Scaffold(
      body: Stack(
        children: [
          Positioned(top: 0, left: 0, right: 0, height: 320, child: MountainScene(colors: t.colors)),
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 280),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                    decoration: const BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name, style: AppText.h1),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.star_rounded, size: 18, color: AppColors.star),
                          Text(' ${t.rating}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.star)),
                          Text('  (${t.reviews} reviews)', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                        ]),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.place, size: 15, color: AppColors.primary),
                          Text(' ${t.region}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
                        ]),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                          child: Row(children: [
                            _stat(Icons.route, t.distance, 'Distance'),
                            divider,
                            _stat(Icons.schedule, t.duration, 'Duration'),
                            divider,
                            _stat(Icons.hiking, t.difficulty, 'Difficulty', color: AppColors.accent),
                            divider,
                            _stat(Icons.landscape_outlined, t.elevation, 'Elevation'),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                          child: Row(children: [
                            _tab('Overview'),
                            _tab('Parking', onTap: () => _push(ParkingFinderScreen(showBack: true, trek: t))),
                            _tab('Gear', onTap: () => _push(const GearShopsScreen(showBack: true))),
                            _tab('Reviews', onTap: () => _push(ReviewsScreen(trek: t))),
                          ]),
                        ),
                        const SizedBox(height: 18),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(top: top + 8, left: 24, child: const BackCircle()),
          Positioned(top: top + 8, right: 24, child: BackCircle(icon: _fav ? Icons.favorite : Icons.favorite_border, onTap: _toggleFav)),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        decoration: const BoxDecoration(color: AppColors.card, border: Border(top: BorderSide(color: AppColors.border))),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(child: AppButton(label: 'Offline map', style: BtnStyle.green, icon: Icons.download_rounded, onTap: () => _push(const OfflineMapsScreen()))),
              const SizedBox(width: 12),
              Expanded(child: AppButton(label: 'Start Trek', icon: Icons.navigation_outlined, onTap: () => _push(LiveNavigationScreen(trek: t)))),
            ],
          ),
        ),
      ),
    );
  }
}
