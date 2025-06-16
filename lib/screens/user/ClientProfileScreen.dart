import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'services/client_service.dart';
import 'user_drawer.dart';

class ClientProfileScreen extends StatefulWidget {
  @override
  _ClientProfileScreenState createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? email;
  bool isLoading = false;

  XFile? _imageFile;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString('user_email');

      if (storedEmail == null) {
        setState(() => email = 'No disponible');
        return;
      }

      setState(() => email = storedEmail);

      final clientService = ClientService();
      final clientData = await clientService.getClientByEmail();

      if (clientData != null && mounted) {
        setState(() {
          _nameController.text = clientData['name'] ?? '';
          _phoneController.text = clientData['phone'] ?? '';
          _addressController.text = clientData['address'] ?? '';
          _imageUrl = clientData['imageUrl'];
        });
      } else {
        debugPrint("No se pudo cargar información desde el backend.");
      }
    } catch (e) {
      debugPrint("Error en _loadUserData: $e");
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _imageFile = pickedFile;
          _imageUrl = null;
        });
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al seleccionar imagen"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final clientService = ClientService();
      final data = {
        "name": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "address": _addressController.text.trim(),
        "email": email!.trim(),
      };

      final success = await clientService.updateClient(data);

      if (!success) throw Exception('Error al guardar datos');

      if (_imageFile != null) {
        final uploadedUrl = await clientService.uploadClientImage(File(_imageFile!.path));
        if (uploadedUrl != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('client_image_url_$email', uploadedUrl);
          setState(() => _imageUrl = uploadedUrl);
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString('client_name_$email', _nameController.text.trim()),
        prefs.setString('client_phone_$email', _phoneController.text.trim()),
        prefs.setString('client_address_$email', _addressController.text.trim()),
      ]);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perfil actualizado'),
          backgroundColor: Colors.green,
        ),
      );
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().contains('403')
              ? 'Acceso denegado. Inicia sesión nuevamente'
              : 'Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }

    await _loadUserData();
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(75),
      child: Container(
        width: 150,
        height: 150,
        child: _imageFile != null
            ? Image.file(File(_imageFile!.path), fit: BoxFit.cover)
            : (_imageUrl != null && _imageUrl!.isNotEmpty)
            ? Image.network(
          _imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
        )
            : _buildPlaceholderIcon(),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.grey[300],
      child: Icon(Icons.person, size: 60, color: Colors.grey[600]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: UserDrawer(),
      appBar: AppBar(
        title: Text("Mis Datos"),
        backgroundColor: Color(0xFF93e5d2),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileSection(),
              SizedBox(height: 20),
              _buildEmailSection(),
              SizedBox(height: 20),
              _buildNameField(),
              SizedBox(height: 16),
              _buildPhoneField(),
              SizedBox(height: 16),
              _buildAddressField(),
              SizedBox(height: 30),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Foto de Perfil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: _buildImagePreview(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Correo electrónico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[200],
          ),
          child: Text(email ?? 'No disponible', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nombre Completo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: _buildInputDecoration(
            hintText: 'Ingrese su nombre',
            icon: Icon(Icons.person, color: Colors.brown),
          ),
          validator: (value) => value!.isEmpty ? "Ingrese su nombre" : null,
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Teléfono', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: _buildInputDecoration(
            hintText: 'Ingrese su teléfono',
            icon: Icon(Icons.phone_android, color: Colors.green),
          ),
          validator: (value) => value!.isEmpty ? "Ingrese su teléfono" : null,
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dirección', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        TextFormField(
          controller: _addressController,
          decoration: _buildInputDecoration(
            hintText: 'Ingrese su dirección',
            icon: Icon(Icons.home, color: Colors.orange),
          ),
          validator: (value) => value!.isEmpty ? "Ingrese su dirección" : null,
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({required String hintText, required Icon icon}) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      prefixIcon: icon,
      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton(
      onPressed: _submit,
      style: _buildButtonStyle(Color(0xFFffc93c)),
      child: Text(
        'Actualizar',
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }

  ButtonStyle _buildButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
    );
  }
}
