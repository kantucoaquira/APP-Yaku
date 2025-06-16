import 'package:flutter/material.dart';
import 'services/reservation_service.dart';
import 'user_drawer.dart';
import 'ReservationDetailScreen.dart';

class UserReservationsListScreen extends StatefulWidget {
  @override
  _UserReservationsListScreenState createState() => _UserReservationsListScreenState();
}

class _UserReservationsListScreenState extends State<UserReservationsListScreen> {
  final ReservationService _reservationService = ReservationService();
  late Future<List<dynamic>> _reservationsFuture;

  @override
  void initState() {
    super.initState();
    _reservationsFuture = _reservationService.getMyReservations();
  }

  void _refreshReservations() {
    setState(() {
      _reservationsFuture = _reservationService.getMyReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: UserDrawer(),
      appBar: AppBar(title: Text("Mis Reservas")),
      body: FutureBuilder<List<dynamic>>(
        future: _reservationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error al cargar reservas"));
          }

          final reservations = snapshot.data;

          if (reservations == null || reservations.isEmpty) {
            return Center(child: Text("No tienes reservas"));
          }

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];

              final checkIn = reservation['checkIn'] ?? '';
              final checkOut = reservation['checkOut'] ?? '';
              final hotelName = reservation['hotelName'] ?? 'Sin hotel';
              final roomName = reservation['roomName'] ?? 'Sin habitación';
              final status = reservation['status'] ?? '';

              if (status == 'CANCELADA') {
                return SizedBox.shrink();
              }

              return Card(
                child: ListTile(
                  title: Text('Hotel: $hotelName'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Habitación: $roomName'),
                      Text('Entrada: $checkIn'),
                      Text('Salida: $checkOut'),
                      Text('Estado: $status'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        child: Text('Cancelar', style: TextStyle(color: Colors.red)),
                        onPressed: () async {
                          final success = await _reservationService.cancelReservation(reservation['id']);
                          if (success) {
                            _refreshReservations();
                          }
                        },
                      ),
                      SizedBox(width: 8),
                      TextButton(
                        child: Text('Ver detalle'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReservationDetailScreen(reservation),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
