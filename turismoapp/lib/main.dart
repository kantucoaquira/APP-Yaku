  import 'package:flutter/material.dart';
  import 'screens/login_screen.dart'; // Importa la pantalla de login
  import 'routes/app_routes.dart'; // Importa el archivo de rutas

  void main() {
    runApp(MyApp());
  }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Turismo App',
        theme: ThemeData(
          primarySwatch: Colors.blue, // Define el tema principal
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
          ),
        ),
        initialRoute: '/login', // Ruta inicial: pantalla de login
        onGenerateRoute: AppRoutes.generateRoute, // Maneja las rutas dinámicamente
        home: LoginScreen(), // Inicia con la pantalla de login
      );
    }
  }