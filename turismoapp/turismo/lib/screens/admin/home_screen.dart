import 'package:flutter/material.dart';
import 'admin_drawer.dart';  // importa el drawer

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // Datos simulados para mostrar en dashboard
  int habitacionesDisponibles = 12;
  int habitacionesOcupadas = 8;
  int reservasActivas = 10;
  double ingresosGenerados = 4500.75;

  List<Map<String, String>> proximasReservas = [
    {'cliente': 'Juan Pérez', 'fecha': '2025-06-01', 'habitacion': 'Doble'},
    {'cliente': 'María López', 'fecha': '2025-06-03', 'habitacion': 'Suite'},
    {'cliente': 'Carlos Ruiz', 'fecha': '2025-06-05', 'habitacion': 'Simple'},
  ];

  List<String> alertas = [
    'Reserva pendiente por confirmar: Juan Pérez',
    'Habitación Suite en mantenimiento',
    'Nuevo comentario de cliente: María López',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel Admin - Hospedaje'),
      ),
      drawer: AdminDrawer(),  // Drawer lateral para navegación
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Resumen del Hospedaje',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Estadísticas en cards
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard('Habitaciones Disponibles', habitacionesDisponibles.toString(), Icons.hotel, Colors.green),
                _buildStatCard('Habitaciones Ocupadas', habitacionesOcupadas.toString(), Icons.bed, Colors.redAccent),
                _buildStatCard('Reservas Activas', reservasActivas.toString(), Icons.event_available, Colors.blueAccent),
                _buildStatCard('Ingresos Generados', '\$${ingresosGenerados.toStringAsFixed(2)}', Icons.attach_money, Colors.orange),
              ],
            ),

            SizedBox(height: 32),

            // Próximas reservas
            Text(
              'Próximas Reservas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...proximasReservas.map((reserva) => Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(Icons.person, color: Colors.blueAccent),
                title: Text(reserva['cliente']!),
                subtitle: Text('Fecha: ${reserva['fecha']}\nHabitación: ${reserva['habitacion']}'),
                isThreeLine: true,
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navegar a detalle reserva cuando exista pantalla
                },
              ),
            )),

            SizedBox(height: 32),

            // Alertas recientes
            Text(
              'Alertas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...alertas.map((alerta) => ListTile(
              leading: Icon(Icons.warning, color: Colors.redAccent),
              title: Text(alerta),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Navegar a sección relacionada con alerta
              },
            )),

            SizedBox(height: 32),

            // Accesos rápidos
            Text(
              'Accesos rápidos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildQuickAccessCard(Icons.hotel, 'Habitaciones', () {
                  Navigator.pushNamed(context, '/admin/habitaciones');
                }),
                _buildQuickAccessCard(Icons.event, 'Reservas', () {
                  Navigator.pushNamed(context, '/admin/reservas');
                }),
                _buildQuickAccessCard(Icons.people, 'Clientes', () {
                  Navigator.pushNamed(context, '/admin/clientes');
                }),
                _buildQuickAccessCard(Icons.insert_chart, 'Reportes', () {
                  Navigator.pushNamed(context, '/admin/reportes'); // crea esta ruta luego
                }),
              ],
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return SizedBox(
      width: 160,
      child: Card(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                    SizedBox(height: 6),
                    Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(IconData icon, String title, VoidCallback onTap) {
    return SizedBox(
      width: 150,
      height: 100,
      child: Card(
        color: Colors.blue[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: Colors.blueAccent),
                SizedBox(height: 8),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
