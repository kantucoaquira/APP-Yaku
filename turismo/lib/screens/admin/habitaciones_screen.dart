import 'package:flutter/material.dart';
import 'admin_drawer.dart';  // Importa el drawer

class HabitacionesScreen extends StatefulWidget {
  @override
  _HabitacionesScreenState createState() => _HabitacionesScreenState();
}

class _HabitacionesScreenState extends State<HabitacionesScreen> {
  List<Map<String, dynamic>> habitaciones = [
    {
      'id': 1,
      'tipo': 'Simple',
      'capacidad': 1,
      'precio': 50.0,
      'estado': 'Disponible',
    },
    {
      'id': 2,
      'tipo': 'Doble',
      'capacidad': 2,
      'precio': 80.0,
      'estado': 'Ocupada',
    },
    {
      'id': 3,
      'tipo': 'Suite',
      'capacidad': 4,
      'precio': 150.0,
      'estado': 'Disponible',
    },
  ];

  void _agregarHabitacion() async {
    final nuevaHabitacion = await Navigator.pushNamed(context, '/admin/habitaciones/form');
    if (nuevaHabitacion != null && nuevaHabitacion is Map<String, dynamic>) {
      setState(() {
        int nuevoId = habitaciones.isNotEmpty
            ? habitaciones.map((h) => h['id'] as int).reduce((a, b) => a > b ? a : b) + 1
            : 1;
        nuevaHabitacion['id'] = nuevoId;
        habitaciones.add(nuevaHabitacion);
      });
    }
  }

  void _editarHabitacion(Map<String, dynamic> habitacion) async {
    final habitacionEditada = await Navigator.pushNamed(
      context,
      '/admin/habitaciones/form',
      arguments: habitacion,
    );
    if (habitacionEditada != null && habitacionEditada is Map<String, dynamic>) {
      setState(() {
        int index = habitaciones.indexWhere((h) => h['id'] == habitacionEditada['id']);
        if (index != -1) {
          habitaciones[index] = habitacionEditada;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Habitaciones'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Agregar habitación',
            onPressed: _agregarHabitacion,
          ),
        ],
      ),
      drawer: AdminDrawer(),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: habitaciones.length,
        itemBuilder: (context, index) {
          final habitacion = habitaciones[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: ListTile(
              leading: Icon(Icons.hotel, color: Colors.blueAccent),
              title: Text('${habitacion['tipo']} - Capacidad: ${habitacion['capacidad']}'),
              subtitle: Text('Precio: \$${habitacion['precio']} - Estado: ${habitacion['estado']}'),
              isThreeLine: true,
              trailing: IconButton(
                icon: Icon(Icons.edit, color: Colors.blueAccent),
                onPressed: () => _editarHabitacion(habitacion),
              ),
              onTap: () {
                // Puedes añadir acción aquí si quieres mostrar detalles
              },
            ),
          );
        },
      ),
    );
  }
}
