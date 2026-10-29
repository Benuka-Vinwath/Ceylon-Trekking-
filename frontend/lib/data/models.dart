import 'package:flutter/material.dart';

// pg sends NUMERIC columns as strings ("7.0"); these read either form.
double toDouble(dynamic v) => v == null ? 0 : double.parse(v.toString());
String fmtNum(dynamic v) => v.toString().replaceAll(RegExp(r'\.0+$'), '');

const _palettes = [
  [Color(0xFF9CC7AE), Color(0xFF2E7D5B)],
  [Color(0xFFF4CB8B), Color(0xFFC9792B)],
  [Color(0xFFA9C9E6), Color(0xFF2F6F9F)],
  [Color(0xFFB5D9C4), Color(0xFF3E8E6A)],
];

class Trek {
  final int id;
  final String name, region, difficulty, distance, duration, elevation, about, safety;
  final double km, hours, rating;
  final int reviews;
  final List<Color> colors;

  Trek.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        name = j['name'],
        region = j['region'],
        difficulty = j['difficulty'],
        km = toDouble(j['distance_km']),
        hours = toDouble(j['duration_hrs']),
        distance = '${fmtNum(j['distance_km'])} km',
        duration = '${fmtNum(j['duration_hrs'])} h',
        elevation = '${j['elevation_m']} m',
        about = j['description'] ?? '',
        safety = 'Check the weather, carry water and tell someone your plan.', // backend has no safety field yet
        rating = toDouble(j['avg_rating']),
        reviews = j['review_count'] ?? 0,
        colors = _palettes[(j['id'] as int) % _palettes.length];
}

class ParkingLot {
  final int id;
  final String name, distance, capacity, fee, status, address, hours;
  final List<String> tags, vehicles, facilities;

  String get info => '$capacity · $fee';

  ParkingLot.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        name = j['name'],
        // per-trek list sends metres from the trailhead; the all-parking list sends the trek name instead
        distance = j['distance_m'] != null ? '${j['distance_m']} m from trailhead' : 'Near ${j['trek_name']}',
        capacity = '${j['spaces']} spaces',
        fee = toDouble(j['fee_per_day']) == 0 ? 'Free' : 'Rs ${fmtNum(j['fee_per_day'])}/day',
        status = j['status'],
        address = j['address'] ?? '',
        hours = j['hours'] ?? '',
        tags = [toDouble(j['fee_per_day']) == 0 ? 'Free' : 'Paid', if (j['is_covered'] == true) 'Covered'],
        vehicles = List<String>.from(j['vehicles'] ?? []),
        facilities = List<String>.from(j['facilities'] ?? []);
}

String _hhmm(dynamic t) => t.toString().substring(0, 5); // "07:00:00" -> "07:00"

class GearShop {
  final int id;
  final String name, area, items, rating, status, address, hours, phone;

  GearShop.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        name = j['name'],
        address = j['address'] ?? '',
        area = j['distance_km'] != null ? '${j['address']} · ${j['distance_km']} km' : (j['address'] ?? ''),
        items = List<String>.from(j['equipment_names'] ?? []).join(' · '),
        rating = j['rating'] == null ? '–' : fmtNum(j['rating']),
        status = j['is_open'] == true ? 'Open' : 'Closed',
        hours = 'Open ${_hhmm(j['opens'])} – ${_hhmm(j['closes'])}',
        phone = j['phone'] ?? '';
}

class Equip {
  final IconData icon;
  final String name, price;
  final bool inStock;

  Equip.fromJson(Map<String, dynamic> j)
      : name = j['name'],
        price = 'Rs ${fmtNum(j['price_per_day'])} / day',
        inStock = j['in_stock'] == true,
        icon = _equipIcon(j['name']);
}

IconData _equipIcon(String name) {
  final n = name.toLowerCase();
  if (n.contains('tent')) return Icons.cabin;
  if (n.contains('sleeping')) return Icons.bed;
  if (n.contains('lamp')) return Icons.flashlight_on;
  if (n.contains('pole') || n.contains('boot')) return Icons.hiking;
  if (n.contains('stove')) return Icons.local_fire_department;
  if (n.contains('rain')) return Icons.umbrella;
  return Icons.backpack;
}

String timeAgo(String iso) {
  final d = DateTime.now().difference(DateTime.parse(iso));
  if (d.inDays >= 30) return '${d.inDays ~/ 30} month${d.inDays >= 60 ? 's' : ''} ago';
  if (d.inDays >= 7) return '${d.inDays ~/ 7} week${d.inDays >= 14 ? 's' : ''} ago';
  if (d.inDays >= 1) return '${d.inDays} day${d.inDays >= 2 ? 's' : ''} ago';
  if (d.inHours >= 1) return '${d.inHours} h ago';
  return 'Just now';
}

class ReviewItem {
  final int id;
  final String name, when, text;
  final int stars;

  ReviewItem.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        name = j['full_name'],
        when = timeAgo(j['created_at']),
        stars = j['rating'],
        text = j['comment'] ?? '';
}
