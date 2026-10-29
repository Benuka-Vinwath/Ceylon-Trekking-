import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/api.dart';
import '../../data/models.dart';

class ReviewsScreen extends StatelessWidget {
  final Trek trek;
  const ReviewsScreen({super.key, required this.trek});

  Widget _summary(List<ReviewItem> reviews) {
    final avg = reviews.isEmpty ? 0.0 : reviews.map((r) => r.stars).reduce((a, b) => a + b) / reviews.length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(avg.toStringAsFixed(1), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700)),
              StarRating(avg.round()),
              const SizedBox(height: 6),
              Text('${reviews.length} reviews', style: AppText.small),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final share = reviews.isEmpty ? 0.0 : reviews.where((r) => r.stars == 5 - i).length / reviews.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Text('${5 - i}', style: AppText.small),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(value: share, minHeight: 6, backgroundColor: AppColors.border, color: AppColors.accent),
                      ),
                    ),
                  ]),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _review(ReviewItem r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(radius: 20, backgroundColor: AppColors.tint, child: Text(r.name.isEmpty ? '?' : r.name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), Text(r.when, style: AppText.small)])),
            StarRating(r.stars, size: 14),
          ]),
          if (r.text.isNotEmpty) ...[const SizedBox(height: 12), Text(r.text, style: const TextStyle(fontSize: 13, height: 1.5))],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Loader<List<ReviewItem>>(
          load: () => Api.reviews(trek.id),
          builder: (reviews, reload) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                child: Row(children: const [BackCircle(), Expanded(child: Center(child: Text('Reviews', style: AppText.h2))), SizedBox(width: 40)]),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  children: [
                    _summary(reviews),
                    const SizedBox(height: 16),
                    if (reviews.isEmpty) const Text('No reviews yet. Be the first!', style: AppText.small),
                    ...reviews.map(_review),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: AppButton(
                  label: 'Write a review',
                  icon: Icons.edit_outlined,
                  onTap: () async {
                    final posted = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => WriteReviewScreen(trek: trek)));
                    if (posted == true) reload();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WriteReviewScreen extends StatefulWidget {
  final Trek trek;
  const WriteReviewScreen({super.key, required this.trek});
  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _stars = 4;
  final Set<String> _tags = {};
  final _comment = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      await Api.post('/treks/${widget.trek.id}/reviews', {'rating': _stars, 'comment': _comment.text.trim(), 'tags': _tags.toList()});
      if (!mounted) return;
      showMessage(context, 'Thanks! Your review was submitted.');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      showMessage(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trek;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Row(children: [BackCircle(bg: AppColors.bg), const Expanded(child: Center(child: Text('Write a review', style: AppText.h2))), const SizedBox(width: 40)]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(18)),
                      child: Row(children: [
                        SizedBox(width: 64, height: 64, child: MountainScene(colors: t.colors, radius: 14)),
                        const SizedBox(width: 14),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t.name, style: AppText.title), const SizedBox(height: 4), Text('${t.region} · ${t.difficulty} · ${t.distance}', style: AppText.small)]),
                      ]),
                    ),
                    const SizedBox(height: 26),
                    const Center(child: Text('How was your trek?', style: AppText.title)),
                    const SizedBox(height: 12),
                    Center(child: StarRating(_stars, size: 44, onChanged: (v) => setState(() => _stars = v))),
                    const SizedBox(height: 26),
                    const Text('Add tags', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      // must match TAGS in backend/src/routes/reviews.js
                      children: ['Great views', 'Well marked', 'Crowded', 'Challenging', 'Family friendly']
                          .map((l) => AppChip(label: l, selected: _tags.contains(l), onTap: () => setState(() => _tags.contains(l) ? _tags.remove(l) : _tags.add(l))))
                          .toList(),
                    ),
                    const SizedBox(height: 22),
                    AppField(label: 'Your review', hint: 'Share trail conditions, tips and what you loved…', maxLines: 5, controller: _comment),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: AppButton(label: _sending ? 'Sending…' : 'Submit review', onTap: _submit),
            ),
          ],
        ),
      ),
    );
  }
}
