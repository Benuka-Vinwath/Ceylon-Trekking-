import 'package:flutter/material.dart';

class Trek {
  final String name, region, difficulty, distance, duration, elevation, about, safety;
  final double rating;
  final int reviews;
  final List<Color> colors;
  const Trek({
    required this.name,
    required this.region,
    required this.difficulty,
    required this.distance,
    required this.duration,
    required this.elevation,
    required this.about,
    required this.safety,
    required this.rating,
    required this.reviews,
    required this.colors,
  });
}

const List<Trek> treks = [
  Trek(
    name: "Adam's Peak",
    region: 'Ratnapura',
    difficulty: 'Hard',
    distance: '11 km',
    duration: '5–6 h',
    elevation: '2,243 m',
    about: 'A sacred pilgrimage peak with over 5,000 steps to the summit. Start around 2 AM to catch the sunrise above the clouds.',
    safety: 'Carry water, a headlamp and a warm layer. Steps are slippery in rain.',
    rating: 4.7,
    reviews: 312,
    colors: [Color(0xFF9CC7AE), Color(0xFF2E7D5B)],
  ),
  Trek(
    name: 'Ella Rock',
    region: 'Ella · Uva',
    difficulty: 'Moderate',
    distance: '9 km',
    duration: '4 h',
    elevation: '1,041 m',
    about: 'A rewarding hike through tea estates and forest with wide views over the Ella gap. Parts of the trail follow the railway line.',
    safety: 'Watch for trains on the railway section and avoid hiking after heavy rain.',
    rating: 4.6,
    reviews: 198,
    colors: [Color(0xFFF4CB8B), Color(0xFFC9792B)],
  ),
  Trek(
    name: 'Pidurangala Rock',
    region: 'Sigiriya',
    difficulty: 'Easy',
    distance: '2 km',
    duration: '1 h',
    elevation: '200 m',
    about: 'A short climb with a famous view of Sigiriya Rock. Best at sunrise or sunset.',
    safety: 'The final section is a rock scramble. Wear shoes with good grip.',
    rating: 4.5,
    reviews: 145,
    colors: [Color(0xFFA9C9E6), Color(0xFF2F6F9F)],
  ),
  Trek(
    name: "World's End",
    region: 'Horton Plains',
    difficulty: 'Moderate',
    distance: '9.5 km',
    duration: '3.5 h',
    elevation: '2,100 m',
    about: 'A loop trail across misty grasslands to a dramatic 870 m cliff edge. Go early, before the clouds roll in.',
    safety: 'Stay behind the markers near the cliff and carry a rain jacket.',
    rating: 4.8,
    reviews: 276,
    colors: [Color(0xFFB5D9C4), Color(0xFF3E8E6A)],
  ),
];

class ParkingLot {
  final String name, distance, info, status, address;
  final List<String> tags;
  const ParkingLot(this.name, this.distance, this.info, this.status, this.tags, this.address);
}

const List<ParkingLot> parkingLots = [
  ParkingLot('Dalhousie Car Park', '300 m from trailhead', '120 spaces · Rs 300/day', 'Open', ['Paid', 'Covered'], 'Nallathanniya Rd, Dalhousie'),
  ParkingLot('Nallathanniya Parking', '150 m from trailhead', '60 spaces · Free', 'Limited', ['Free'], 'Nallathanniya, Maskeliya'),
  ParkingLot('Seetha Gangula Lot', '1.1 km from trailhead', '35 spaces · Rs 200/day', 'Open', ['Paid'], 'Seetha Gangula, Dalhousie'),
];

class GearShop {
  final String name, area, items, rating, status, address, hours;
  const GearShop(this.name, this.area, this.items, this.rating, this.status, this.address, this.hours);
}

const List<GearShop> gearShops = [
  GearShop('Trail Gear Hatton', 'Hatton · 2.1 km', 'Tents · Sleeping bags · Headlamps', '4.6', 'Open', '12 Dalhousie Rd, Hatton', 'Open 7 AM – 7 PM'),
  GearShop('Peak Outfitters', 'Nuwara Eliya · 4.8 km', 'Backpacks · Poles · Rain gear', '4.4', 'Open', '45 Lake Rd, Nuwara Eliya', 'Open 8 AM – 6 PM'),
  GearShop('Ella Camp Rentals', 'Ella · 0.9 km', 'Tents · Stoves · Hiking boots', '4.7', 'Closed', '3 Main St, Ella', 'Opens 8 AM'),
];

class Equip {
  final IconData icon;
  final String name, price;
  const Equip(this.icon, this.name, this.price);
}

const List<Equip> equipment = [
  Equip(Icons.cabin, 'Tent (2 person)', 'Rs 1,500 / day'),
  Equip(Icons.bed, 'Sleeping bag', 'Rs 600 / day'),
  Equip(Icons.flashlight_on, 'Headlamp', 'Rs 250 / day'),
  Equip(Icons.hiking, 'Trekking poles', 'Rs 300 / day'),
  Equip(Icons.backpack, 'Backpack 50 L', 'Rs 800 / day'),
];

class ReviewItem {
  final String name, when, text;
  final int stars;
  const ReviewItem(this.name, this.when, this.stars, this.text);
}

const List<ReviewItem> reviewItems = [
  ReviewItem('Nimali P.', '2 weeks ago', 5, 'Unforgettable sunrise! Start by 2 AM and bring a torch. The steps are well lit.'),
  ReviewItem('Ravindu S.', '1 month ago', 4, 'Tough but worth it. Very crowded on poya days, so go on a weekday.'),
  ReviewItem('Chris M.', '2 months ago', 5, 'Best hike in Sri Lanka. Tea shops along the way are great.'),
];
