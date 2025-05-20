import 'package:flutter/material.dart';

class RestaurantsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestión de Restaurantes"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Aquí puedes navegar a una pantalla de creación
            },
          ),
        ],
      ),
      body: Center(
        child: Text("Lista de Restaurantes"),
      ),
    );
  }
}