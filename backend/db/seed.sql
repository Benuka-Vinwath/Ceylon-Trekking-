INSERT INTO treks (name, region, difficulty, distance_km, duration_hrs, elevation_m, description, lat, lng) VALUES
('Adam''s Peak',      'Sabaragamuwa', 'Hard',     7.0, 5.0, 2243, 'Sacred pilgrimage climb, best at sunrise.',        6.8096, 80.4994),
('Ella Rock',         'Uva',          'Moderate', 9.0, 4.0, 1041, 'Railway-track approach with valley views.',          6.8667, 81.0466),
('Pidurangala Rock',  'Central',      'Easy',     2.0, 1.5,  424, 'Short climb facing Sigiriya.',                      7.9647, 80.7580),
('World''s End',      'Central',      'Easy',     9.5, 3.5, 2100, 'Horton Plains loop ending at a 870 m cliff.',       6.8029, 80.8014);

-- Sample places. Coordinates are approximate; replace with surveyed ones before launch.
INSERT INTO parking_locations (trek_id, name, address, lat, lng, spaces, fee_per_day, is_covered, hours, vehicles, facilities, status) VALUES
(1, 'Dalhousie Car Park',      'Nallathanniya Rd, Dalhousie', 6.8120, 80.5010, 120, 300, false, 'Open 24 h', '{Car,Van,Bike}', '{Toilets,Security,"Tea shop",Lighting}', 'Open'),
(1, 'Nallathanniya Parking',   'Nallathanniya Rd, Dalhousie', 6.8105, 80.5002,  60,   0, false, 'Open 24 h', '{Car,Bike}',     '{Toilets}',                            'Limited'),
(1, 'Seetha Gangula Lot',      'Seetha Gangula, Dalhousie',   6.8190, 80.5060,  35, 200, true,  '5 AM - 10 PM', '{Car,Van}',    '{Security,Lighting}',                  'Open'),
(1, 'Maskeliya Road Lot',      'Maskeliya Rd, Dalhousie',     6.8210, 80.5120,  80, 250, false, 'Open 24 h', '{Car,Van,Bike}', '{Toilets,"Tea shop"}',                 'Open'),
(2, 'Ella Station Parking',    'Station Rd, Ella',            6.8660, 81.0460,  40, 150, false, 'Open 24 h', '{Car,Bike}',     '{Security}',                           'Open'),
(3, 'Pidurangala Temple Lot',  'Pidurangala, Sigiriya',       7.9660, 80.7570,  50,   0, false, '6 AM - 6 PM',  '{Car,Van,Bike}', '{Toilets}',                          'Open'),
(4, 'Horton Plains Visitor Centre', 'Horton Plains NP',       6.8020, 80.8010, 100, 500, true,  '6 AM - 4 PM',  '{Car,Van}',    '{Toilets,Security,"Tea shop"}',        'Open');

INSERT INTO shops (name, address, phone, lat, lng, opens, closes, rating) VALUES
('Trail Gear Hatton',  '12 Dalhousie Rd, Hatton',   '0770000001', 6.8917, 80.5957, '07:00', '19:00', 4.6),
('Peak Outfitters',    'Nuwara Eliya',              '0770000002', 6.9497, 80.7891, '08:00', '18:00', 4.4),
('Ella Camp Rentals',  'Main St, Ella',             '0770000003', 6.8667, 81.0466, '08:00', '17:00', 4.7);

INSERT INTO equipment (shop_id, name, price_per_day, stock) VALUES
(1, 'Tent (2 person)', 1500, 6), (1, 'Sleeping bag', 600, 10), (1, 'Headlamp', 250, 12), (1, 'Trekking poles', 300, 8), (1, 'Backpack 50 L', 800, 5),
(2, 'Backpack 50 L', 800, 4), (2, 'Trekking poles', 300, 6), (2, 'Rain jacket', 400, 7),
(3, 'Tent (2 person)', 1500, 3), (3, 'Camping stove', 500, 4), (3, 'Hiking boots', 700, 0);

-- Sample route points (approximate). Only Adam's Peak and Ella Rock have routes so far.
INSERT INTO trek_waypoints (trek_id, position, name, lat, lng, elevation_m) VALUES
(1, 1, 'Dalhousie Trailhead', 6.8120, 80.5010, 1150),
(1, 2, 'Seetha Gangula',      6.8112, 80.5004, 1320),
(1, 3, 'Indikatupana',        6.8104, 80.4999, 1710),
(1, 4, 'Summit',              6.8096, 80.4994, 2243),
(2, 1, 'Ella Station',           6.8660, 81.0460, 1000),
(2, 2, 'Railway track junction', 6.8650, 81.0480, 1020),
(2, 3, 'Ella Rock summit',       6.8667, 81.0466, 1041);

-- Sample map packs: an area of about 9 km around each trek.
INSERT INTO offline_maps (trek_id, size_mb, south, west, north, east, updated_at)
SELECT t.id, v.size_mb, t.lat - 0.04, t.lng - 0.04, t.lat + 0.04, t.lng + 0.04, now() - v.age
FROM treks t JOIN (VALUES (1, 42.0, interval '3 days'), (2, 35.0, interval '7 days'), (3, 21.0, interval '1 day'), (4, 38.0, interval '14 days')) AS v(trek_id, size_mb, age) ON v.trek_id = t.id;
