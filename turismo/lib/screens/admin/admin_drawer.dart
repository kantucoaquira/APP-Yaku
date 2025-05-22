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
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Text(
              'Menú Admin',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin');
            },
          ),
          ListTile(
            leading: Icon(Icons.hotel),
            title: Text('Habitaciones'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin/habitaciones');
            },
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Reservas'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin/reservas');
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Clientes'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin/clientes');
            },
          ),
          ListTile(
            leading: Icon(Icons.insert_drive_file),
            title: Text('Reportes'),
            onTap: () {
              Navigator.pushNamed(context, '/admin/reportes');

            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
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
