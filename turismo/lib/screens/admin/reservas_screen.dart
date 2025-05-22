import 'package:flutter/material.dart';
import 'admin_drawer.dart';

class ReservasScreen extends StatefulWidget {
  @override
  _ReservasScreenState createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  List<Map<String, dynamic>> reservas = [
    {
      'id': 1,
      'cliente': 'Juan Pérez',
      'fecha': '2025-06-01',
      'habitacion': 'Doble',
      'estado': 'Pendiente',
    },
    {
      'id': 2,
      'cliente': 'María López',
      'fecha': '2025-06-03',
      'habitacion': 'Suite',
      'estado': 'Confirmada',
    },
    {
      'id': 3,
      'cliente': 'Carlos Ruiz',
      'fecha': '2025-06-05',
      'habitacion': 'Simple',
      'estado': 'Cancelada',
    },
  ];

  void _cambiarEstado(int id, String nuevoEstado) {
    setState(() {
      final index = reservas.indexWhere((reserva) => reserva['id'] == id);
      if (index != -1) {
        reservas[index]['estado'] = nuevoEstado;
      }
    });
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Confirmada':
        return Colors.green;
      case 'Pendiente':
        return Colors.orange;
      case 'Cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Reservas'),
      ),
      drawer: AdminDrawer(),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: reservas.length,
        itemBuilder: (context, index) {
          final reserva = reservas[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: ListTile(
              leading: Icon(Icons.event_available, color: _colorEstado(reserva['estado'])),
              title: Text('${reserva['cliente']}'),
              subtitle: Text('Fecha: ${reserva['fecha']} - Habitación: ${reserva['habitacion']}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  _cambiarEstado(reserva['id'], value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Estado cambiado a $value')),
                  );
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'Confirmada', child: Text('Confirmar')),
                  PopupMenuItem(value: 'Pendiente', child: Text('Pendiente')),
                  PopupMenuItem(value: 'Cancelada', child: Text('Cancelar')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
