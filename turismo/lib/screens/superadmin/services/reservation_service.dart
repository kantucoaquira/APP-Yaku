import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationService {
  final String baseUrl = 'http://192.168.1.12:8080/api/reservations';

  // Obtiene el token JWT guardado en SharedPreferences
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> getReservations() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar reservas');
    }
  }

  Future<Map<String, dynamic>> getReservationById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/$id'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar reserva');
    }
  }

  Future<Map<String, dynamic>> createReservation(Map<String, dynamic> data) async {
    final headers = await _getHeaders();

    // Ajusta el JSON para enviar IDs planos según tu base
    final Map<String, dynamic> formattedData = {
      "checkIn": data["startDate"],
      "checkOut": data["endDate"],
      "status": data["status"] ?? "PENDIENTE",
      "client": data["clientId"],
      "hotel": data["hotelId"],
      "restaurant": data["restaurantId"], // opcional
      "room": data["roomId"], // opcional
    }..removeWhere((key, value) => value == null);

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(formattedData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error crear reserva: ${response.statusCode} - ${response.body}');
      throw Exception('Error al crear reserva');
    }
  }

  Future<Map<String, dynamic>> updateReservation(int id, Map<String, dynamic> data) async {
    final headers = await _getHeaders();

    final Map<String, dynamic> formattedData = {
      "checkIn": data["startDate"],
      "checkOut": data["endDate"],
      "status": data["status"] ?? "PENDIENTE",
      "client": data["clientId"],
      "hotel": data["hotelId"],
      "restaurant": data["restaurantId"], // opcional
      "room": data["roomId"], // opcional
    }..removeWhere((key, value) => value == null);

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
      body: jsonEncode(formattedData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error actualizar reserva: ${response.statusCode} - ${response.body}');
      throw Exception('Error al actualizar reserva');
    }
  }

  Future<void> deleteReservation(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: headers);
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar reserva');
    }
  }

  Future<void> uploadImage(int reservationId, XFile imageFile) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/$reservationId/uploadImage');
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Error al subir imagen');
    }
  }
}
