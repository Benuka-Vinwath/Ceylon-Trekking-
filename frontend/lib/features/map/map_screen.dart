import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../treks/home_screen.dart';
import '../treks/search_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Set<String> _layers = {'Treks'};

  @override
  Widget build(BuildContext context) {
    final pins = <MapPin>[];
    if (_layers.contains('Treks')) {
      pins.addAll(const [
        MapPin(.2, .28, AppColors.primary, Icons.terrain),
        MapPin(.66, .36, AppColors.accent, Icons.terrain),
        MapPin(.4, .52, AppColors.danger, Icons.terrain),
      ]);
    }
    if (_layers.contains('Parking')) {
      pins.addAll(const [MapPin(.75, .58, AppColors.info, Icons.local_parking), MapPin(.3, .7, AppColors.info, Icons.local_parking)]);
    }
    if (_layers.contains('Gear shops')) {
      pins.addAll(const [MapPin(.16, .62, AppColors.purple, Icons.backpack), MapPin(.58, .22, AppColors.purple, Icons.backpack)]);
    }
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: FakeMap(pins: pins, me: const Offset(.5, .45))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), boxShadow: kShadow),
                      child: const Row(children: [Icon(Icons.search, color: AppColors.muted), SizedBox(width: 10), Text('Search on map', style: TextStyle(fontSize: 15, color: AppColors.muted))]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: ['Treks', 'Parking', 'Gear shops']
                        .map((l) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: DecoratedBox(
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: kShadow),
                                child: AppChip(label: l, selected: _layers.contains(l), onTap: () => setState(() => _layers.contains(l) ? _layers.remove(l) : _layers.add(l))),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 190,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: kShadow),
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            height: 130,
            // swipe sideways through the treks
            child: Loader<List<Trek>>(load: Api.treks, builder: (treks, _) => PageView(controller: PageController(viewportFraction: .88), children: treks.map((t) => _card(t)).toList())),
          ),
        ],
      ),
    );
  }

  Widget _card(Trek trek) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
              onTap: () => openTrek(context, trek),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: kShadowUp),
                child: Row(
                  children: [
                    SizedBox(width: 96, height: 96, child: MountainScene(colors: trek.colors, radius: 16)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [Expanded(child: Text(trek.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))), const Icon(Icons.star_rounded, size: 16, color: AppColors.accent), Text(' ${trek.rating}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))]),
                          const SizedBox(height: 4),
                          Text(trek.region, style: AppText.small),
                          const SizedBox(height: 6),
                          Text('${trek.distance}   ${trek.duration}   ${trek.elevation}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Row(children: [DifficultyBadge(trek.difficulty), const Spacer(), const Text('View details ›', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary))]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
