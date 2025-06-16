import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaqueteService {
  static const String apiUrl = 'http://192.168.43.72:8080/api/paquetes';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<dynamic>> getPaquetes() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener paquetes');
    }
  }

  Future<Map<String, dynamic>> createPaquete(Map<String, dynamic> paqueteData) async {
    final headers = await _getHeaders();

    // No enviar los precios, el backend los calcula
    paqueteData.remove("precioOriginal");
    paqueteData.remove("precioConDescuento");

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(paqueteData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear paquete: ${response.statusCode} ${response.body}');
    }
  }
  Future<void> deletePaquete(int id) async {
    final headers = await _getHeaders();
    final url = '$apiUrl/$id';

    final response = await http.delete(Uri.parse(url), headers: headers);

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar paquete: ${response.statusCode}');
    }
  }

}
