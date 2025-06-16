import 'package:flutter/material.dart';

class HabitacionesFormScreen extends StatefulWidget {
  final Map<String, dynamic>? habitacion; // null para crear, no null para editar

  HabitacionesFormScreen({this.habitacion});

  @override
  _HabitacionesFormScreenState createState() => _HabitacionesFormScreenState();
}

class _HabitacionesFormScreenState extends State<HabitacionesFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tipoController;
  late TextEditingController _capacidadController;
  late TextEditingController _precioController;
  String _estado = 'Disponible';

  @override
  void initState() {
    super.initState();
    _tipoController = TextEditingController(text: widget.habitacion?['tipo'] ?? '');
    _capacidadController = TextEditingController(text: widget.habitacion?['capacidad']?.toString() ?? '');
    _precioController = TextEditingController(text: widget.habitacion?['precio']?.toString() ?? '');
    _estado = widget.habitacion?['estado'] ?? 'Disponible';
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _capacidadController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  void _guardarHabitacion() {
    if (!_formKey.currentState!.validate()) return;

    final nuevaHabitacion = {
      'tipo': _tipoController.text.trim(),
      'capacidad': int.parse(_capacidadController.text.trim()),
      'precio': double.parse(_precioController.text.trim()),
      'estado': _estado,
    };

    // Por ahora solo mostramos snackbar, luego integraremos backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.habitacion == null ? 'Habitación creada' : 'Habitación actualizada')),
    );

    // Puedes hacer Navigator.pop con datos si quieres devolver la habitación creada/actualizada
    Navigator.pop(context, nuevaHabitacion);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.habitacion != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Habitación' : 'Agregar Habitación'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tipoController,
                decoration: InputDecoration(labelText: 'Tipo de habitación'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _capacidadController,
                decoration: InputDecoration(labelText: 'Capacidad'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (int.tryParse(value) == null) return 'Debe ser un número';
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _precioController,
                decoration: InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (double.tryParse(value) == null) return 'Debe ser un número válido';
                  return null;
                },
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: InputDecoration(labelText: 'Estado'),
                items: ['Disponible', 'Ocupada', 'Mantenimiento']
                    .map((e) => DropdownMenuItem(child: Text(e), value: e))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _estado = val ?? 'Disponible';
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarHabitacion,
                child: Text(isEdit ? 'Guardar cambios' : 'Crear habitación'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
