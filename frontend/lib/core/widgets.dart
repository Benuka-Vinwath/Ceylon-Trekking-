import 'package:flutter/material.dart';
import '../data/api.dart';
import '../data/models.dart';
import 'theme.dart';

const List<BoxShadow> kShadow = [BoxShadow(color: Color(0x1F000000), blurRadius: 12, offset: Offset(0, 3))];
const List<BoxShadow> kShadowUp = [BoxShadow(color: Color(0x1F000000), blurRadius: 20, offset: Offset(0, -4))];

// ───────── Buttons ─────────
// primary = orange call-to-action, green = forest green secondary action
enum BtnStyle { primary, green, outline, danger, white, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final BtnStyle style;
  final double height;
  final IconData? icon;
  const AppButton({super.key, required this.label, this.onTap, this.style = BtnStyle.primary, this.height = 54, this.icon});

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.accent;
    Color fg = Colors.white;
    BorderSide side = BorderSide.none;
    switch (style) {
      case BtnStyle.primary:
        break;
      case BtnStyle.green:
        bg = AppColors.primary;
        break;
      case BtnStyle.outline:
        bg = Colors.transparent;
        fg = AppColors.primary;
        side = const BorderSide(color: AppColors.primary, width: 1.5);
        break;
      case BtnStyle.danger:
        bg = AppColors.danger;
        break;
      case BtnStyle.white:
        bg = AppColors.card;
        fg = AppColors.text;
        side = const BorderSide(color: AppColors.border, width: 1.5);
        break;
      case BtnStyle.ghost:
        bg = Colors.transparent;
        break;
    }
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: side),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}

class AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const AppChip({super.key, required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: selected ? null : Border.all(color: AppColors.border, width: 1.2),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: selected ? Colors.white : AppColors.text)),
      ),
    );
  }
}

class DifficultyBadge extends StatelessWidget {
  final String level;
  const DifficultyBadge(this.level, {super.key});

  static Color fg(String l) => l == 'Easy' ? const Color(0xFF2E9E6B) : (l == 'Moderate' ? const Color(0xFFC77C0E) : const Color(0xFFD9534F));
  static Color bg(String l) => l == 'Easy' ? const Color(0xFFE3F5EC) : (l == 'Moderate' ? const Color(0xFFFCF0DA) : const Color(0xFFFBE5E4));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(color: bg(level), borderRadius: BorderRadius.circular(12)),
      child: Text(level, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg(level))),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String text;
  const StatusPill(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    final ok = text == 'Open';
    final warn = text == 'Limited';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(
        color: ok ? AppColors.tint : (warn ? const Color(0xFFFCF0DA) : AppColors.bg),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ok ? AppColors.primary : (warn ? const Color(0xFFC77C0E) : AppColors.muted))),
    );
  }
}

// ───────── Misc small widgets ─────────
class BackCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color bg;
  const BackCircle({super.key, this.icon = Icons.arrow_back, this.onTap, this.bg = AppColors.card});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.maybePop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle, boxShadow: kShadow),
        child: Icon(icon, size: 20, color: AppColors.text),
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  final int value;
  final double size;
  final ValueChanged<int>? onChanged;
  const StarRating(this.value, {super.key, this.size = 16, this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final star = Icon(Icons.star_rounded, size: size, color: i < value ? AppColors.star : const Color(0xFFDCD5C6));
        if (onChanged == null) return star;
        return GestureDetector(onTap: () => onChanged!(i + 1), child: star);
      }),
    );
  }
}

// Runs load() once and shows a spinner, the error with a Retry button, or builder(data, reload).
class Loader<T> extends StatefulWidget {
  final Future<T> Function() load;
  final Widget Function(T data, VoidCallback reload) builder;
  const Loader({super.key, required this.load, required this.builder});
  @override
  State<Loader<T>> createState() => _LoaderState<T>();
}

class _LoaderState<T> extends State<Loader<T>> {
  late Future<T> _future = widget.load();

  void _reload() => setState(() => _future = widget.load());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, s) {
        if (s.connectionState != ConnectionState.done) return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
        if (s.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${s.error}', textAlign: TextAlign.center, style: AppText.small),
                TextButton(onPressed: _reload, child: const Text('Retry')),
              ]),
            ),
          );
        }
        return widget.builder(s.data as T, _reload);
      },
    );
  }
}

String userInitial() {
  final name = (Api.user?['full_name'] ?? '') as String;
  return name.isEmpty ? '?' : name[0].toUpperCase();
}

void showMessage(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

class AppField extends StatelessWidget {
  final String label, hint; // empty label = no label above the field
  final bool obscure, dark;
  final int maxLines;
  final IconData? icon;
  final TextEditingController? controller;
  const AppField({super.key, this.label = '', required this.hint, this.obscure = false, this.maxLines = 1, this.controller, this.icon, this.dark = false});

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder b(Color c) => OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c, width: 1.2));
    final muted = dark ? const Color(0xFF9FB3A6) : AppColors.muted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: dark ? AppColors.onDark : AppColors.text)), const SizedBox(height: 8)],
        TextField(
          controller: controller,
          obscureText: obscure,
          maxLines: obscure ? 1 : maxLines,
          style: TextStyle(color: dark ? Colors.white : AppColors.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: muted, fontSize: 15),
            prefixIcon: icon == null ? null : Icon(icon, size: 20, color: muted),
            filled: true,
            fillColor: dark ? AppColors.darkCard : AppColors.card,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: b(dark ? AppColors.darkCard : AppColors.border),
            enabledBorder: b(dark ? AppColors.darkCard : AppColors.border),
            focusedBorder: b(dark ? AppColors.accent : AppColors.primary),
          ),
        ),
      ],
    );
  }
}

// Mountain outline + "CEYLON / TREKKING" word mark (splash, login).
class BrandLogo extends StatelessWidget {
  final double scale;
  const BrandLogo({super.key, this.scale = 1});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.landscape_outlined, size: 64 * scale, color: Colors.white),
        Text('CEYLON', style: TextStyle(fontFamily: 'serif', fontSize: 40 * scale, fontWeight: FontWeight.w600, letterSpacing: 4 * scale, color: Colors.white, height: 1.1)),
        Text('TREKKING', style: TextStyle(fontSize: 15 * scale, fontWeight: FontWeight.w500, letterSpacing: 9 * scale, color: Colors.white)),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppText.h2),
        if (action != null) GestureDetector(onTap: onAction, child: Text(action!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary))),
      ],
    );
  }
}

class StatBox extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const StatBox(this.label, this.value, {super.key, this.valueColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.text)),
          const SizedBox(height: 4),
          Text(label, style: AppText.small),
        ],
      ),
    );
  }
}

// ───────── Mountain illustration (placeholder for photos) ─────────
class MountainPainter extends CustomPainter {
  const MountainPainter();
  // Ridges as (x, y) fractions, back to front; the see-through back ridges fade into the sky like haze.
  static const _ridges = [
    [0.0, .55, .12, .42, .22, .5, .38, .22, .5, .4, .62, .3, .78, .48, .9, .38, 1.0, .46],
    [0.0, .7, .18, .5, .3, .62, .46, .45, .6, .6, .75, .5, .88, .62, 1.0, .55],
    [0.0, .82, .2, .68, .4, .8, .58, .7, .8, .84, 1.0, .74],
    [0.0, .95, .25, .86, .5, .94, .75, .88, 1.0, .96],
  ];
  static const _ridgeColors = [Color(0x591F4D36), Color(0x991F4D36), AppColors.primary, AppColors.dark];

  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    c.drawCircle(Offset(w * .72, h * .3), w * .07, Paint()..color = const Color(0x80FFF3D6));
    for (var r = 0; r < _ridges.length; r++) {
      final pts = _ridges[r];
      final p = Path()..moveTo(0, h);
      for (var i = 0; i < pts.length; i += 2) {
        p.lineTo(pts[i] * w, pts[i + 1] * h);
      }
      p
        ..lineTo(w, h)
        ..close();
      c.drawPath(p, Paint()..color = _ridgeColors[r]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MountainScene extends StatelessWidget {
  final List<Color> colors;
  final double radius;
  final Widget? child;
  const MountainScene({super.key, required this.colors, this.radius = 0, this.child});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors))),
          const CustomPaint(painter: MountainPainter()),
          ?child,
        ],
      ),
    );
  }
}

// ───────── Trek cards ─────────
// Small translucent chip used on top of trek images.
Widget glassChip(IconData icon, String text, {Color iconColor = Colors.white}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: const Color(0x4D000000), borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: iconColor),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
    ]),
  );
}

// Image card with the trek over it. Below 200 px wide it shows the short "popular" layout.
class TrekCard extends StatelessWidget {
  final Trek trek;
  final VoidCallback onTap;
  final double width, height;
  const TrekCard({super.key, required this.trek, required this.onTap, this.width = 280, this.height = 200});

  @override
  Widget build(BuildContext context) {
    final compact = width < 200;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(compact ? 14 : 20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              MountainScene(colors: trek.colors),
              const DecoratedBox(
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.center, end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0xCC000000)])),
              ),
              Positioned(
                left: compact ? 10 : 16,
                right: compact ? 10 : 16,
                bottom: compact ? 10 : 14,
                child: compact
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(trek.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                          const SizedBox(height: 4),
                          Row(children: [
                            Text(trek.distance, style: const TextStyle(fontSize: 11, color: AppColors.onDark)),
                            const Spacer(),
                            const Icon(Icons.star_rounded, size: 13, color: AppColors.star),
                            Text(' ${trek.rating}', style: const TextStyle(fontSize: 11, color: AppColors.star, fontWeight: FontWeight.w600)),
                          ]),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(trek.name, maxLines: 2, style: const TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white, height: 1.15)),
                                const SizedBox(height: 8),
                                Wrap(spacing: 6, runSpacing: 6, children: [
                                  glassChip(Icons.route, trek.distance),
                                  glassChip(Icons.schedule, trek.duration),
                                  glassChip(Icons.terrain, trek.difficulty, iconColor: AppColors.star),
                                ]),
                              ],
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrekListTile extends StatelessWidget {
  final Trek trek;
  final VoidCallback onTap;
  final bool saved;
  const TrekListTile({super.key, required this.trek, required this.onTap, this.saved = false});

  @override
  Widget build(BuildContext context) {
    Widget meta(IconData i, String t) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(i, size: 13, color: AppColors.muted), const SizedBox(width: 4), Text(t, style: const TextStyle(fontSize: 12, color: AppColors.muted))]);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            SizedBox(width: 84, height: 84, child: MountainScene(colors: trek.colors, radius: 12)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trek.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.title),
                  const SizedBox(height: 3),
                  Text(trek.region, style: AppText.small),
                  const SizedBox(height: 10),
                  Row(children: [meta(Icons.route, trek.distance), const SizedBox(width: 14), meta(Icons.schedule, trek.duration)]),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(saved ? Icons.favorite : Icons.favorite_border, size: 22, color: saved ? AppColors.accent : AppColors.muted),
                const SizedBox(height: 22),
                Row(children: [const Icon(Icons.star_rounded, size: 16, color: AppColors.star), Text(' ${trek.rating}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ───────── Fake map (UI placeholder; real map comes later with flutter_map) ─────────
class MapPin {
  final double fx, fy;
  final Color color;
  final IconData icon;
  const MapPin(this.fx, this.fy, this.color, this.icon);
}

class RouteGeo {
  static const List<List<double>> _seg = [
    [80, 390, 130, 360, 250, 360, 240, 310],
    [240, 310, 230, 260, 110, 250, 130, 190],
    [130, 190, 150, 130, 270, 140, 260, 80],
    [260, 80, 254, 45, 200, 35, 210, 20],
  ];

  static Path build(Size s, EdgeInsets ins) {
    final sx = (s.width - ins.horizontal) / 390;
    final sy = (s.height - ins.vertical) / 400;
    double px(double x) => ins.left + x * sx;
    double py(double y) => ins.top + y * sy;
    final p = Path()..moveTo(px(80), py(390));
    for (final g in _seg) {
      p.cubicTo(px(g[2]), py(g[3]), px(g[4]), py(g[5]), px(g[6]), py(g[7]));
    }
    return p;
  }

  static Offset at(Size s, EdgeInsets ins, double t) {
    final m = build(s, ins).computeMetrics().first;
    final tan = m.getTangentForOffset(m.length * t.clamp(0.0, 1.0));
    return tan!.position;
  }
}

class _MapPainter extends CustomPainter {
  final bool route;
  final double progress;
  final EdgeInsets insets;
  _MapPainter(this.route, this.progress, this.insets);

  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    // dark "satellite" terrain to match the forest theme
    c.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF2C4A35));
    final forest = Paint()..color = const Color(0xFF223D2B);
    c.drawOval(Rect.fromLTWH(-w * .15, h * .08, w * .75, h * .4), forest);
    c.drawOval(Rect.fromLTWH(w * .5, h * .55, w * .8, h * .5), forest);
    c.drawOval(Rect.fromLTWH(w * .55, -h * .05, w * .6, h * .3), Paint()..color = const Color(0xFF3D5E45));
    final cont = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x667FA88A);
    for (var i = 0; i < 4; i++) {
      c.drawOval(Rect.fromLTWH(w * .55 - i * 28, h * .2 - i * 18, 60.0 + i * 56, 40.0 + i * 36), cont);
    }
    c.save();
    c.translate(0, h * .66);
    c.rotate(-0.17);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-20, 0, w + 40, 12), const Radius.circular(6)), Paint()..color = const Color(0xFF4F86AD));
    c.restore();
    final road = Paint()
      ..color = const Color(0xFFB9A77A)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    c.drawLine(Offset(-20, h * .45), Offset(w + 20, h * .3), road);
    c.drawLine(Offset(w * .25, -10), Offset(w * .32, h + 10), road);

    if (route) {
      final path = RouteGeo.build(s, insets);
      c.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..color = AppColors.dark
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      final metric = path.computeMetrics().first;
      c.drawPath(
        metric.extractPath(0, metric.length * progress),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = AppColors.accent
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      final dot = Paint()..color = const Color(0xFFF5D08A);
      for (double d = metric.length * progress; d < metric.length; d += 12) {
        final t = metric.getTangentForOffset(d);
        if (t != null) c.drawCircle(t.position, 2.5, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => old.route != route || old.progress != progress || old.insets != insets;
}

Widget _pinWidget(double x, double y, Color c, IconData i) {
  return Positioned(
    left: x - 18,
    top: y - 18,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: kShadow),
      child: Icon(i, size: 17, color: Colors.white),
    ),
  );
}

Widget _meWidget(double x, double y) {
  return Positioned(
    left: x - 22,
    top: y - 22,
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.2), shape: BoxShape.circle),
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(color: AppColors.info, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: kShadow),
        ),
      ),
    ),
  );
}

class FakeMap extends StatelessWidget {
  final List<MapPin> pins;
  final bool route;
  final double progress;
  final Offset? me; // fractional position (0..1)
  final EdgeInsets routeInsets;
  const FakeMap({super.key, this.pins = const [], this.route = false, this.progress = 0.38, this.me, this.routeInsets = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, cs) {
      final size = Size(cs.maxWidth, cs.maxHeight);
      final kids = <Widget>[Positioned.fill(child: CustomPaint(painter: _MapPainter(route, progress, routeInsets)))];
      if (route) {
        final a = RouteGeo.at(size, routeInsets, 0);
        final b = RouteGeo.at(size, routeInsets, 1);
        kids.add(_pinWidget(a.dx, a.dy, const Color(0xFF2E9E6B), Icons.flag));
        kids.add(_pinWidget(b.dx, b.dy, AppColors.accent, Icons.terrain));
        if (progress < 1) {
          final u = RouteGeo.at(size, routeInsets, progress);
          kids.add(_meWidget(u.dx, u.dy));
        }
      }
      for (final p in pins) {
        kids.add(_pinWidget(p.fx * size.width, p.fy * size.height, p.color, p.icon));
      }
      if (me != null) kids.add(_meWidget(me!.dx * size.width, me!.dy * size.height));
      return ClipRect(child: Stack(children: kids));
    });
  }
}
