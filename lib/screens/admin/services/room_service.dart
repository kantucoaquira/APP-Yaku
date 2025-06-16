import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class RoomService {
  static const String baseUrl = 'http://192.168.43.72:8080/api/rooms';

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

  Future<List<dynamic>> getRooms() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar habitaciones');
    }
  }
  Future<List<dynamic>> getMyRooms() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/my-rooms'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar habitaciones del administrador');
    }
  }

  Future<List<dynamic>> getAvailableRoomsByHotel(int hotelId) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/disponibles/hotel/$hotelId'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar habitaciones disponibles del hotel');
    }
  }
  Future<List<dynamic>> getAvailableRooms() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/disponibles'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar habitaciones disponibles');
    }
  }


  Future<Map<String, dynamic>> getRoomById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/$id'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar habitación');
    }
  }


  Future<int> createRoom(Map<String, dynamic> roomData) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(roomData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['id']; // <-- Asegúrate que el backend devuelve el ID en la respuesta
    } else {
      throw Exception('Error al crear habitación');
    }
  }


  Future<void> updateRoom(int id, Map<String, dynamic> roomData) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
      body: jsonEncode(roomData),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar habitación');
    }
  }

  Future<void> deleteRoom(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: headers);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar habitación');
    }
  }

  Future<void> uploadImage(int roomId, XFile imageFile) async {
    final url = Uri.parse('$baseUrl/$roomId/uploadImage');
    final request = http.MultipartRequest('POST', url);

    final headers = await _getHeaders(isMultipart: true);
    request.headers.addAll(headers);

    final mimeType = lookupMimeType(imageFile.path) ?? 'application/octet-stream';
    final mimeSplit = mimeType.split('/');

    final multipartFile = await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      contentType: MediaType(mimeSplit[0], mimeSplit[1]),
    );

    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      final errorMessage = response.body.isNotEmpty ? response.body : 'Error al subir imagen';
      throw Exception('Error al subir imagen: $errorMessage (Código ${response.statusCode})');
    }
  }
}