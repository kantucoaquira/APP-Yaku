  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'package:shared_preferences/shared_preferences.dart';

  class ReservationService {
    final String baseUrl = 'http://192.168.43.72:8080/api/reservations';

    Future<String?> _getToken() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('jwt_token');
    }

    Future<Map<String, String>> _getHeaders() async {
      final token = await _getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      return headers;
    }

    /// Consulta si hay una reserva activa para un cliente y habitación específicos
    Future<bool> hasActiveReservation({required int clientId, required int roomId}) async {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/active?clientId=$clientId&roomId=$roomId');

      try {
        final response = await http.get(url, headers: headers);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['active'] == true;
        } else {
          print('Error al consultar reserva activa: ${response.statusCode}');
          return false;
        }
      } catch (e) {
        print('Excepción en hasActiveReservation: $e');
        return false;
      }
    }

    /// Obtiene las reservas del usuario autenticado
    Future<List<dynamic>> getMyReservations() async {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$baseUrl/my'), headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener tus reservas: ${response.statusCode}');
      }
    }

    /// Crea una nueva reserva con los datos proporcionados
    Future<Map<String, dynamic>?> createReservation(Map<String, dynamic> data) async {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print("Error en createReservation: ${response.body}");
        return null;
      }
    }

    /// Cancela una reserva dado su ID
    Future<bool> cancelReservation(int id) async {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/$id/cancel'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Error cancelando reserva: ${response.body}");
        return false;
      }
    }

  }
