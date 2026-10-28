import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _difficulty = 'Moderate';
  String _distance = '5 – 10 km';
  final Set<String> _regions = {'Uva', 'Central'};
  RangeValues _hours = const RangeValues(1, 5);
  String _sort = 'Top rated';
  final _q = TextEditingController(text: 'Ella');

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _reset() => setState(() {
        _difficulty = 'Any';
        _distance = 'Any';
        _regions.clear();
        _hours = const RangeValues(0.5, 8);
        _sort = 'Top rated';
      });

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
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                        suffixIcon: const Icon(Icons.close, size: 18, color: AppColors.muted),
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
                        Text('${_hours.start.toStringAsFixed(0)} – ${_hours.end.toStringAsFixed(0)} h', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ],
                    ),
                    RangeSlider(values: _hours, min: 0, max: 8, divisions: 8, activeColor: AppColors.primary, onChanged: (v) => setState(() => _hours = v)),
                    const SizedBox(height: 12),
                    _group('Sort by', ['Top rated', 'Nearest', 'Shortest'], (o) => _sort == o, (o) => _sort = o),
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
                  Expanded(child: AppButton(label: 'Show 8 treks', onTap: () => Navigator.pop(context))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
