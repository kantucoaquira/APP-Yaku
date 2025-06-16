import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // Para SocketException
import 'dart:async'; // Para TimeoutException
import 'package:shared_preferences/shared_preferences.dart';

// --- CONSTANTES ---
const String _baseUrl = 'http://192.168.75.20:8080/api'; // Cambia si es necesario
const String _jwtTokenKey = 'jwt_token';

// --- MODELOS DE DATOS ---
class User {
  final String id;
  final String username;
  final String email;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(), // Fallback ID
      username: json['username'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      role: json['role'] ?? 'USER',
    );
  }
}

class StatsData {
  final int activeUsers;
  final int totalReservations;
  final double totalIncome;

  StatsData({
    required this.activeUsers,
    required this.totalReservations,
    required this.totalIncome,
  });

  factory StatsData.fromJson(Map<String, dynamic> json) {
    return StatsData(
      activeUsers: json['activeUsers'] ?? 0,
      totalReservations: json['totalReservations'] ?? 0,
      totalIncome: double.tryParse(json['totalIncome'].toString()) ?? 0.0,
    );
  }
}

// --- WIDGET PRINCIPAL ---
class SuperAdminHomeScreen extends StatefulWidget {
  const SuperAdminHomeScreen({super.key}); // Añadido super.key

  @override
  _SuperAdminHomeScreenState createState() => _SuperAdminHomeScreenState();
}

class _SuperAdminHomeScreenState extends State<SuperAdminHomeScreen> {
  // Datos del perfil (podrían venir de un objeto User también)
  String adminName = "Maria";
  String adminEmail = "maria@gmail.com";
  String adminProfilePictureUrl = "https://via.placeholder.com/150";

  // Estado de la UI
  StatsData? stats;
  List<User> users = [];
  bool isLoadingStats = false;
  bool isLoadingUsers = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await fetchStats();
    await fetchUsers();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_jwtTokenKey);
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _handleApiError(dynamic e, http.Response? response, String contextMessage) async {
    if (!mounted) return;
    String message;
    if (e is SocketException) {
      message = 'Error de conexión. Verifica tu red.';
    } else if (e is TimeoutException) {
      message = 'Tiempo de espera agotado. Intenta de nuevo.';
    } else if (response != null) {
      if (response.statusCode == 401) {
        message = 'No autorizado. Serás redirigido al login.';
        await _logoutAndNavigateToLogin();
        return; // Salimos temprano porque ya navegamos
      }
      try {
        final errorData = jsonDecode(response.body);
        message = errorData['message'] ?? '$contextMessage (Código: ${response.statusCode})';
      } catch (_) {
        message = '$contextMessage (Código: ${response.statusCode})';
      }
    } else {
      message = '$contextMessage: ${e.toString()}';
    }
    setState(() {
      errorMessage = message;
    });
  }

  Future<void> _logoutAndNavigateToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_jwtTokenKey);
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  Future<void> fetchStats() async {
    if (!mounted) return;
    setState(() {
      isLoadingStats = true;
      errorMessage = ''; // Limpiar errores previos de esta sección
    });

    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$_baseUrl/stats'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          stats = StatsData.fromJson(data);
        });
      } else {
        _handleApiError(null, response, 'Error al cargar estadísticas');
      }
    } catch (e) {
      _handleApiError(e, null, 'Error al cargar estadísticas');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingStats = false;
        });
      }
    }
  }

  Future<void> fetchUsers() async {
    if (!mounted) return;
    setState(() {
      isLoadingUsers = true;
      errorMessage = ''; // Limpiar errores previos de esta sección
    });

    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$_baseUrl/users'), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          users = jsonData.map((item) => User.fromJson(item)).toList();
        });
      } else {
        _handleApiError(null, response, 'No se pudieron cargar los usuarios');
      }
    } catch (e) {
      _handleApiError(e, null, 'Error al cargar usuarios');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingUsers = false;
        });
      }
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(Uri.parse('$_baseUrl/users/$userId'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario eliminado exitosamente")),
        );
        await fetchUsers(); // Recargar la lista de usuarios
      } else {
        _handleApiError(null, response, 'Error al eliminar usuario');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage.isNotEmpty ? errorMessage : "Error al eliminar usuario")),
        );
      }
    } catch (e) {
      _handleApiError(e, null, 'Error al eliminar usuario');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage.isNotEmpty ? errorMessage : "Error al eliminar usuario")),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    // Usar Future.wait para ejecutar en paralelo si no dependen una de otra
    // En este caso, no hay una dependencia directa fuerte, pero se refrescan juntas.
    await fetchStats();
    await fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("SuperAdmin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _logoutAndNavigateToLogin();
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      drawer: _buildDrawer(context), // Extraído para legibilidad
      body: RefreshIndicator(
        onRefresh: _refreshData,
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
              _UserProfileCard(
                name: adminName,
                email: adminEmail,
                profilePictureUrl: adminProfilePictureUrl,
              ),
              const SizedBox(height: 28),
              Text(
                "Estadísticas Generales",
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
              ),
              const SizedBox(height: 16),
              _buildStatsSection(),
              const SizedBox(height: 40),
              Text(
                "Gestión de Usuarios",
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
              ),
              const SizedBox(height: 16),
              _buildUsersSection(),
              if (errorMessage.isNotEmpty && !isLoadingStats && !isLoadingUsers) // Mostrar error general si existe y no hay cargas activas
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Asegúrate de que esta ruta esté definida en tu MaterialApp
          Navigator.pushNamed(context, '/superadmin/adduser').then((newUserAdded) {
            // Si la pantalla de agregar usuario devuelve true, refresca la lista
            if (newUserAdded == true) {
              fetchUsers();
            }
          });
        },
        icon: const Icon(Icons.person_add),
        label: const Text("Agregar Usuario"),
        backgroundColor: Colors.blueAccent,
        elevation: 6,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlue]),
            ),
            child: Center(
              child: Text(
                'Menú SuperAdmin',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          _drawerListTile(context, Icons.hotel, 'Hospedajes', '/superadmin/hotels', Colors.blueAccent),
          _drawerListTile(context, Icons.restaurant, 'Restaurantes', '/superadmin/restaurants', Colors.orangeAccent),
          _drawerListTile(context, Icons.event_note, 'Reservas', '/superadmin/reservations/manage', Colors.green),
          _drawerListTile(context, Icons.insert_chart, 'Reportes', '/superadmin/reports', Colors.purple),
          _drawerListTile(context, Icons.notifications, 'Notificaciones', '/superadmin/notifications', Colors.redAccent),
        ],
      ),
    );
  }

  ListTile _drawerListTile(BuildContext context, IconData icon, String title, String route, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Cierra el drawer
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _buildStatsSection() {
    if (isLoadingStats && stats == null) { // Mostrar shimmer o placeholder si se desea
      return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
    }
    // No mostramos error aquí directamente, se manejará de forma global o en el widget de error principal
    // if (errorMessage.isNotEmpty && stats == null) {
    //   return Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)));
    // }
    if (stats == null && !isLoadingStats) { // Si no hay datos y no está cargando (podría ser un error inicial)
      return const Center(child: Text("No se pudieron cargar las estadísticas.", style: TextStyle(color: Colors.grey)));
    }


    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center, // Centrar las tarjetas si no ocupan todo el ancho
      children: [
        _buildStatCard("Usuarios Activos", stats?.activeUsers.toString() ?? "-", Icons.people_alt_outlined, Colors.blueAccent),
        _buildStatCard("Ingresos Totales", "\$${stats?.totalIncome.toStringAsFixed(2) ?? "-"}", Icons.monetization_on_outlined, Colors.green),
        _buildStatCard("Total de Reservas", stats?.totalReservations.toString() ?? "-", Icons.event_available_outlined, Colors.orangeAccent),
      ],
    );
  }

  Widget _buildUsersSection() {
    if (isLoadingUsers && users.isEmpty) { // Mostrar shimmer o placeholder si se desea
      return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
    }
    // El error general se muestra al final del ListView principal.
    // if (errorMessage.isNotEmpty && users.isEmpty && !isLoadingUsers) {
    //   return Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)));
    // }
    if (users.isEmpty && !isLoadingUsers) {
      return Center(child: Text("No hay usuarios registrados.", style: TextStyle(fontSize: 16, color: Colors.grey[600])));
    }
    if (users.isEmpty && isLoadingUsers) { // Si está cargando y no hay usuarios, no mostrar "No hay usuarios" aún.
      return const SizedBox.shrink();
    }


    return Container(
      // Considera no usar una altura fija o hacerla más dinámica si es posible.
      // Si la lista es muy larga, esta altura fija podría ser un problema.
      // Para este ejemplo, la mantenemos como en tu original.
      height: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
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
            key: Key(user.id), // Usar el ID del objeto User
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.redAccent.shade100,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 32),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirmar Eliminación"),
                    content: Text("¿Estás seguro de que deseas eliminar a ${user.username}?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("CANCELAR"),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("ELIMINAR"),
                      ),
                    ],
                  );
                },
              ) ?? false; // Retorna false si el diálogo es descartado
            },
            onDismissed: (direction) {
              deleteUser(user.id);
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent.withOpacity(0.1),
                child: Text(
                  user.username.isNotEmpty ? user.username[0].toUpperCase() : "U",
                  style: TextStyle(color: Colors.blueAccent.shade700, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                user.username,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(user.email),
              trailing: Chip(
                backgroundColor: Colors.blueAccent.withOpacity(0.1),
                avatar: Icon(Icons.security_outlined, size: 16, color: Colors.blueAccent.shade700),
                label: Text(
                  user.role.replaceAll('ROLE_', '').toLowerCase().capitalize(),
                  style: TextStyle(color: Colors.blueAccent.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    // Usar LayoutBuilder o MediaQuery si necesitas que sea más responsivo
    // Por ahora, mantenemos el SizedBox con ancho fijo como en tu original.
    return SizedBox(
      width: MediaQuery.of(context).size.width > 360 ? 170 : (MediaQuery.of(context).size.width / 2) - 30, // Un poco más responsivo
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: iconColor.withOpacity(0.15),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded( // Usar Expanded en lugar de Flexible aquí para que tome el espacio
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      value,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
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

// --- EXTENSIONES ---
extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

// --- WIDGET EXTRAÍDO (EJEMPLO) ---
class _UserProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String profilePictureUrl;

  const _UserProfileCard({
    // Key? key, // No es necesario si no lo usas explícitamente y es privado
    required this.name,
    required this.email,
    required this.profilePictureUrl,
  }); // : super(key: key); // No es necesario

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.blueAccent.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(profilePictureUrl), // Considerar placeholder y errorBuilder para NetworkImage
                onBackgroundImageError: (exception, stackTrace) {
                  // Log error or show fallback
                },
                backgroundColor: Colors.grey[200],
              ),
            ),
            const SizedBox(width: 20),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    email,
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}