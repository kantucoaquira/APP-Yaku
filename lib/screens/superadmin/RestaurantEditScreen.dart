import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turismoapp/screens/superadmin/services/restaurant_service.dart';

class RestaurantEditScreen extends StatefulWidget {
  final int? restaurantId;

  const RestaurantEditScreen({Key? key, this.restaurantId}) : super(key: key);

  @override
  _RestaurantEditScreenState createState() => _RestaurantEditScreenState();
}

class _RestaurantEditScreenState extends State<RestaurantEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final restaurantService = RestaurantService();

  String name = '';
  String address = '';
  String description = '';
  XFile? _imageFile;
  bool isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _saveRestaurant() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isLoading = true);

    try {
      final restaurantData = {
        "name": name,
        "address": address,
        "description": description,
      };

      int? restaurantId;

      if (widget.restaurantId == null) {
        final createdRestaurant = await restaurantService.createRestaurant(restaurantData);
        restaurantId = createdRestaurant['id'];
      } else {
        await restaurantService.updateRestaurant(widget.restaurantId!, restaurantData);
        restaurantId = widget.restaurantId!;
      }

      if (_imageFile != null && restaurantId != null) {
        await restaurantService.uploadImage(restaurantId, _imageFile!);
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar restaurante: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurantId == null ? 'Nuevo Restaurante' : 'Editar Restaurante'),
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
              Text(
                'Imagen',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                    image: _imageFile != null
                        ? DecorationImage(
                      image: FileImage(File(_imageFile!.path)),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: _imageFile == null
                      ? Center(
                    child: Icon(Icons.image, size: 80, color: Colors.grey[600]),
                  )
                      : null,
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.restaurant),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Ingresa un nombre' : null,
                onSaved: (value) => name = value ?? '',
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: address,
                decoration: InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Ingresa una dirección' : null,
                onSaved: (value) => address = value ?? '',
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: description,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                onSaved: (value) => description = value ?? '',
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveRestaurant,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: Text(
                  widget.restaurantId == null ? 'Crear' : 'Actualizar',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
