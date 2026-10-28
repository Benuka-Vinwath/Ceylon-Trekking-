import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/mock_data.dart';

class ParkingFinderScreen extends StatefulWidget {
  final bool showBack;
  const ParkingFinderScreen({super.key, this.showBack = false});
  @override
  State<ParkingFinderScreen> createState() => _ParkingFinderScreenState();
}

class _ParkingFinderScreenState extends State<ParkingFinderScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final list = _filter == 'All' ? parkingLots : parkingLots.where((p) => p.tags.contains(_filter)).toList();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 360,
            child: FakeMap(me: Offset(.28, .8), pins: [
              MapPin(.22, .45, AppColors.info, Icons.local_parking),
              MapPin(.64, .56, AppColors.info, Icons.local_parking),
              MapPin(.44, .74, AppColors.primary, Icons.terrain),
              MapPin(.78, .34, AppColors.info, Icons.local_parking),
            ]),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  if (widget.showBack) ...[const BackCircle(), const SizedBox(width: 12)],
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: kShadow),
                      child: const Row(children: [Icon(Icons.search, size: 20, color: AppColors.muted), SizedBox(width: 8), Text("Parking near Adam's Peak", style: TextStyle(fontSize: 14, color: AppColors.muted))]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            top: 330,
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28)), boxShadow: kShadowUp),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [const Text("Parking near Adam's Peak", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)), Text('${list.length} locations', style: AppText.small)],
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: ['All', 'Free', 'Paid', 'Covered'].map((l) => Padding(padding: const EdgeInsets.only(right: 8), child: AppChip(label: l, selected: _filter == l, onTap: () => setState(() => _filter = l)))).toList()),
                  ),
                  const SizedBox(height: 16),
                  ...list.map((p) => GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ParkingDetailScreen(lot: p))),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFE4EEF9), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.local_parking, color: AppColors.info)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(p.distance, style: AppText.small),
                                    const SizedBox(height: 4),
                                    Text(p.info, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 6),
                                    const Text('Directions ›', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                  ],
                                ),
                              ),
                              StatusPill(p.status),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParkingDetailScreen extends StatelessWidget {
  final ParkingLot lot;
  const ParkingDetailScreen({super.key, required this.lot});

  Widget _info(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: AppText.small), const SizedBox(height: 6), Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned(top: 0, left: 0, right: 0, height: 330, child: FakeMap(me: Offset(.26, .75), pins: [MapPin(.5, .45, AppColors.info, Icons.local_parking)])),
          Positioned(top: MediaQuery.of(context).padding.top + 8, left: 24, child: const BackCircle()),
          Positioned.fill(
            top: 290,
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28)), boxShadow: kShadowUp),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Expanded(child: Text(lot.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700))), StatusPill(lot.status)]),
                    const SizedBox(height: 6),
                    Text('${lot.address} · ${lot.distance}', style: AppText.small),
                    const SizedBox(height: 18),
                    Row(children: [Expanded(child: _info('Capacity', lot.info.split(' · ').first)), const SizedBox(width: 12), Expanded(child: _info('Fee', lot.info.split(' · ').last))]),
                    const SizedBox(height: 12),
                    Row(children: [Expanded(child: _info('Hours', 'Open 24 h')), const SizedBox(width: 12), Expanded(child: _info('Vehicles', 'Car · Van · Bike'))]),
                    const SizedBox(height: 18),
                    const Text('Facilities', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: ['Toilets', 'Security', 'Tea shop', 'Lighting'].map((l) => AppChip(label: l)).toList()),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFFFCF0DA), borderRadius: BorderRadius.circular(14)),
                      child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(Icons.info_outline, size: 18, color: Color(0xFF8A5A0B)),
                        SizedBox(width: 10),
                        Expanded(child: Text('Availability is community-reported and may change on poya days.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF8A5A0B), height: 1.5))),
                      ]),
                    ),
                    const SizedBox(height: 22),
                    AppButton(
                      label: 'Get directions',
                      icon: Icons.near_me,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Directions will open in the map (coming soon).'))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
