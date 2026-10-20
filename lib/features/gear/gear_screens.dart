import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/mock_data.dart';

class GearShopsScreen extends StatelessWidget {
  final bool showBack;
  const GearShopsScreen({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            if (showBack) ...[const Align(alignment: Alignment.centerLeft, child: BackCircle()), const SizedBox(height: 12)],
            const Text('Gear shops', style: AppText.h1),
            const SizedBox(height: 4),
            const Text('Rent trekking & camping equipment near trailheads', style: TextStyle(fontSize: 13, color: AppColors.muted)),
            const SizedBox(height: 16),
            const SizedBox(
              height: 170,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: FakeMap(me: Offset(.35, .75), pins: [
                  MapPin(.18, .3, AppColors.purple, Icons.backpack),
                  MapPin(.5, .5, AppColors.purple, Icons.backpack),
                  MapPin(.76, .28, AppColors.purple, Icons.backpack),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            ...gearShops.map((s) => GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShopDetailScreen(shop: s))),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 56, height: 56, decoration: BoxDecoration(color: const Color(0xFFEFE8FA), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.backpack, color: AppColors.purple, size: 26)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(s.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(s.area, style: AppText.small),
                                const SizedBox(height: 6),
                                Text(s.items, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              ]),
                            ),
                            Row(children: [const Icon(Icons.star_rounded, size: 16, color: AppColors.accent), Text(' ${s.rating}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))]),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [StatusPill(s.status), const Text('View equipment ›', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary))],
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class ShopDetailScreen extends StatelessWidget {
  final GearShop shop;
  const ShopDetailScreen({super.key, required this.shop});

  void _soon(BuildContext context, String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned(top: 0, left: 0, right: 0, height: 230, child: MountainScene(colors: [Color(0xFFC9B6EA), Color(0xFF6B4BB0)])),
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 200),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shop.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text('${shop.address} · ${shop.area.split(' · ').last}', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                        const SizedBox(height: 4),
                        Text('${shop.hours}   ★ ${shop.rating}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 18),
                        Row(children: [
                          Expanded(child: AppButton(label: 'Call shop', icon: Icons.call, height: 52, onTap: () => _soon(context, 'Calling is available on a real device.'))),
                          const SizedBox(width: 12),
                          Expanded(child: AppButton(label: 'Directions', icon: Icons.near_me, style: BtnStyle.outline, height: 52, onTap: () => _soon(context, 'Directions will open in the map (coming soon).'))),
                        ]),
                        const SizedBox(height: 24),
                        const Text('Available equipment', style: AppText.h2),
                        const SizedBox(height: 12),
                        ...equipment.map((e) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(14)),
                              child: Row(children: [
                                Icon(e.icon, color: AppColors.primary, size: 24),
                                const SizedBox(width: 14),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(e.price, style: AppText.small)])),
                                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.tint, borderRadius: BorderRadius.circular(12)), child: const Text('In stock', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary))),
                              ]),
                            )),
                        const SizedBox(height: 8),
                        const Text('Rental is arranged directly with the shop. Call to confirm availability.', style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(top: MediaQuery.of(context).padding.top + 8, left: 24, child: const BackCircle()),
        ],
      ),
    );
  }
}
