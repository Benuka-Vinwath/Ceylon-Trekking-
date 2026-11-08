import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import 'search_screen.dart';
import 'trek_detail_screen.dart';

Future<void> openTrek(BuildContext context, Trek t) => Navigator.push(context, MaterialPageRoute(builder: (_) => TrekDetailScreen(trek: t)));

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = 'All';
  List<Trek> _treks = [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _treks = await Api.treks();
    } on ApiException catch (e) {
      _error = e.message;
    }
    if (mounted) setState(() => _loading = false);
  }

  static const _levels = {'All': Icons.apps, 'Easy': Icons.directions_walk, 'Moderate': Icons.hiking, 'Hard': Icons.terrain};

  void _openSearch() => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));

  Widget _header(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))),
        if (onSeeAll != null) GestureDetector(onTap: onSeeAll, child: const Text('See All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent))),
      ]),
    );
  }

  Widget _level(String label, IconData icon) {
    final on = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: Column(children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: on ? AppColors.accent : AppColors.darkCard, borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: on ? Colors.white : AppColors.onDark)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filter == 'All' ? _treks : _treks.where((t) => t.difficulty == _filter).toList();
    final popular = [...list]..sort((a, b) => b.rating.compareTo(a.rating));
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning,' : (hour < 17 ? 'Good Afternoon,' : 'Good Evening,');
    final first = ((Api.user?['full_name'] ?? '') as String).split(' ').first;
    const onDarkSmall = TextStyle(fontSize: 13, color: AppColors.onDark);
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              child: Row(
                children: [
                  const Icon(Icons.landscape_outlined, color: Colors.white, size: 26),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('CEYLON TREKKING', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2, color: Colors.white))),
                  const Icon(Icons.notifications_none, color: Colors.white),
                  const SizedBox(width: 14),
                  CircleAvatar(radius: 18, backgroundColor: AppColors.accent, child: Text(userInitial(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(greeting, style: const TextStyle(fontSize: 15, color: AppColors.onDark)),
                const SizedBox(height: 2),
                Text('${first.isEmpty ? 'Explorer' : first}!', style: AppText.display.copyWith(color: Colors.white)),
              ]),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: _openSearch,
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
                child: const Row(children: [
                  Icon(Icons.search, color: AppColors.muted),
                  SizedBox(width: 10),
                  Expanded(child: Text('Search treks, locations…', style: TextStyle(fontSize: 15, color: AppColors.muted))),
                  Icon(Icons.tune, color: AppColors.primary, size: 20),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(children: [Text(_error!, style: onDarkSmall), TextButton(onPressed: _load, child: const Text('Retry', style: TextStyle(color: AppColors.accent)))]),
              )
            else ...[
              if (popular.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TrekCard(trek: popular.first, width: MediaQuery.of(context).size.width - 48, height: 190, onTap: () => openTrek(context, popular.first)),
                ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: _levels.entries.map((e) => _level(e.key, e.value)).toList()),
              ),
              const SizedBox(height: 24),
              _header('Popular Treks', onSeeAll: _openSearch),
              const SizedBox(height: 12),
              if (list.isEmpty)
                const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('No treks match this filter.', style: onDarkSmall))
              else
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: popular.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => TrekCard(trek: popular[i], width: 120, height: 150, onTap: () => openTrek(context, popular[i])),
                  ),
                ),
              const SizedBox(height: 24),
              _header('All Treks'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(children: list.map((t) => TrekListTile(trek: t, onTap: () => openTrek(context, t))).toList()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
