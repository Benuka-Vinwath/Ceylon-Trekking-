import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../auth/auth_screens.dart';
import '../map/offline_maps_screen.dart';
import '../treks/saved_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // One row of the menu list; rows sit inside a single card, split by thin lines.
  Widget _row(IconData icon, String label, VoidCallback onTap, {Color color = AppColors.text, bool last = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(
          children: [
            Icon(icon, size: 21, color: color == AppColors.text ? AppColors.primary : color),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color))),
            if (color == AppColors.text) const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void soon() => showMessage(context, 'Coming soon');
    void push(Widget s) => Navigator.push(context, MaterialPageRoute(builder: (_) => s));
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.accent, width: 2)),
                child: CircleAvatar(radius: 44, backgroundColor: AppColors.primary, child: Text(userInitial(), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white))),
              ),
              const SizedBox(height: 12),
              Text(Api.user?['full_name'] ?? '', style: AppText.h1.copyWith(fontSize: 22)),
              const SizedBox(height: 2),
              Text(Api.user?['email'] ?? '', style: AppText.small.copyWith(fontSize: 13)),
              const SizedBox(height: 20),
              Container(
                constraints: const BoxConstraints(minHeight: 76),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Loader<Map<String, dynamic>>(
                  load: () async => await Api.get('/hikes/stats'),
                  builder: (s, _) => Row(
                    children: [
                      _ProfileStat('${s['treks']}', 'Treks'),
                      _ProfileStat('${fmtNum(s['distance_km'])} km', 'Distance'),
                      _ProfileStat('${s['reviews']}', 'Reviews'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Column(children: [
                  _row(Icons.favorite_border, 'Saved Treks', () => push(const SavedTreksScreen())),
                  _row(Icons.download_outlined, 'Downloaded Maps', () => push(const OfflineMapsScreen())),
                  _row(Icons.star_outline_rounded, 'My Reviews', soon),
                  _row(Icons.notifications_none, 'Notifications', soon),
                  if (Api.isAdmin) _row(Icons.admin_panel_settings_outlined, 'Admin Dashboard', () => push(const AdminDashboardScreen())),
                  _row(Icons.logout, 'Logout', () {
                    Api.logout();
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
                  }, color: AppColors.danger, last: true),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value, label;
  const _ProfileStat(this.value, this.label);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: AppText.small),
      ]),
    );
  }
}

// ───────── Admin dashboard ─────────
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Widget _stat(String label, dynamic value, Color c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Container(width: 5, height: 44, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(label, style: AppText.small)]),
          ],
        ),
      ),
    );
  }

  Widget _manage(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Row(children: [Icon(icon, size: 20, color: AppColors.primary), const SizedBox(width: 14), Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))), const Icon(Icons.chevron_right, color: AppColors.muted)]),
    );
  }

  // "Remove" deletes the review, "Keep" clears the flag; then the dashboard reloads.
  Future<void> _decide(BuildContext context, int reviewId, bool remove, VoidCallback reload) async {
    try {
      await (remove ? Api.delete('/reviews/$reviewId') : Api.post('/admin/reviews/$reviewId/unflag'));
      reload();
    } on ApiException catch (e) {
      if (context.mounted) showMessage(context, e.message);
    }
  }

  Widget _flagged(BuildContext context, Map<String, dynamic> r, VoidCallback reload) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text('${r['full_name']} · ${r['trek_name']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFFBE5E4), borderRadius: BorderRadius.circular(11)), child: const Text('Reported', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.danger))),
          ]),
          const SizedBox(height: 8),
          Text('“${r['comment']}”', style: const TextStyle(fontSize: 12, color: AppColors.muted, height: 1.5)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: AppButton(label: 'Remove', style: BtnStyle.danger, height: 40, onTap: () => _decide(context, r['id'], true, reload))),
            const SizedBox(width: 12),
            Expanded(child: AppButton(label: 'Keep', style: BtnStyle.white, height: 40, onTap: () => _decide(context, r['id'], false, reload))),
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Loader<List<dynamic>>(
          load: () => Future.wait([Api.get('/admin/stats'), Api.get('/admin/reviews?flagged=true')]),
          builder: (data, reload) {
            final s = data[0] as Map<String, dynamic>;
            final flagged = (data[1] as List).cast<Map<String, dynamic>>();
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              children: [
                Row(children: const [BackCircle(), Expanded(child: Center(child: Text('Admin dashboard', style: AppText.h2))), SizedBox(width: 40)]),
                const SizedBox(height: 20),
                Row(children: [_stat('Treks', s['treks'], AppColors.primary), const SizedBox(width: 12), _stat('Gear shops', s['shops'], AppColors.purple)]),
                const SizedBox(height: 12),
                Row(children: [_stat('Parking', s['parking'], AppColors.info), const SizedBox(width: 12), _stat('Users', s['users'], AppColors.accent)]),
                const SizedBox(height: 24),
                const Text('Manage content', style: AppText.h2),
                const SizedBox(height: 12),
                _manage(Icons.terrain, 'Trek destinations'),
                _manage(Icons.backpack_outlined, 'Gear shops & equipment'),
                _manage(Icons.local_parking, 'Parking locations'),
                _manage(Icons.chat_bubble_outline, 'User reviews'),
                const SizedBox(height: 16),
                const Text('Flagged reviews', style: AppText.h2),
                const SizedBox(height: 12),
                if (flagged.isEmpty) const Text('No flagged reviews. 🎉', style: AppText.small),
                ...flagged.map((r) => _flagged(context, r, reload)),
              ],
            );
          },
        ),
      ),
    );
  }
}
