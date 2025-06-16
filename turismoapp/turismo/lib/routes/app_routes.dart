import 'package:flutter/material.dart';
import '../screens/admin/cliente_detail_screen.dart';
import '../screens/admin/clientes_screen.dart';
import '../screens/admin/habitaciones_form_screen.dart';
import '../screens/admin/habitaciones_screen.dart';
import '../screens/admin/home_screen.dart';
import '../screens/admin/reportes_screen.dart';
import '../screens/admin/reservas_screen.dart';
import '../screens/superadmin/add_hotel_screen.dart';
import '../screens/superadmin/hotels_screen.dart';
import '../screens/superadmin/notifications_screen.dart';
import '../screens/superadmin/reports_screen.dart';
import '../screens/superadmin/reservations_management_screen.dart';
import '../screens/superadmin/restaurants_screen.dart';
import '../screens/superadmin/user_form_screen.dart';
import '../screens/superadmin/user_management_screen.dart';
import '../screens/usuario/user_home_screen.dart';
import '../screens/superadmin/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {


    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case '/user':
        return MaterialPageRoute(builder: (_) => UserHomeScreen());
      case '/admin':
        return MaterialPageRoute(builder: (_) => AdminHomeScreen());
      case '/admin/habitaciones':
        return MaterialPageRoute(builder: (_) => HabitacionesScreen());
      case '/admin/reportes':
        return MaterialPageRoute(builder: (_) => ReportesScreen());

      case '/admin/reservas':
        return MaterialPageRoute(builder: (_) => ReservasScreen()); // crea este archivo luego
      case '/admin/clientes':
        return MaterialPageRoute(builder: (_) => ClientesScreen());
      case '/admin/clientes/detail':
        final cliente = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => ClienteDetailScreen(cliente: cliente));
      case '/admin/habitaciones/form':
        final args = settings.arguments as Map<String, dynamic>?;
    return MaterialPageRoute(builder: (_) => HabitacionesFormScreen(habitacion: args),);
      case '/superadmin':
        return MaterialPageRoute(builder: (_) => SuperAdminHomeScreen());
      case '/superadmin/hotels':
        return MaterialPageRoute(builder: (_) => HotelsScreen());
      case '/superadmin/restaurants':
        return MaterialPageRoute(builder: (_) => RestaurantsScreen());
      case '/superadmin/reservations/manage':
        return MaterialPageRoute(builder: (_) => ReservationsScreen());
      case '/superadmin/hotels/add':
        return MaterialPageRoute(builder: (_) => AddHotelScreen());
      case '/superadmin/users':
        return MaterialPageRoute(builder: (_) => UserManagementScreen());
      case '/superadmin/users/form':
        final args = settings.arguments as Map<String, dynamic>?;
    return MaterialPageRoute(builder: (_) => UserFormScreen(user: args));

      case '/superadmin/reports':
        return MaterialPageRoute(builder: (_) => ReportsScreen());
      case '/superadmin/notifications':
        return MaterialPageRoute(builder: (_) => NotificationsScreen());


      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Página no encontrada')),
          ),
        );
    }
  }
}