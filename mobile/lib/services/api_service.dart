import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device.dart';
import '../models/reading.dart';
import '../models/alert.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:5113/api/v1';
  static const String _tokenKey = 'jwt_token';

  // ── Auth ────────────────────────────────────────────────────────────────

  Future<bool> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode == 200) {
      final token = jsonDecode(res.body)['token'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    return res.statusCode == 200;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  void _checkStatus(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }

  // ── Devices ─────────────────────────────────────────────────────────────

  Future<List<Device>> getDevices() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/devices'),
      headers: await _authHeaders(),
    );
    _checkStatus(res);
    return (jsonDecode(res.body) as List)
        .map((j) => Device.fromJson(j))
        .toList();
  }

  Future<Device> createDevice(String name, String location, String type) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/devices'),
      headers: await _authHeaders(),
      body: jsonEncode({'name': name, 'location': location, 'type': type}),
    );
    _checkStatus(res);
    return Device.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteDevice(int id) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/devices/$id'),
      headers: await _authHeaders(),
    );
    _checkStatus(res);
  }

  // ── Readings ─────────────────────────────────────────────────────────────

  Future<List<Reading>> getReadingsForDevice(int deviceId) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/readings/device/$deviceId'),
      headers: await _authHeaders(),
    );
    _checkStatus(res);
    return (jsonDecode(res.body) as List)
        .map((j) => Reading.fromJson(j))
        .toList();
  }

  Future<Reading> createReading(int deviceId, double value, String unit) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/readings'),
      headers: await _authHeaders(),
      body: jsonEncode({'deviceId': deviceId, 'value': value, 'unit': unit}),
    );
    _checkStatus(res);
    return Reading.fromJson(jsonDecode(res.body));
  }

  // ── Alerts ───────────────────────────────────────────────────────────────

  Future<List<Alert>> getAlerts() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/alerts'),
      headers: await _authHeaders(),
    );
    _checkStatus(res);
    return (jsonDecode(res.body) as List)
        .map((j) => Alert.fromJson(j))
        .toList();
  }

  Future<List<Alert>> getAlertsForDevice(int deviceId) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/alerts/device/$deviceId'),
      headers: await _authHeaders(),
    );
    _checkStatus(res);
    return (jsonDecode(res.body) as List)
        .map((j) => Alert.fromJson(j))
        .toList();
  }

  Future<void> deleteAlert(int id) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/alerts/$id'),
      headers: await _authHeaders(),
    );
    _checkStatus(res);
  }
}
