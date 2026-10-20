import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'theme.dart';

const List<BoxShadow> kShadow = [BoxShadow(color: Color(0x1F000000), blurRadius: 12, offset: Offset(0, 3))];
const List<BoxShadow> kShadowUp = [BoxShadow(color: Color(0x1F000000), blurRadius: 20, offset: Offset(0, -4))];

// ───────── Buttons ─────────
enum BtnStyle { primary, outline, danger, white, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final BtnStyle style;
  final double height;
  final IconData? icon;
  const AppButton({super.key, required this.label, this.onTap, this.style = BtnStyle.primary, this.height = 56, this.icon});

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.primary;
    Color fg = Colors.white;
    BorderSide side = BorderSide.none;
    switch (style) {
      case BtnStyle.primary:
        break;
      case BtnStyle.outline:
        bg = Colors.white;
        fg = AppColors.primary;
        side = const BorderSide(color: AppColors.primary, width: 1.5);
        break;
      case BtnStyle.danger:
        bg = AppColors.danger;
        break;
      case BtnStyle.white:
        bg = Colors.white;
        fg = AppColors.dark;
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
          shape: StadiumBorder(side: side),
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
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: selected ? null : Border.all(color: AppColors.border, width: 1.5),
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
  const BackCircle({super.key, this.icon = Icons.arrow_back, this.onTap, this.bg = Colors.white});
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
        final star = Icon(Icons.star_rounded, size: size, color: i < value ? AppColors.accent : const Color(0xFFD5DCD8));
        if (onChanged == null) return star;
        return GestureDetector(onTap: () => onChanged!(i + 1), child: star);
      }),
    );
  }
}

class AppField extends StatelessWidget {
  final String label, hint;
  final bool obscure;
  final int maxLines;
  final TextEditingController? controller;
  const AppField({super.key, required this.label, required this.hint, this.obscure = false, this.maxLines = 1, this.controller});

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder b(Color c) => OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c, width: 1.5));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          maxLines: obscure ? 1 : maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.muted, fontSize: 15),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: b(AppColors.border),
            enabledBorder: b(AppColors.border),
            focusedBorder: b(AppColors.primary),
          ),
        ),
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
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(14)),
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
  @override
  void paint(Canvas c, Size s) {
    void tri(double x1, double y1, double x2, double y2, double x3, double y3, Color col) {
      final p = Path()
        ..moveTo(x1, y1)
        ..lineTo(x2, y2)
        ..lineTo(x3, y3)
        ..close();
      c.drawPath(p, Paint()..color = col);
    }

    final w = s.width, h = s.height;
    tri(-w * .15, h * 1.1, w * .225, h * .3, w * .6, h * 1.1, const Color(0xFF1F5A44));
    tri(w * .3, h * 1.05, w * .725, h * .1, w * 1.15, h * 1.05, AppColors.primary);
    tri(w * .05, h * 1.1, w * .35, h * .55, w * .65, h * 1.1, AppColors.dark);
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
class TrekCard extends StatelessWidget {
  final Trek trek;
  final VoidCallback onTap;
  final double width, height;
  const TrekCard({super.key, required this.trek, required this.onTap, this.width = 280, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              MountainScene(colors: trek.colors),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height * .6,
                child: const DecoratedBox(
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0xBF000000)])),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: Color(0xE6FFFFFF), shape: BoxShape.circle),
                  child: const Icon(Icons.favorite_border, size: 20, color: AppColors.text),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DifficultyBadge(trek.difficulty),
                    const SizedBox(height: 8),
                    Text(trek.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 14, color: Color(0xFFE4EFE8)),
                        Text(' ${trek.region}    ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFE4EFE8))),
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
                        Text(' ${trek.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFE4EFE8))),
                      ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            SizedBox(width: 76, height: 76, child: MountainScene(colors: trek.colors, radius: 14)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trek.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.title),
                  const SizedBox(height: 4),
                  Text(trek.region, style: AppText.small),
                  const SizedBox(height: 6),
                  Text('${trek.distance}  ·  ${trek.duration}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                saved ? const Icon(Icons.favorite, size: 20, color: AppColors.danger) : DifficultyBadge(trek.difficulty),
                const SizedBox(height: 10),
                Row(children: [const Icon(Icons.star_rounded, size: 16, color: AppColors.accent), Text(' ${trek.rating}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))]),
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
    c.drawRect(Offset.zero & s, Paint()..color = const Color(0xFFE9EFE6));
    final forest = Paint()..color = const Color(0xFFD3E8D5);
    c.drawOval(Rect.fromLTWH(-w * .15, h * .08, w * .75, h * .4), forest);
    c.drawOval(Rect.fromLTWH(w * .5, h * .55, w * .8, h * .5), forest);
    c.drawOval(Rect.fromLTWH(w * .55, -h * .05, w * .6, h * .3), Paint()..color = const Color(0xFFC2DDC8));
    final cont = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xB39FC3AA);
    for (var i = 0; i < 4; i++) {
      c.drawOval(Rect.fromLTWH(w * .55 - i * 28, h * .2 - i * 18, 60.0 + i * 56, 40.0 + i * 36), cont);
    }
    c.save();
    c.translate(0, h * .66);
    c.rotate(-0.17);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-20, 0, w + 40, 16), const Radius.circular(8)), Paint()..color = const Color(0xFFBFDDEF));
    c.restore();
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
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
          ..color = Colors.white
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      final metric = path.computeMetrics().first;
      c.drawPath(
        metric.extractPath(0, metric.length * progress),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = AppColors.primary
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      final dot = Paint()..color = const Color(0xFF7DAE93);
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
        kids.add(_pinWidget(a.dx, a.dy, AppColors.primary, Icons.flag));
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
