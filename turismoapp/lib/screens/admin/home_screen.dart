import 'package:flutter/material.dart';
import 'admin_drawer.dart';
import 'services/room_service.dart';  // Asegúrate que la ruta es correcta

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final RoomService roomService = RoomService();

  int habitacionesDisponibles = 0;
  int habitacionesOcupadas = 0;

  // Por ahora sin próximas reservas ni alertas
  List<Map<String, String>> proximasReservas = [];
  List<String> alertas = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarResumenHabitaciones();
  }

  Future<void> cargarResumenHabitaciones() async {
    setState(() {
      isLoading = true;
    });

    try {
      final rooms = await roomService.getMyRooms();

      int disponibles = 0;
      int ocupadas = 0;

      for (var room in rooms) {
        if (room['availability'] == 'DISPONIBLE') {
          disponibles++;
        } else if (room['availability'] == 'OCUPADO') {
          ocupadas++;
        }
      }

      setState(() {
        habitacionesDisponibles = disponibles;
        habitacionesOcupadas = ocupadas;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar resumen de habitaciones')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF93e5d2),
        title: Text('Panel Admin - Anfitrión'),
      ),
      drawer: AdminDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
          children: [
            Text(
              'Resumen del Hospedaje',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 190 / 150, // Mantiene tamaño fijo
              children: [
                _buildStatCard(
                    'Habitaciones Disponibles',
                    habitacionesDisponibles.toString(),
                    Icons.hotel,
                    Colors.green),
                _buildStatCard(
                    'Habitaciones Ocupadas',
                    habitacionesOcupadas.toString(),
                    Icons.bed,
                    Colors.redAccent),
                _buildStatCard(
                    'Reservas Activas',
                    '0',
                    Icons.event_available,
                    Colors.blueAccent),
                _buildStatCard(
                    'Ingresos Generados',
                    '\$0.00',
                    Icons.attach_money,
                    Colors.orange),
              ],
            ),
            SizedBox(height: 32),

            // Próximas reservas - vacías por ahora
            Text(
              'Próximas Reservas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            proximasReservas.isEmpty
                ? Text('No hay próximas reservas',
                style: TextStyle(fontSize: 16))
                : Column(
              children: proximasReservas
                  .map((reserva) => Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(Icons.person,
                      color: Colors.blueAccent),
                  title: Text(reserva['cliente']!),
                  subtitle: Text(
                      'Fecha: ${reserva['fecha']}\nHabitación: ${reserva['habitacion']}'),
                  isThreeLine: true,
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
              ))
                  .toList(),
            ),

            SizedBox(height: 32),

            // Alertas - vacías por ahora
            Text(
              'Alertas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            alertas.isEmpty
                ? Text('No hay alertas', style: TextStyle(fontSize: 16))
                : Column(
              children: alertas
                  .map((alerta) => ListTile(
                leading: Icon(Icons.warning,
                    color: Colors.redAccent),
                title: Text(alerta),
                trailing: Icon(Icons.chevron_right),
                onTap: () {},
              ))
                  .toList(),
            ),

            SizedBox(height: 32),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return SizedBox(
      width: 190,
      height: 150,
      child: Card(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                    SizedBox(height: 6),
                    Text(value,
                        style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
