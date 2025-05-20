import 'package:flutter/material.dart';
import 'admin_drawer.dart';

class ClientesScreen extends StatefulWidget {
  @override
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  // Lista simulada de clientes
  List<Map<String, dynamic>> clientes = [
    {
      'id': 1,
      'nombre': 'Juan Pérez',
      'email': 'juan@example.com',
      'telefono': '987654321',
      'reservas': 5,
    },
    {
      'id': 2,
      'nombre': 'María López',
      'email': 'maria@example.com',
      'telefono': '912345678',
      'reservas': 2,
    },
    {
      'id': 3,
      'nombre': 'Carlos Ruiz',
      'email': 'carlos@example.com',
      'telefono': '999888777',
      'reservas': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Clientes'),
      ),
      drawer: AdminDrawer(),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: clientes.length,
        itemBuilder: (context, index) {
          final cliente = clientes[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: ListTile(
              leading: CircleAvatar(child: Text(cliente['nombre'][0])),
              title: Text(cliente['nombre']),
              subtitle: Text('Email: ${cliente['email']}\nTel: ${cliente['telefono']}'),
              isThreeLine: true,
              trailing: Chip(label: Text('${cliente['reservas']} reservas')),
              onTap: () {
                Navigator.pushNamed(context, '/admin/clientes/detail', arguments: cliente);
              },
            ),
          );
        },
      ),
    );
  }
}
