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
      final data = await roomService.getRooms();
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

    );
  }
}