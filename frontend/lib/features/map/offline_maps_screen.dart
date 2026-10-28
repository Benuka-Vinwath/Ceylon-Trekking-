import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/mock_data.dart';
import 'live_navigation_screen.dart';

class OfflineMapsScreen extends StatefulWidget {
  const OfflineMapsScreen({super.key});
  @override
  State<OfflineMapsScreen> createState() => _OfflineMapsScreenState();
}

class _OfflineMapsScreenState extends State<OfflineMapsScreen> {
  bool _wifiOnly = true;
  bool _worldsEndDownloaded = false;

  Widget _row(Trek t, String sub, {Widget? action, Widget? extra}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          SizedBox(width: 56, height: 56, child: MountainScene(colors: t.colors, radius: 12)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(sub, style: AppText.small),
                if (extra != null) ...[const SizedBox(height: 6), extra],
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }

  Widget _pill(String label, VoidCallback onTap, {bool filled = true}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: filled ? AppColors.primary : AppColors.tint, borderRadius: BorderRadius.circular(18)),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: filled ? Colors.white : AppColors.primary)),
      ),
    );
  }

  void _navigate(Trek t) => Navigator.push(context, MaterialPageRoute(builder: (_) => LiveNavigationScreen(trek: t)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            Row(children: const [BackCircle(), Expanded(child: Center(child: Text('Offline maps', style: AppText.h2))), SizedBox(width: 40)]),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(22)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Storage used', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFA8CDB9))),
                  const SizedBox(height: 6),
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: const [
                    Text('148 MB', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white)),
                    SizedBox(width: 10),
                    Padding(padding: EdgeInsets.only(bottom: 5), child: Text('of 2 GB available', style: TextStyle(fontSize: 12, color: Color(0xFFA8CDB9)))),
                  ]),
                  const SizedBox(height: 14),
                  ClipRRect(borderRadius: BorderRadius.circular(4), child: const LinearProgressIndicator(value: 0.074, minHeight: 8, backgroundColor: Color(0x33FFFFFF), color: AppColors.accent)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('Downloaded', style: AppText.h2),
            const SizedBox(height: 12),
            _row(treks[0], '42 MB · Updated 3 days ago', action: _pill('Navigate', () => _navigate(treks[0]))),
            _row(treks[1], '35 MB · Updated 1 week ago', action: _pill('Navigate', () => _navigate(treks[1]), filled: false)),
            if (_worldsEndDownloaded) _row(treks[3], '38 MB · Just now', action: _pill('Navigate', () => _navigate(treks[3]), filled: false)),
            const SizedBox(height: 12),
            const Text('Downloading', style: AppText.h2),
            const SizedBox(height: 12),
            _row(
              treks[2],
              '68% · 14 of 21 MB',
              action: const Icon(Icons.close, color: AppColors.muted, size: 20),
              extra: ClipRRect(borderRadius: BorderRadius.circular(3), child: const LinearProgressIndicator(value: 0.68, minHeight: 5, backgroundColor: AppColors.border, color: AppColors.primary)),
            ),
            if (!_worldsEndDownloaded) ...[
              const SizedBox(height: 12),
              const Text('Available', style: AppText.h2),
              const SizedBox(height: 12),
              _row(treks[3], '38 MB · Horton Plains', action: _pill('⬇ Get', () => setState(() => _worldsEndDownloaded = true))),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Download on Wi-Fi only', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                value: _wifiOnly,
                activeThumbColor: AppColors.primary,
                onChanged: (v) => setState(() => _wifiOnly = v),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Maps include tiles, the trail route and waypoints. GPS works without internet.', style: AppText.small),
          ],
        ),
      ),
    );
  }
}
