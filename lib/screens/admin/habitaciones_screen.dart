import 'package:flutter/material.dart';
import 'habitacion_edit_screen.dart';
import 'services/habitacion_service.dart';
import 'admin_drawer.dart';

class HabitacionesScreen extends StatefulWidget {
  @override
  _HabitacionesScreenState createState() => _HabitacionesScreenState();
}

class _HabitacionesScreenState extends State<HabitacionesScreen> {
  final habitacionService = HabitacionService();
  List<dynamic> habitaciones = [];
  bool isLoading = false;

  Future<void> fetchHabitaciones() async {
    setState(() => isLoading = true);
    try {
      final data = await habitacionService.getHabitaciones();
      setState(() => habitaciones = data);
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
    fetchHabitaciones();
  }

  Future<void> _navigateToEdit({int? habitacionId}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HabitacionEditScreen(habitacionId: habitacionId),
      ),
    );
    if (result == true) fetchHabitaciones();
  }

  Future<void> _deleteHabitacion(int id) async {
    try {
      await habitacionService.deleteHabitacion(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Habitación eliminada')),
      );
      fetchHabitaciones();
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
        title: Text("Gestión de Habitaciones"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _navigateToEdit(),
            tooltip: "Agregar habitación",
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : habitaciones.isEmpty
          ? Center(child: Text("No hay habitaciones disponibles", style: TextStyle(fontSize: 18)))
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: habitaciones.length,
          itemBuilder: (context, index) {
            final h = habitaciones[index];
            return Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(15),
              shadowColor: Colors.black54,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () => _navigateToEdit(habitacionId: h['id']),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[100],
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      ),
                      child: Icon(Icons.bed, size: 60, color: Colors.grey[700]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Habitación ${h['numero']} - ${h['tipo']}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Precio: \$${h['precio']}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Text(
                            'Hotel: ${h['hotel']['name']}',
                            style: TextStyle(color: Colors.grey[700]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey[300]),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blueAccent),
                            tooltip: 'Editar',
                            onPressed: () => _navigateToEdit(habitacionId: h['id']),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            tooltip: 'Eliminar',
                            onPressed: () => _deleteHabitacion(h['id']),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}