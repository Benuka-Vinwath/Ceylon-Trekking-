import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../treks/reviews_screen.dart';

class TrekSummaryScreen extends StatelessWidget {
  final Trek trek;
  final Map<String, dynamic> hike; // the saved hike returned by POST /api/hikes
  const TrekSummaryScreen({super.key, required this.trek, required this.hike});

  String _time(int s) => '${s ~/ 3600}:${((s % 3600) ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  Widget _stat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(18)),
      child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, style: AppText.small),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned(top: 0, left: 0, right: 0, height: 300, child: FakeMap(route: true, progress: 1, routeInsets: EdgeInsets.fromLTRB(40, 70, 40, 50))),
          Positioned(top: MediaQuery.of(context).padding.top + 8, left: 24, child: BackCircle(onTap: () => Navigator.popUntil(context, (r) => r.isFirst))),
          Positioned.fill(
            top: 270,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28)), boxShadow: kShadowUp),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text('Trek complete 🎉', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('${trek.name} · Today', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                    const SizedBox(height: 22),
                    Row(children: [Expanded(child: _stat('${fmtNum(hike['distance_km'])} km', 'Distance')), const SizedBox(width: 12), Expanded(child: _stat(_time(hike['duration_seconds']), 'Time'))]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _stat('${hike['elevation_gain_m']} m', 'Elevation gain')),
                      const SizedBox(width: 12),
                      Expanded(child: _stat('${fmtNum(hike['avg_pace_min_per_km'])} min/km', 'Avg pace')),
                    ]),
                    const SizedBox(height: 18),
                    const Text('Your hike is saved to your profile.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.5)),
                    const SizedBox(height: 22),
                    AppButton(label: 'Rate this trek', icon: Icons.star_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WriteReviewScreen(trek: trek)))),
                    const SizedBox(height: 12),
                    AppButton(label: 'Back to home', style: BtnStyle.white, height: 52, onTap: () => Navigator.popUntil(context, (r) => r.isFirst)),
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
