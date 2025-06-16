import 'package:flutter/material.dart';
import 'room_edit_screen.dart';
import 'services/room_service.dart';
import 'admin_drawer.dart';

class RoomsScreen extends StatefulWidget {
  @override
  _RoomsScreenState createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final roomService = RoomService();
  List<dynamic> rooms = [];
  bool isLoading = false;

  Future<void> fetchRooms() async {
    setState(() => isLoading = true);
    try {
      final data = await roomService.getMyRooms(); // ← Solo habitaciones del admin autenticado
      setState(() => rooms = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar habitaciones')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> _navigateToEdit({int? roomId}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoomEditScreen(roomId: roomId)),
    );
    if (result == true) {
      fetchRooms();
    }
  }

  Future<void> _deleteRoom(int id) async {
    try {
      await roomService.deleteRoom(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Habitación eliminada')),
      );
      fetchRooms();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar habitación')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(),
      appBar: AppBar(
        title: Text('Gestión de Habitaciones'),
        backgroundColor: Color(0xFF93e5d2),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 30),
        actions: [],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : rooms.isEmpty
          ? Center(
        child: Text(
          'No hay habitaciones disponibles',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          final imageUrl = room['imageUrl'] ?? '';
          final hotelName = room['hotelName'] ?? 'Sin hotel';

          return Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(15),
              shadowColor: Colors.black54,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () => _navigateToEdit(roomId: room['id']),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image, size: 60, color: Colors.lightGreen),
                        ),
                      )
                          : Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: Icon(Icons.meeting_room, size: 60, color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            room['name'] ?? 'Sin nombre',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Hotel: $hotelName',
                            style: TextStyle(color: Colors.grey[700], fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Precio: \$${room['price'] ?? '?'}',
                            style: TextStyle(color: Colors.grey[700], fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Capacidad: ${room['capacity'] ?? '?'}',
                            style: TextStyle(color: Colors.grey[700], fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Divider(color: Colors.grey[300]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blueAccent, size: 24),
                                tooltip: 'Editar',
                                onPressed: () => _navigateToEdit(roomId: room['id']),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.redAccent, size: 24),
                                tooltip: 'Eliminar',
                                onPressed: () => _deleteRoom(room['id']),
                              ),
                            ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(),
        backgroundColor: Color(0xFF93e5d2),
        child: Icon(Icons.add, color: Colors.black),
        tooltip: 'Agregar nueva habitación',
      ),
    );
  }
}
