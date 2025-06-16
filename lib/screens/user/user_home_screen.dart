import 'package:flutter/material.dart';
import 'services/room_service.dart'; // Ajusta la ruta si es necesario
import 'user_drawer.dart'; // Drawer para usuarios
import 'user_reservation_screen.dart';

class UserHomeScreen extends StatefulWidget {
  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final RoomService roomService = RoomService();
  List<dynamic> rooms = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    setState(() => isLoading = true);
    try {
      final data = await roomService.getRooms();
      setState(() => rooms = data);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar habitaciones')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: UserDrawer(),
      appBar: AppBar(
        title: Text('Bienvenido '),
        backgroundColor: Color(0xFF93e5d2),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : rooms.isEmpty
              ? Center(
                child: Text(
                  'No hay habitaciones disponibles',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      'Tenemos estas habitaciones para ti',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        final imageUrl = room['imageUrl'] ?? '';
                        final isAvailable =
                            room['availability'] == 'DISPONIBLE';

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: Material(
                            elevation: 6,
                            borderRadius: BorderRadius.circular(15),
                            shadowColor: Colors.black54,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () {}, // No hace nada al tapear la tarjeta
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                    child:
                                        imageUrl.isNotEmpty
                                            ? Image.network(
                                              imageUrl,
                                              height: 180,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (_, __, ___) => Container(
                                                    height: 180,
                                                    color: Colors.grey[300],
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      size: 60,
                                                      color: Colors.lightGreen,
                                                    ),
                                                  ),
                                            )
                                            : Container(
                                              height: 180,
                                              color: Colors.grey[300],
                                              child: Icon(
                                                Icons.meeting_room,
                                                size: 60,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          room['name'] ?? 'Sin nombre',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (room['hotelName'] != null &&
                                            room['hotelName'].isNotEmpty)
                                          Text(
                                            'Hotel: ${room['hotelName']}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Precio: \$${room['price'] ?? '?'}',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Capacidad: ${room['capacity'] ?? '?'}',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Divider(color: Colors.grey[300]),
                                        Center(
                                          child: ElevatedButton(
                                            onPressed: isAvailable
                                                ? () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => UserReservationScreen(
                                                    roomId: room['id'].toString(),
                                                    hotelId: room['hotelId'].toString(),
                                                    // Puedes pasar más info si quieres, como nombre, precio, etc.
                                                  ),
                                                ),
                                              );
                                            }
                                                : null,
                                            child: Text(
                                              isAvailable ? 'Reservar' : 'No disponible',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isAvailable ? Colors.green : Colors.grey,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
