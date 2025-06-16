import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ClientService {
  static const String baseUrl = 'http://192.168.43.72:8080/api/clients';

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

  Future<Map<String, dynamic>> getClientByEmail() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener cliente: ${response.statusCode}');
    }
  }

  Future<bool> registerClient(Map<String, dynamic> clientData) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(clientData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al registrar: ${response.statusCode}');
    }
  }

  Future<bool> updateClient(Map<String, dynamic> clientData) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(clientData),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al actualizar: ${response.statusCode}');
    }
  }

  Future<String?> uploadClientImage(File imageFile) async {
    final url = Uri.parse('$baseUrl/uploadImage');
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

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['imageUrl'];
    } else {
      final errorMessage = response.body.isNotEmpty ? response.body : 'Error al subir imagen';
      throw Exception('Error al subir imagen: $errorMessage (Código ${response.statusCode})');
    }
  }
}