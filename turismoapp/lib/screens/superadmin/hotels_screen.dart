import 'package:flutter/material.dart';

class HotelsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestión de Hospedajes"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/superadmin/hotels/add');
            },
          ),
        ],
      ),
      body: Center(
        child: Text("Lista de Hospedajes"),
      ),
    );
  }
}