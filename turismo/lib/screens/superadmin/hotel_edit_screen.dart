import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/hotel_service.dart';

class HotelEditScreen extends StatefulWidget {
  final int? hotelId; // null para nuevo, no null para editar

  const HotelEditScreen({Key? key, this.hotelId}) : super(key: key);

  @override
  _HotelEditScreenState createState() => _HotelEditScreenState();
}

class _HotelEditScreenState extends State<HotelEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final hotelService = HotelService();

  String name = '';
  String address = '';
  String phone = '';
  String description = '';

  bool isLoading = false;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadHotel();
  }

  Future<void> _loadHotel() async {
    if (widget.hotelId == null) return;
    setState(() => isLoading = true);
    try {
      final hotel = await hotelService.getHotelById(widget.hotelId!);
      setState(() {
        name = hotel['name'] ?? '';
        address = hotel['address'] ?? '';
        phone = hotel['phone'] ?? '';
        description = hotel['description'] ?? '';
        // Si quieres cargar imagen ya guardada, aquí puedes implementarlo
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error al cargar hotel')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return Image.file(File(_imageFile!.path), height: 150);
    }
    return Container(
      height: 150,
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 100, color: Colors.grey),
    );
  }

  Future<void> _saveHotel() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isLoading = true);

    try {
      final hotelData = {
        "name": name,
        "address": address,
        "phone": phone,
        "description": description,
      };

      int? hotelId;

      if (widget.hotelId == null) {
        final createdHotel = await hotelService.createHotel(hotelData);
        //hotelId = createdHotel["id"];
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Hotel creado')));
      } else {
        await hotelService.updateHotel(widget.hotelId!, hotelData);
        hotelId = widget.hotelId!;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Hotel actualizado')));
      }

      // Subir imagen si se seleccionó
      if (_imageFile != null && hotelId != null) {
        await hotelService.uploadImage(hotelId, _imageFile!);
      }

      Navigator.pop(context, true); // Devuelve true para refrescar lista
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error al guardar hotel')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotelId == null ? 'Nuevo Hospedaje' : 'Editar Hospedaje'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Imagen'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: _buildImagePreview(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Ingrese el nombre' : null,
                onSaved: (value) => name = value ?? '',
              ),
              TextFormField(
                initialValue: address,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Ingrese la dirección' : null,
                onSaved: (value) => address = value ?? '',
              ),
              TextFormField(
                initialValue: phone,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                onSaved: (value) => phone = value ?? '',
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
                onSaved: (value) => description = value ?? '',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveHotel,
                child: Text(widget.hotelId == null ? 'Crear' : 'Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
