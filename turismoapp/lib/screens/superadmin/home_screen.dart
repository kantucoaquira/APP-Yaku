// screens/superadmin/home_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SuperAdminHomeScreen extends StatefulWidget {
  @override
  _SuperAdminHomeScreenState createState() => _SuperAdminHomeScreenState();
}

class _SuperAdminHomeScreenState extends State<SuperAdminHomeScreen> {
  String name = "Maria";
  String email = "maria@gmail.com";
  String profilePictureUrl = "https://via.placeholder.com/150";

  int activeUsers = 0;
  int totalReservations = 0;
  double totalIncome = 0.0;

  List<dynamic> users = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchStats() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.8:8080/api/stats'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          activeUsers = data['activeUsers'] ?? 0;
          totalReservations = data['totalReservations'] ?? 0;
          totalIncome = double.tryParse(data['totalIncome'].toString()) ?? 0.0;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar estadísticas';
      });
    }
  }

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
      fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuario eliminado")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar usuario")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStats();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("SuperAdmin"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              await fetchStats();
              await fetchUsers();
            },
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamed(context, '/login');

            },
            tooltip: 'Cerrar sesión',
          ),
          IconButton(
            icon: Icon(Icons.people),
            tooltip: 'Gestionar Usuarios',
            onPressed: () {
              Navigator.pushNamed(context, '/superadmin/users');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlue]),
              ),
              child: Center(
                child: Text(
                  'Menú SuperAdmin',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.hotel, color: Colors.blueAccent),
              title: Text('Hospedajes'),
              onTap: () {
                Navigator.pushNamed(context, '/superadmin/hotels');
              },
            ),
            ListTile(
              leading: Icon(Icons.restaurant, color: Colors.orangeAccent),
              title: Text('Restaurantes'),
              onTap: () {
                Navigator.pushNamed(context, '/superadmin/restaurants');
              },
            ),
            ListTile(
              leading: Icon(Icons.event_note, color: Colors.green),
              title: Text('Reservas'),
              onTap: () {
                Navigator.pushNamed(context, '/superadmin/reservations/manage');
              },
            ),
            ListTile(
              leading: Icon(Icons.event_note, color: Colors.green),
              title: Text('Reportes'),
              onTap: () {
                Navigator.pushNamed(context, '/superadmin/reports');

              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: Colors.green),
              title: Text('Nofiticaciones'),
              onTap: () {
                Navigator.pushNamed(context, '/superadmin/notifications');


              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchStats();
          await fetchUsers();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Perfil con sombra y mejor estilo
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                shadowColor: Colors.blueAccent.withOpacity(0.4),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.4),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundImage: NetworkImage(profilePictureUrl),
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent.shade700,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              email,
                              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 28),

              Text(
                "Estadísticas",
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
              ),
              SizedBox(height: 16),

              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard("Usuarios Activos", activeUsers.toString(), Icons.people, Colors.blueAccent),
                  _buildStatCard("Ingresos Totales", "\$${totalIncome.toStringAsFixed(2)}", Icons.attach_money, Colors.green),
                  _buildStatCard("Total de Reservas", totalReservations.toString(), Icons.event_note, Colors.orangeAccent),
                ],
              ),

              SizedBox(height: 40),

              Text(
                "Usuarios",
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
              ),

              SizedBox(height: 16),

              if (errorMessage.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(errorMessage, style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  ),
                )
              else if (isLoading)
                Center(child: CircularProgressIndicator(color: Colors.blueAccent))
              else if (users.isEmpty)
                  Center(child: Text("No hay usuarios registrados", style: TextStyle(fontSize: 16, color: Colors.grey[600])))
                else
                  Container(
                    height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Dismissible(
                          key: Key(user['id'].toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.redAccent,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(Icons.delete, color: Colors.white, size: 32),
                          ),
                          onDismissed: (direction) {
                            deleteUser(user['id'].toString());
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent.shade100,
                              child: Text(
                                user['username'][0].toUpperCase(),
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              user['username'],
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(user['email']),
                            trailing: Chip(
                              backgroundColor: Colors.blueAccent.shade100,
                              label: Text(
                                user['role'],
                                style: TextStyle(color: Colors.blueAccent.shade100, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/superadmin/adduser');
        },
        icon: Icon(Icons.person_add),
        label: Text("Agregar usuario"),
        backgroundColor: Colors.blueAccent,
        elevation: 6,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return SizedBox(
      width: 160,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: iconColor.withOpacity(0.2),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 6),
                    Text(
                      value,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
