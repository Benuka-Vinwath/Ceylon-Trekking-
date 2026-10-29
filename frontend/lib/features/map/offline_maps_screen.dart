import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import 'live_navigation_screen.dart';

// A map pack from GET /api/offline-maps, joined with its trek.
class _Pack {
  final Trek trek;
  final double sizeMb;
  final String updated;
  _Pack(this.trek, Map<String, dynamic> j)
      : sizeMb = toDouble(j['size_mb']),
        updated = timeAgo(j['updated_at']);
}

class OfflineMapsScreen extends StatefulWidget {
  const OfflineMapsScreen({super.key});
  @override
  State<OfflineMapsScreen> createState() => _OfflineMapsScreenState();
}

class _OfflineMapsScreenState extends State<OfflineMapsScreen> {
  // shortcut: "downloaded" only means the pack's route was fetched this session; real tile storage needs a map package (e.g. flutter_map + a tile cache).
  static final Set<int> _downloaded = {};
  int? _busy;
  bool _wifiOnly = true;

  Future<List<_Pack>> _load() async {
    final treks = {for (final t in await Api.treks()) t.id: t};
    final packs = await Api.get('/offline-maps') as List;
    return packs.where((j) => treks.containsKey(j['trek_id'])).map((j) => _Pack(treks[j['trek_id']]!, j)).toList();
  }

  Future<void> _download(Trek t) async {
    setState(() => _busy = t.id);
    try {
      await Api.get('/offline-maps/${t.id}');
      _downloaded.add(t.id);
    } on ApiException catch (e) {
      if (mounted) showMessage(context, e.message);
    }
    if (mounted) setState(() => _busy = null);
  }

  Widget _row(Trek t, String sub, {Widget? action}) {
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
        child: Loader<List<_Pack>>(
          load: _load,
          builder: (packs, _) {
            final done = packs.where((p) => _downloaded.contains(p.trek.id)).toList();
            final available = packs.where((p) => !_downloaded.contains(p.trek.id)).toList();
            final usedMb = done.fold<double>(0, (sum, p) => sum + p.sizeMb);
            return ListView(
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
                      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('${fmtNum(usedMb)} MB', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(width: 10),
                        const Padding(padding: EdgeInsets.only(bottom: 5), child: Text('of 2 GB available', style: TextStyle(fontSize: 12, color: Color(0xFFA8CDB9)))),
                      ]),
                      const SizedBox(height: 14),
                      ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: usedMb / 2048, minHeight: 8, backgroundColor: const Color(0x33FFFFFF), color: AppColors.accent)),
                    ],
                  ),
                ),
                if (done.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const Text('Downloaded', style: AppText.h2),
                  const SizedBox(height: 12),
                  ...done.map((p) => _row(p.trek, '${fmtNum(p.sizeMb)} MB · Updated ${p.updated}', action: _pill('Navigate', () => _navigate(p.trek)))),
                ],
                if (available.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const Text('Available', style: AppText.h2),
                  const SizedBox(height: 12),
                  ...available.map((p) => _row(
                        p.trek,
                        '${fmtNum(p.sizeMb)} MB · ${p.trek.region}',
                        action: _busy == p.trek.id
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                            : _pill('⬇ Get', () => _download(p.trek), filled: false),
                      )),
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
            );
          },
        ),
      ),
    );
  }
}
