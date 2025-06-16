import 'package:flutter/material.dart';

class ReservationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> reservation;

  const ReservationDetailScreen(this.reservation, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fechas sin la parte de la hora
    final checkIn = reservation['checkIn']?.split('T')[0] ?? 'No especificado';
    final checkOut = reservation['checkOut']?.split('T')[0] ?? 'No especificado';

    final hotelName = reservation['hotelName'] ?? 'Sin hotel';
    final clientName = reservation['clientName'] ?? 'Cliente no disponible';
    final clientEmail = reservation['clientEmail'] ?? 'Correo no disponible';
    final roomName = reservation['roomName'] ?? 'Sin habitación';
    final roomAvailability = reservation['roomAvailability'] ?? 'Desconocido';
    final status = reservation['status'] ?? 'Desconocido';

    return Scaffold(
      appBar: AppBar(title: Text('Detalle de la Reserva')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Documento de Reserva',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(height: 30, thickness: 2),

                _buildSectionTitle('Información del Hotel'),
                _buildDetailRow('Nombre:', hotelName),
                SizedBox(height: 15),

                _buildSectionTitle('Detalles de la Habitación'),
                _buildDetailRow('Nombre:', roomName),
                _buildDetailRow('Disponibilidad:', roomAvailability),
                SizedBox(height: 15),

                _buildSectionTitle('Fechas de la Reserva'),
                _buildDetailRow('Check-in:', checkIn),
                _buildDetailRow('Check-out:', checkOut),
                SizedBox(height: 15),

                _buildSectionTitle('Cliente'),
                _buildDetailRow('Nombre:', clientName),
                _buildDetailRow('Email:', clientEmail),
                SizedBox(height: 15),

                _buildSectionTitle('Estado'),
                _buildDetailRow('Estado:', status),
                SizedBox(height: 25),

                Center(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.picture_as_pdf),
                    label: Text('Generar PDF (próximamente)'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Funcionalidad en desarrollo')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(label, style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }
}
