import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.greenAccent),
            child: Center(
              child: Text(
                'Menú Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: Colors.blue),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin');
            },
          ),
          ListTile(
            leading: Icon(Icons.hotel, color: Colors.deepPurple),
            title: Text('Habitaciones'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin/rooms');
            },
          ),
          ListTile(
            leading: Icon(Icons.event, color: Colors.orange),
            title: Text('Reservas'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin/reservas');
            },
          ),
          ListTile(
            leading: Icon(Icons.upcoming, color: Colors.pinkAccent),
            title: Text('Menu'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin/menu');
            },
          ),
          ListTile(
            leading: Icon(Icons.people, color: Colors.teal),
            title: Text('Mis Datos'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin/perfil');
            },
          ),
          ListTile(
            leading: Icon(Icons.book_online, color: Colors.black87),
            title: Text('Paquetes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/admin/paquete');
            },
          ),
          ListTile(
            leading: Icon(Icons.insert_drive_file, color: Colors.brown),
            title: Text('Reportes'),
            onTap: () {
              Navigator.pushNamed(context, '/admin/reportes');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.redAccent),
            title: Text('Cerrar sesión'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
