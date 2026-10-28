import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../auth/auth_screens.dart';
import '../map/offline_maps_screen.dart';
import '../treks/saved_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _row(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.tint, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: AppColors.primary)),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void soon() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 240,
                  decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF14352A), Color(0xFF2E7D5B)])),
                  child: SafeArea(
                    child: Column(
                      children: const [
                        SizedBox(height: 20),
                        CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Text('S', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.primary))),
                        SizedBox(height: 10),
                        Text('Senuk Yuthmika', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                        SizedBox(height: 2),
                        Text('senuk@example.com', style: TextStyle(fontSize: 13, color: Color(0xFFCFE6DA))),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  top: 205,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: kShadow),
                    child: Row(
                      children: const [
                        _ProfileStat('12', 'Treks'),
                        _ProfileStat('86 km', 'Distance'),
                        _ProfileStat('5', 'Reviews'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 56),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _row(context, Icons.favorite_border, 'Saved treks', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedTreksScreen()))),
                  _row(context, Icons.download_rounded, 'Offline maps', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineMapsScreen()))),
                  _row(context, Icons.star_outline_rounded, 'My reviews', soon),
                  _row(context, Icons.notifications_none, 'Notifications', soon),
                  _row(context, Icons.admin_panel_settings_outlined, 'Admin dashboard', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()))),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), foregroundColor: AppColors.danger, side: const BorderSide(color: Color(0xFFF0C6C4), width: 1.5), shape: const StadiumBorder()),
                    child: const Text('Log out', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
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
      child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: AppText.small),
      ]),
    );
  }
}

// ───────── Admin dashboard ─────────
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _flaggedVisible = true;

  Widget _stat(String label, String value, Color c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Container(width: 5, height: 44, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(label, style: AppText.small)]),
          ],
        ),
      ),
    );
  }

  Widget _manage(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Row(children: [Icon(icon, size: 20, color: AppColors.primary), const SizedBox(width: 14), Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))), const Icon(Icons.chevron_right, color: AppColors.muted)]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            Row(children: const [BackCircle(), Expanded(child: Center(child: Text('Admin dashboard', style: AppText.h2))), SizedBox(width: 40)]),
            const SizedBox(height: 20),
            Row(children: [_stat('Treks', '24', AppColors.primary), const SizedBox(width: 12), _stat('Gear shops', '18', AppColors.purple)]),
            const SizedBox(height: 12),
            Row(children: [_stat('Parking', '31', AppColors.info), const SizedBox(width: 12), _stat('Users', '1,240', AppColors.accent)]),
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
            if (_flaggedVisible)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Expanded(child: Text('Anonymous · Ella Rock', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFFBE5E4), borderRadius: BorderRadius.circular(11)), child: const Text('Reported', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.danger))),
                    ]),
                    const SizedBox(height: 8),
                    const Text('“This review contains inappropriate language…”', style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.5)),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: AppButton(label: 'Remove', style: BtnStyle.danger, height: 40, onTap: () => setState(() => _flaggedVisible = false))),
                      const SizedBox(width: 12),
                      Expanded(child: AppButton(label: 'Keep', style: BtnStyle.white, height: 40, onTap: () => setState(() => _flaggedVisible = false))),
                    ]),
                  ],
                ),
              )
            else
              const Text('No flagged reviews. 🎉', style: AppText.small),
          ],
        ),
      ),
    );
  }
}
