import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuService {
  static const String apiUrl = 'http://192.168.43.72:8080/api/menus';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }
  Future<List<dynamic>> getMyMenus() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiUrl?my=true'), headers: headers);
    print('Status code getMyMenus: ${response.statusCode}');
    print('Response body getMyMenus: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData is List) {
        return jsonData;
      } else {
        throw Exception('Formato inesperado de respuesta');
      }
    } else {
      throw Exception('Error al obtener mis menús: ${response.statusCode}');
    }
  }


  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await _getToken();
    print('Token JWT: $token'); // <-- Aquí
    final headers = <String, String>{};
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }


  Future<List<dynamic>> getMenus() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(apiUrl), headers: headers);
    print('Status code getMenus: ${response.statusCode}');
    print('Response body getMenus: ${response.body}');
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData is List) {
        return jsonData;
      } else if (jsonData is Map && jsonData.containsKey('menus')) {
        return jsonData['menus'];
      } else {
        throw Exception('Formato inesperado de respuesta');
      }
    } else {
      throw Exception('Error al obtener menús: ${response.statusCode}');
    }
  }


  Future<Map<String, dynamic>> getMenuById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiUrl/$id'), headers: headers);

    print('getMenuById status: ${response.statusCode}');
    print('getMenuById body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> menu = jsonDecode(response.body);

      // Aseguramos que la clave imageUrl existe para la imagen inicial
      if (!menu.containsKey('imageUrl')) {
        menu['imageUrl'] = null; // O '' si prefieres
      }

      return menu;
    } else {
      throw Exception('Error al obtener el menú: ${response.statusCode} ${response.body}');
    }
  }


  Future<Map<String, dynamic>> createMenu(Map<String, dynamic> menuData) async {
    final headers = await _getHeaders();

    // Añadir el Content-Type al header
    final updatedHeaders = {
      ...headers,
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: updatedHeaders,
      body: jsonEncode(menuData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      // Lanzar excepción con más detalle para depurar
      throw Exception('Error al crear el menú: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateMenu(int id, Map<String, dynamic> menuData) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$apiUrl/$id'),
      headers: headers,
      body: jsonEncode(menuData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error al actualizar menú: ${response.statusCode} - ${response.body}');
      throw Exception('Error al actualizar el menú: ${response.statusCode}');
    }
  }


  Future<void> deleteMenu(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$apiUrl/$id'), headers: headers);
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar el menú');
    }
  }

  Future<void> uploadImage(int menuId, XFile imageFile) async {
    final url = Uri.parse('$apiUrl/$menuId/uploadImage');
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
      throw Exception('Error al subir imagen del menú');
    }
  }
}
