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
