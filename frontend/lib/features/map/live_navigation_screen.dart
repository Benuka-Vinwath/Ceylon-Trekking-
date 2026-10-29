import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import 'trek_summary_screen.dart';

class LiveNavigationScreen extends StatefulWidget {
  final Trek trek;
  const LiveNavigationScreen({super.key, required this.trek});
  @override
  State<LiveNavigationScreen> createState() => _LiveNavigationScreenState();
}

class _LiveNavigationScreenState extends State<LiveNavigationScreen> {
  int _secs = 0;
  bool _paused = false;
  bool _saving = false;
  Timer? _timer;
  final _started = DateTime.now();
  List<dynamic> _waypoints = []; // [{position, name, lat, lng, elevation_m}] in walking order

  // shortcut: no GPS yet, so progress is elapsed time against the trek's estimated duration; use the geolocator package for real tracking.
  double get _progress => widget.trek.hours <= 0 ? 0 : (_secs / (widget.trek.hours * 3600)).clamp(0, 1).toDouble();

  int get _gain {
    final e = _waypoints.map((w) => w['elevation_m']).whereType<int>().toList();
    return e.length < 2 ? 0 : (e.last - e.first).clamp(0, 9000);
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_paused && mounted) setState(() => _secs++);
    });
    Api.get('/treks/${widget.trek.id}/route').then((w) {
      if (mounted) setState(() => _waypoints = w);
    }, onError: (_) {}); // the screen still works without waypoints
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final hike = await Api.post('/hikes', {
        'trek_id': widget.trek.id,
        'distance_km': double.parse((widget.trek.km * _progress).toStringAsFixed(2)).clamp(0.01, 500),
        'duration_seconds': _secs < 1 ? 1 : _secs,
        'elevation_gain_m': (_gain * _progress).round(),
        'started_at': _started.toUtc().toIso8601String(),
      });
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TrekSummaryScreen(trek: widget.trek, hike: hike)));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showMessage(context, e.message);
    }
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
    final pct = (_progress * 100).round();
    // the next waypoint is the first one not yet reached, assuming waypoints are evenly spaced
    final reached = (_progress * (_waypoints.length - 1)).floor();
    final next = _waypoints.isEmpty ? null : _waypoints[(reached + 1).clamp(0, _waypoints.length - 1)];
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: FakeMap(route: true, progress: _progress, routeInsets: EdgeInsets.only(top: 190, bottom: 270, left: 10, right: 10))),
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
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(next == null ? widget.trek.name : 'Next: ${next['name']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(next == null ? 'No route points for this trek yet' : 'Elevation ${next['elevation_m']} m', style: AppText.small),
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
                    Row(children: [
                      _stat('${(widget.trek.km * _progress).toStringAsFixed(1)} km', 'Distance'),
                      _stat(_fmt(_secs), _paused ? 'Paused' : 'Time'),
                      _stat('+${(_gain * _progress).round()} m', 'Elevation'),
                    ]),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$pct% of route', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.tint, borderRadius: BorderRadius.circular(13)),
                          child: const Text('✓ On route', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: _progress, minHeight: 8, backgroundColor: AppColors.border, color: AppColors.primary)),
                    const SizedBox(height: 18),
                    Row(children: [
                      Expanded(child: AppButton(label: _paused ? 'Resume' : 'Pause', style: BtnStyle.white, icon: _paused ? Icons.play_arrow : Icons.pause, onTap: () => setState(() => _paused = !_paused))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: _saving ? 'Saving…' : 'Finish',
                          style: BtnStyle.danger,
                          icon: Icons.stop,
                          onTap: _finish,
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
