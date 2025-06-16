import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDrawer extends StatefulWidget {
  const UserDrawer({Key? key}) : super(key: key);

  @override
  _UserDrawerState createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_username') ?? 'Usuario';
      userEmail = prefs.getString('user_email') ?? 'correo@example.com';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: TextStyle(fontSize: 40.0, color: Colors.green),
              ),
            ),
            decoration: BoxDecoration(
              color: Color(0xFF93e5d2),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/user');
            },
          ),
          ListTile(
            leading: Icon(Icons.search),
            title: Text('Buscar Hoteles'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/user');
            },
          ),
          ListTile(
            leading: Icon(Icons.book_online),
            title: Text('Mis Reservas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/user/reservation');
            },
          ),

          ListTile(
            leading: Icon(Icons.person),
            title: Text('Mis Datos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/user/perfil');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Paquetes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/user/paquete');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.redAccent),
            title: Text('Cerrar sesión', style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // ✅ Limpiar los datos del usuario
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
