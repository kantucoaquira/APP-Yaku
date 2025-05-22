import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HotelService {
  static const String baseUrl = 'http://192.168.43.81:8080/api/hotels';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }


  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<void> uploadImage(int hotelId, XFile imageFile) async {
    final url = Uri.parse('http://192.168.1.8:8080/api/hotels/$hotelId/uploadImage');
    final request = http.MultipartRequest('POST', url);
    final headers = await _getHeaders();
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Error al subir imagen');
    }
  }

  // Obtener hotel por ID
  Future<Map<String, dynamic>> getHotelById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/$id'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar hotel');
    }
  }

  // Crear un nuevo hotel
  Future<void> createHotel(Map<String, dynamic> hotelData) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(hotelData),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al crear hotel');
    }
  }

  // Actualizar un hotel existente
  Future<void> updateHotel(int id, Map<String, dynamic> hotelData) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
      body: jsonEncode(hotelData),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar hotel');
    }
  }

  // Obtener todos los hoteles
  Future<List<dynamic>> getHotels() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Error al cargar hoteles');
    }
  }

  // Eliminar un hotel
  Future<void> deleteHotel(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar hotel');
    }
  }
}