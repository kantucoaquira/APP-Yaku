import 'package:flutter/material.dart';

class UserHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bienvenido Usuario")),
      body: Center(child: Text("Pantalla de Usuario")),
    );
  }
}