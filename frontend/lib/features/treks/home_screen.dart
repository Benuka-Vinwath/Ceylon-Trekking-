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

  @override
  Widget build(BuildContext context) {
    final list = _filter == 'All' ? _treks : _treks.where((t) => t.difficulty == _filter).toList();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Ayubowan 👋', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.muted)),
                        SizedBox(height: 2),
                        Text('Where to next?', style: AppText.h1),
                      ],
                    ),
                  ),
                  CircleAvatar(radius: 20, backgroundColor: AppColors.primary, child: Text(userInitial(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
              child: Container(
                height: 52,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), border: Border.all(color: AppColors.border, width: 1.5)),
                child: Row(
                  children: [
                    const SizedBox(width: 18),
                    const Icon(Icons.search, color: AppColors.muted),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('Search treks, places…', style: TextStyle(fontSize: 15, color: AppColors.muted))),
                    Container(
                      margin: const EdgeInsets.all(5),
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.tune, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: ['All', 'Easy', 'Moderate', 'Hard']
                    .map((l) => Padding(padding: const EdgeInsets.only(right: 8), child: AppChip(label: l, selected: _filter == l, onTap: () => setState(() => _filter = l))))
                    .toList(),
              ),
            ),
            const SizedBox(height: 22),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: SectionHeader('Featured treks', action: 'See all')),
            const SizedBox(height: 14),
            if (_loading)
              const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(children: [Text(_error!, style: AppText.small), TextButton(onPressed: _load, child: const Text('Retry'))]),
              )
            else if (list.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24), child: Text('No treks match this filter.', style: AppText.small))
            else
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => TrekCard(trek: list[i], onTap: () => openTrek(context, list[i])),
                ),
              ),
            const SizedBox(height: 22),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: SectionHeader('Nearby treks')),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: list.reversed.map((t) => TrekListTile(trek: t, onTap: () => openTrek(context, t))).toList()),
            ),
          ],
        ),
      ),
    );
  }
}
