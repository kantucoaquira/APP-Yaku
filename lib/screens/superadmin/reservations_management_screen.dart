import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turismoapp/screens/superadmin/services/reservation_service.dart';
import 'ReservationEditScreen.dart';// Crea este servicio para manejar las API

class ReservationsScreen extends StatefulWidget {
  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<dynamic> reservations = [];
  bool isLoading = false;

  final picker = ImagePicker();
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  Future<void> fetchReservations() async {
    setState(() => isLoading = true);
    try {
      final data = await ReservationService().getReservations();
      setState(() {
        reservations = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar reservas')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteReservation(int id) async {
    try {
      await ReservationService().deleteReservation(id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reserva eliminada')));
      fetchReservations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar reserva')));
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  void _navigateToEdit(int? reservationId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReservationEditScreen(reservationId: reservationId),
      ),
    );
    if (result == true) fetchReservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Reservas'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _navigateToEdit(null),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : reservations.isEmpty
          ? Center(child: Text('No hay reservas disponibles'))
          : ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          return Card(
            margin: EdgeInsets.all(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reserva Confirmada',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Habitación: ${reservation['roomType']} (${reservation['numberOfPeople']} personas)'),
                  Text('Fecha: ${reservation['startDate']} - ${reservation['endDate']} (${reservation['nights']} noches)'),
                  Text('Servicios: ${reservation['services']}'),
                  Text('Total: S/${reservation['total']}'),
                  Text('Código: ${reservation['code']}'),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton.icon(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        label: Text('Modificar Reserva', style: TextStyle(color: Colors.orange)),
                        onPressed: () => _navigateToEdit(reservation['id']),
                      ),
                      SizedBox(width: 8),
                      TextButton.icon(
                        icon: Icon(Icons.delete, color: Colors.red),
                        label: Text('Cancelar Reserva', style: TextStyle(color: Colors.red)),
                        onPressed: () => _deleteReservation(reservation['id']),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: Icon(Icons.download),
                    label: Text('Descargar Comprobante'),
                    onPressed: () {
                      // Implementa función para descargar comprobante
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
