import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import 'home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _difficulty = 'Any';
  String _distance = 'Any';
  final Set<String> _regions = {};
  RangeValues _hours = const RangeValues(0, 8);
  String _sort = 'Top rated';
  final _q = TextEditingController();
  late final Future<List<Trek>> _all = Api.treks(); // only 4–50 treks, so filter on the phone

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _reset() => setState(() {
        _q.clear();
        _difficulty = 'Any';
        _distance = 'Any';
        _regions.clear();
        _hours = const RangeValues(0, 8);
        _sort = 'Top rated';
      });

  List<Trek> _filter(List<Trek> all) {
    final q = _q.text.trim().toLowerCase();
    final list = all.where((t) {
      if (q.isNotEmpty && !t.name.toLowerCase().contains(q) && !t.region.toLowerCase().contains(q)) return false;
      if (_difficulty != 'Any' && t.difficulty != _difficulty) return false;
      if (_distance == 'Under 5 km' && t.km >= 5) return false;
      if (_distance == '5 – 10 km' && (t.km < 5 || t.km > 10)) return false;
      if (_distance == '10 km +' && t.km <= 10) return false;
      if (_regions.isNotEmpty && !_regions.contains(t.region)) return false;
      return t.hours >= _hours.start && (_hours.end >= 8 || t.hours <= _hours.end); // 8 on the slider means "8 h or more"
    }).toList();
    if (_sort == 'Top rated') list.sort((a, b) => b.rating.compareTo(a.rating));
    if (_sort == 'Shortest') list.sort((a, b) => a.km.compareTo(b.km));
    return list;
  }

  Widget _group(String title, List<String> options, bool Function(String) selected, void Function(String) onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: options.map((o) => AppChip(label: o, selected: selected(o), onTap: () => setState(() => onTap(o)))).toList()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Row(
                children: [
                  BackCircle(bg: AppColors.bg),
                  const Expanded(child: Center(child: Text('Search & filters', style: AppText.h2))),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _q,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Trek or region',
                        prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                        suffixIcon: IconButton(icon: const Icon(Icons.close, size: 18, color: AppColors.muted), onPressed: () => setState(_q.clear)),
                        filled: true,
                        fillColor: AppColors.bg,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _group('Difficulty', ['Any', 'Easy', 'Moderate', 'Hard'], (o) => _difficulty == o, (o) => _difficulty = o),
                    _group('Distance', ['Any', 'Under 5 km', '5 – 10 km', '10 km +'], (o) => _distance == o, (o) => _distance = o),
                    _group('Region', ['Central', 'Uva', 'Sabaragamuwa', 'Southern', 'Northern'], (o) => _regions.contains(o), (o) => _regions.contains(o) ? _regions.remove(o) : _regions.add(o)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estimated duration', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        Text('${_hours.start.toStringAsFixed(0)} – ${_hours.end.toStringAsFixed(0)}${_hours.end >= 8 ? '+' : ''} h', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ],
                    ),
                    RangeSlider(values: _hours, min: 0, max: 8, divisions: 8, activeColor: AppColors.primary, onChanged: (v) => setState(() => _hours = v)),
                    const SizedBox(height: 12),
                    _group('Sort by', ['Top rated', 'Shortest'], (o) => _sort == o, (o) => _sort = o),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
              child: Row(
                children: [
                  SizedBox(width: 100, child: AppButton(label: 'Reset', style: BtnStyle.white, onTap: _reset)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FutureBuilder<List<Trek>>(
                      future: _all,
                      builder: (context, s) {
                        if (s.hasError) return AppButton(label: 'Server unreachable', onTap: () => showMessage(context, '${s.error}'));
                        if (!s.hasData) return AppButton(label: 'Loading…', onTap: () {});
                        final results = _filter(s.data!);
                        return AppButton(
                          label: 'Show ${results.length} treks',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _ResultsScreen(results))),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsScreen extends StatelessWidget {
  final List<Trek> treks;
  const _ResultsScreen(this.treks);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            Row(children: const [BackCircle(), Expanded(child: Center(child: Text('Results', style: AppText.h2))), SizedBox(width: 40)]),
            const SizedBox(height: 16),
            if (treks.isEmpty) const Text('No treks match these filters.', style: AppText.small),
            ...treks.map((t) => TrekListTile(trek: t, onTap: () => openTrek(context, t))),
          ],
        ),
      ),
    );
  }
}
