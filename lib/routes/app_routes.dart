import 'package:flutter/material.dart';
import 'package:turismoapp/screens/admin/paquete_screen.dart';
import 'package:turismoapp/screens/user/usuario_paquetes_screen.dart';
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
import '../screens/user/user_home_screen.dart';
import '../screens/superadmin/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/admin/rooms_screen.dart';          // Cambiado import para RoomsScreen
import '../screens/admin/room_edit_screen.dart';      // Cambiado import para RoomEditScreen
import '../screens/user/user_datos_screen.dart';
import '../screens/user/ClientProfileScreen.dart';
import '../screens/user/UserReservationsListScreen.dart';
import '../screens/admin/menus_screen.dart';
import '../screens/admin/menu_edit_screen.dart';


class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {


    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterScreen());

      case '/user':
        return MaterialPageRoute(builder: (_) => UserHomeScreen());
      case '/user/datos':
        return MaterialPageRoute(builder: (_) => UserDatosScreen());
      case '/user/perfil':
        return MaterialPageRoute(builder: (_) => ClientProfileScreen());
      case '/user/reservation':
        return MaterialPageRoute(builder: (_) => UserReservationsListScreen());
      case '/user/paquete':
        return MaterialPageRoute(builder: (_) => UsuarioPaqueteScreen());


      case '/admin':
        return MaterialPageRoute(builder: (_) => AdminHomeScreen());
      case '/admin/habitaciones':
        return MaterialPageRoute(builder: (_) => HabitacionesScreen());
      case '/admin/rooms':
        return MaterialPageRoute(builder: (_) => RoomsScreen());
      case '/admin/menu':
        return MaterialPageRoute(builder: (_) => MenuScreen());
      case '/admin/reportes':
        return MaterialPageRoute(builder: (_) => ReportesScreen());
      case '/admin/reservas':
        return MaterialPageRoute(builder: (_) => ReservasScreen()); // crea este archivo luego
      case '/admin/clientes':
        return MaterialPageRoute(builder: (_) => ClientesScreen());
      case '/admin/perfil':
        return MaterialPageRoute(builder: (_) => ClientProfileScreen());
      case '/admin/paquete':
        return MaterialPageRoute(builder: (_) => PaqueteScreen());
      case '/admin/clientes/detail':
        final cliente = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => ClienteDetailScreen(cliente: cliente));
      case '/admin/habitaciones/form':
        final args = settings.arguments as Map<String, dynamic>?;
       return MaterialPageRoute(builder: (_) => HabitacionesFormScreen(habitacion: args),);
    // Ruta actualizada para formulario de edición/creación de habitación (room)
      case '/admin/rooms/edit':
        final args = settings.arguments as Map<String, dynamic>?;
        // args puede contener el roomId u otros datos
        final int? roomId = args != null ? args['roomId'] as int? : null;
        return MaterialPageRoute(builder: (_) => RoomEditScreen(roomId: roomId));
      case '/admin/menu/edit':
        final args = settings.arguments as Map<String, dynamic>?;
        final int? menuId = args != null ? args['menuId'] as int? : null;
        return MaterialPageRoute(builder: (_) => MenuEditScreen(menuId: menuId));




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