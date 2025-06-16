import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HabitacionService {
  static const String baseUrl = 'http://192.168.43.72:8080/api/habitaciones';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<dynamic>> getHabitaciones() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar habitaciones');
    }
  }

  Future<Map<String, dynamic>> getHabitacionById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/$id'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar habitación');
    }
  }

  Future<void> createHabitacion(Map<String, dynamic> habitacionData) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(habitacionData),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al crear habitación');
    }
  }

  Future<void> updateHabitacion(int id, Map<String, dynamic> habitacionData) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
      body: jsonEncode(habitacionData),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar habitación');
    }
  }

  Future<void> deleteHabitacion(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: headers);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar habitación');
    }
  }
}
