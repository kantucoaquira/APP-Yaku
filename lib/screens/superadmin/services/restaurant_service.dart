import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantService {
  static const String baseUrl = 'http://192.168.75.20:8080/api/restaurants';
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await _getToken();
    final headers = <String, String>{};
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<dynamic>> getRestaurants() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar restaurantes');
    }
  }

  Future<Map<String, dynamic>> createRestaurant(Map<String, dynamic> restaurantData) async {
    final headers = await _getHeaders();
    final response = await http.post(Uri.parse(baseUrl), headers: headers, body: jsonEncode(restaurantData));
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear restaurante');
    }
  }

  Future<Map<String, dynamic>> updateRestaurant(int id, Map<String, dynamic> restaurantData) async {
    final headers = await _getHeaders();
    final response = await http.put(Uri.parse('$baseUrl/$id'), headers: headers, body: jsonEncode(restaurantData));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar restaurante');
    }
  }

  Future<void> deleteRestaurant(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: headers);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar restaurante');
    }
  }

  Future<void> uploadImage(int restaurantId, XFile imageFile) async {
    final url = Uri.parse('$baseUrl/$restaurantId/uploadImage');
    final request = http.MultipartRequest('POST', url);

    final headers = await _getHeaders(isMultipart: true);
    request.headers.addAll(headers);

    // Detectar el tipo MIME
    final mimeType = lookupMimeType(imageFile.path) ?? 'application/octet-stream';
    final mimeTypeSplit = mimeType.split('/');

    final multipartFile = await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      contentType: MediaType(mimeTypeSplit[0], mimeTypeSplit[1]),
    );

    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return;
    } else {
      final errorMessage = response.body.isNotEmpty ? response.body : 'Error al subir la imagen';
      throw Exception('Error al subir la imagen: $errorMessage (Código ${response.statusCode})');
    }
  }

}