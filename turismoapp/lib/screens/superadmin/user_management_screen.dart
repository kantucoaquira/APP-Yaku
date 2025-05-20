import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<dynamic> users = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final response = await http.get(Uri.parse('http://192.168.1.8:8080/api/users'));
      if (response.statusCode == 200) {
        setState(() {
          users = jsonDecode(response.body);
        });
      } else {
        setState(() {
          errorMessage = 'No se pudieron cargar los usuarios';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error de conexión';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteUser(String userId) async {
    final url = Uri.parse('http://192.168.1.8:8080/api/users/$userId');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      await fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuario eliminado")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar usuario")),
      );
    }
  }

  Future<bool?> confirmDelete(BuildContext context, String username) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Seguro quieres eliminar al usuario "$username"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Eliminar')),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchUsers,
            tooltip: 'Actualizar',
          ),

          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Crear nuevo usuario',
            onPressed: () {
              Navigator.pushNamed(context, '/superadmin/users/form').then((value) {
                if (value == true) fetchUsers();
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
          : users.isEmpty
          ? Center(child: Text('No hay usuarios registrados'))
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(user['username'][0].toUpperCase()),
            ),
            title: Text(user['username']),
            subtitle: Text(user['email']),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                final confirmed = await confirmDelete(context, user['username']);
                if (confirmed == true) {
                  deleteUser(user['id'].toString());
                }
              },
            ),
          );
        },
      ),
    );
  }
}
