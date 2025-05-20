import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReservationsManagementScreen extends StatefulWidget {
  @override
  _ReservationsManagementScreenState createState() => _ReservationsManagementScreenState();
}

class _ReservationsManagementScreenState extends State<ReservationsManagementScreen> {
  List<dynamic> reservations = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchReservations() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse('http://192.168.1.8:8080/api/reservations'));
      if (response.statusCode == 200) {
        setState(() {
          reservations = jsonDecode(response.body);
        });
      } else {
        setState(() {
          errorMessage = 'No se pudieron cargar las reservas';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error de conexión';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateReservationStatus(String id, String newStatus) async {
    final url = Uri.parse('http://192.168.1.8:8080/api/reservations/$id/status');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': newStatus}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Estado actualizado')));
      fetchReservations();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar')));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Reservas'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchReservations,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
          : reservations.isEmpty
          ? Center(child: Text('No hay reservas'))
          : ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final res = reservations[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text('Reserva: ${res['id']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Usuario: ${res['user']['username']}'),
                  Text('Fecha: ${res['date']}'),
                  Text('Estado: ${res['status']}'),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) => updateReservationStatus(res['id'], value),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'CONFIRMED', child: Text('Confirmar')),
                  PopupMenuItem(value: 'PENDING', child: Text('Pendiente')),
                  PopupMenuItem(value: 'CANCELLED', child: Text('Cancelar')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
