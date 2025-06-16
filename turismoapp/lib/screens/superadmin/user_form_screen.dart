import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserFormScreen extends StatefulWidget {
  final Map<String, dynamic>? user; // Si es null, será creación

  UserFormScreen({this.user});

  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String _role = 'user';

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user?['username'] ?? '');
    _emailController = TextEditingController(text: widget.user?['email'] ?? '');
    _passwordController = TextEditingController();
    _role = widget.user?['role'] ?? 'user';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final userData = {
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'role': _role,
    };

    if (_passwordController.text.isNotEmpty) {
      userData['password'] = _passwordController.text.trim();
    }

    try {
      http.Response response;

      if (widget.user == null) {
        // Crear usuario (POST)
        response = await http.post(
          Uri.parse('http://192.168.75.20:8080/api/users'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(userData),
        );
      } else {
        // Editar usuario (PUT)
        final userId = widget.user!['id'];
        response = await http.put(
          Uri.parse('http://192.168.75.20:8080/api/users/$userId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(userData),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario guardado correctamente')),
        );
        Navigator.pop(context, true); // Indicar éxito
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar usuario')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Usuario' : 'Crear Usuario'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Nombre de usuario'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Correo electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Correo inválido';
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: isEdit ? 'Nueva contraseña (dejar en blanco para no cambiar)' : 'Contraseña',
                ),
                obscureText: true,
                validator: (value) {
                  if (!isEdit && (value == null || value.isEmpty)) return 'Campo requerido';
                  return null;
                },
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: InputDecoration(labelText: 'Rol'),
                items: [
                  DropdownMenuItem(value: 'user', child: Text('Usuario')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                  DropdownMenuItem(value: 'superadmin', child: Text('SuperAdmin')),
                ],
                onChanged: (value) => setState(() => _role = value ?? 'user'),
              ),
              SizedBox(height: 24),
              _isSubmitting
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitForm,
                child: Text(isEdit ? 'Guardar cambios' : 'Crear usuario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
