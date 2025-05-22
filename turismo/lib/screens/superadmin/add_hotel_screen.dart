
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddHotelScreen extends StatefulWidget {
  @override
  _AddHotelScreenState createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String location;
  late int rating;
  late String description;


  Future<void> addHotel() async {
    final response = await http.post(
      Uri.parse('http://192.168.43.81:8080/api/hotels'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'location': location,
        'rating': rating,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hospedaje guardado")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar hospedaje")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar Hospedaje"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Nombre del Hospedaje"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
                onSaved: (value) => name = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: "Ubicación"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una ubicación';
                  }
                  return null;
                },
                onSaved: (value) => location = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Calificación (1-5)"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una calificación';
                  }
                  final numValue = int.tryParse(value);
                  if (numValue == null || numValue < 1 || numValue > 5) {
                    return 'Debe ser un número entre 1 y 5';
                  }
                  return null;
                },
                onSaved: (value) => rating = int.parse(value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                maxLines: 3,
                decoration: InputDecoration(labelText: "Descripción", border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
                onSaved: (value) => description = value!,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Aquí puedes hacer la petición POST al backend
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Hospedaje guardado")),
                    );
                  }
                },
                child: Text("Guardar Hospedaje"),
              )
            ],
          ),
        ),
      ),
    );
  }
}