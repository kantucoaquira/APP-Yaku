import 'package:flutter/material.dart';

class ClienteDetailScreen extends StatefulWidget {
  final Map<String, dynamic> cliente;

  ClienteDetailScreen({required this.cliente});

  @override
  _ClienteDetailScreenState createState() => _ClienteDetailScreenState();
}

class _ClienteDetailScreenState extends State<ClienteDetailScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;

  List<Map<String, String>> historialReservas = [
    {'fecha': '2025-05-01', 'habitacion': 'Doble', 'estado': 'Completada'},
    {'fecha': '2025-03-20', 'habitacion': 'Simple', 'estado': 'Cancelada'},
  ];

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.cliente['nombre']);
    _emailController = TextEditingController(text: widget.cliente['email']);
    _telefonoController = TextEditingController(text: widget.cliente['telefono']);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    // Aquí deberías enviar los datos al backend para actualizar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cambios guardados')),
    );
    _toggleEdit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle Cliente'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveChanges : _toggleEdit,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
              enabled: _isEditing,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _telefonoController,
              decoration: InputDecoration(labelText: 'Teléfono'),
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 24),
            Text('Historial de Reservas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            ...historialReservas.map((reserva) => Card(
              margin: EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text('Fecha: ${reserva['fecha']}'),
                subtitle: Text('Habitación: ${reserva['habitacion']} - Estado: ${reserva['estado']}'),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
