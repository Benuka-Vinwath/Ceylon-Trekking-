import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/mock_data.dart';
import 'trek_summary_screen.dart';

class LiveNavigationScreen extends StatefulWidget {
  final Trek trek;
  const LiveNavigationScreen({super.key, required this.trek});
  @override
  State<LiveNavigationScreen> createState() => _LiveNavigationScreenState();
}

class _LiveNavigationScreenState extends State<LiveNavigationScreen> {
  int _secs = 1 * 3600 + 42 * 60 + 10;
  bool _paused = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_paused && mounted) setState(() => _secs++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(int s) {
    final h = s ~/ 3600;
    final m = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$h:$m:$sec';
  }

  Widget _stat(String value, String label) {
    return Expanded(
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
      body: Stack(
        children: [
          const Positioned.fill(child: FakeMap(route: true, progress: 0.38, routeInsets: EdgeInsets.only(top: 190, bottom: 270, left: 10, right: 10))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const BackCircle(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(20)),
                          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.sensors, size: 16, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Offline mode · GPS locked', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: kShadow),
                    child: Row(children: [
                      Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.tint, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_upward, color: AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                          Text('Next: Seetha Gangula', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          SizedBox(height: 2),
                          Text('1.2 km ahead · +180 m elevation', style: AppText.small),
                        ]),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28)), boxShadow: kShadowUp),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 18),
                    Row(children: [_stat('4.2 km', 'Distance'), _stat(_fmt(_secs), _paused ? 'Paused' : 'Time'), _stat('1,320 m', 'Elevation')]),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('38% of route', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.tint, borderRadius: BorderRadius.circular(13)),
                          child: const Text('✓ On route', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(borderRadius: BorderRadius.circular(4), child: const LinearProgressIndicator(value: 0.38, minHeight: 8, backgroundColor: AppColors.border, color: AppColors.primary)),
                    const SizedBox(height: 18),
                    Row(children: [
                      Expanded(child: AppButton(label: _paused ? 'Resume' : 'Pause', style: BtnStyle.white, icon: _paused ? Icons.play_arrow : Icons.pause, onTap: () => setState(() => _paused = !_paused))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: 'Finish',
                          style: BtnStyle.danger,
                          icon: Icons.stop,
                          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TrekSummaryScreen(trek: widget.trek))),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
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
