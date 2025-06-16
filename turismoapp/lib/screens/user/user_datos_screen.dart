import 'package:flutter/material.dart';
import 'user_drawer.dart';

class UserDatosScreen extends StatefulWidget {
  @override
  _UserDatosScreenState createState() => _UserDatosScreenState();
}

class _UserDatosScreenState extends State<UserDatosScreen> {
  final _formKey = GlobalKey<FormState>();

  String nombre = '';
  String email = '';
  String telefono = '';
  String direccion = '';

  bool isLoading = false;

  void _guardarDatos() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Datos guardados correctamente')),
    );

    // Aquí podrías enviar los datos al backend
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: UserDrawer(),
      appBar: AppBar(
        title: Text('Mis Datos'),
        backgroundColor: Color(0xFF93e5d2),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nombre',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Ingrese su nombre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.person, color: Colors.brown),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? 'Ingrese su nombre' : null,
                onSaved: (v) => nombre = v ?? '',
              ),
              SizedBox(height: 16),

              Text(
                'Correo electrónico',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Ingrese su correo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.email, color: Colors.blue),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Ingrese su email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                    return 'Email no válido';
                  }
                  return null;
                },
                onSaved: (v) => email = v ?? '',
              ),
              SizedBox(height: 16),

              Text(
                'Teléfono',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Ingrese su teléfono',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon:
                  Icon(Icons.phone_android, color: Colors.green),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty
                    ? 'Ingrese su teléfono'
                    : null,
                onSaved: (v) => telefono = v ?? '',
              ),
              SizedBox(height: 16),

              Text(
                'Dirección',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Ingrese su dirección',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.home, color: Colors.orange),
                ),
                onSaved: (v) => direccion = v ?? '',
              ),
              SizedBox(height: 30),

              ElevatedButton(
                onPressed: _guardarDatos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2ae5a6),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Guardar',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
