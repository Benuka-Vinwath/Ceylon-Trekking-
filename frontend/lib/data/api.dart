import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

// Android emulator reaches the PC's localhost at 10.0.2.2. Override with: flutter run --dart-define=API_URL=http://192.168.x.x:3000/api
const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:3000/api');

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class Api {
  // shortcut: token lives in memory, so the user logs in again after an app restart; persist it (shared_preferences) when that matters.
  static String? token;
  static Map<String, dynamic>? user;

  static bool get isAdmin => user?['role'] == 'admin';

  static Future<dynamic> get(String path) => _send('GET', path);
  static Future<dynamic> post(String path, [Map<String, dynamic>? body]) => _send('POST', path, body);
  static Future<dynamic> put(String path) => _send('PUT', path);
  static Future<dynamic> delete(String path) => _send('DELETE', path);

  static Future<dynamic> _send(String method, String path, [Map<String, dynamic>? body]) async {
    final headers = {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
    final http.Response res;
    try {
      final req = http.Request(method, Uri.parse('$apiUrl$path'))..headers.addAll(headers);
      if (body != null) req.body = jsonEncode(body);
      res = await http.Response.fromStream(await req.send().timeout(const Duration(seconds: 15)));
    } catch (_) {
      throw ApiException('Cannot reach the server. Is the backend running?');
    }
    final data = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 400) throw ApiException(data is Map && data['error'] != null ? data['error'] : 'Request failed (${res.statusCode})');
    return data;
  }

  static Future<void> _auth(String path, Map<String, dynamic> body) async {
    final data = await post(path, body);
    token = data['token'];
    user = data['user'];
  }

  static Future<void> login(String email, String password) => _auth('/auth/login', {'email': email, 'password': password});

  static Future<void> signup(String fullName, String email, String password, String role) =>
      _auth('/auth/signup', {'full_name': fullName, 'email': email, 'password': password, 'role': role});

  static void logout() {
    token = null;
    user = null;
  }

  static Future<List<T>> _list<T>(String path, T Function(Map<String, dynamic>) from) async =>
      (await get(path) as List).map((j) => from(j as Map<String, dynamic>)).toList();

  static Future<List<Trek>> treks() => _list('/treks', Trek.fromJson);
  static Future<List<Trek>> saved() => _list('/saved', Trek.fromJson);
  static Future<List<ReviewItem>> reviews(int trekId) => _list('/treks/$trekId/reviews', ReviewItem.fromJson);
  static Future<List<ParkingLot>> parking([Trek? trek]) => _list(trek == null ? '/parking' : '/treks/${trek.id}/parking', ParkingLot.fromJson);
  static Future<List<GearShop>> shops() => _list('/shops', GearShop.fromJson);
  static Future<List<Equip>> equipment(int shopId) async =>
      ((await get('/shops/$shopId'))['equipment'] as List).map((j) => Equip.fromJson(j)).toList();
}
