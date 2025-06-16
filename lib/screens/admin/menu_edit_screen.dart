import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turismoapp/screens/admin/services/menu_service.dart';
import 'package:turismoapp/screens/superadmin/services/restaurant_service.dart';

class MenuEditScreen extends StatefulWidget {
  final int? menuId;
  const MenuEditScreen({Key? key, this.menuId}) : super(key: key);

  @override
  State<MenuEditScreen> createState() => _MenuEditScreenState();
}

class _MenuEditScreenState extends State<MenuEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final menuService = MenuService();
  final restaurantService = RestaurantService();

  // Controladores para los campos de texto
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;

  int? selectedRestaurantId;
  List<dynamic> restaurants = [];
  XFile? _imageFile;
  String? _imageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Inicializa los controladores vacíos
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    priceController = TextEditingController();

    _loadRestaurants().then((_) => _loadMenuData());
  }

  @override
  void dispose() {
    // Libera los controladores
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurants() async {
    try {
      final data = await restaurantService.getRestaurants();
      setState(() => restaurants = data);
    } catch (e) {
      print('Error al cargar restaurantes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar restaurantes: $e')),
      );
    }
  }

  Future<void> _loadMenuData() async {
    if (widget.menuId != null) {
      try {
        final menu = await menuService.getMenuById(widget.menuId!);
        print('Menú recibido: $menu');

        setState(() {
          nameController.text = menu['name'] ?? '';
          descriptionController.text = menu['description'] ?? '';
          priceController.text = (menu['price'] ?? 0).toString();
          selectedRestaurantId = menu['restaurant'] != null ? menu['restaurant']['id'] : null;

          if (menu['imageUrl'] != null && (menu['imageUrl'] as String).isNotEmpty) {
            _imageUrl = menu['imageUrl'];
          } else {
            _imageUrl = null;
          }
        });
      } catch (e) {
        print('Error en _loadMenuData: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos del menú')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = picked;
        _imageUrl = null;
      });
    }
  }

  Future<void> _saveMenu() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final menuData = {
        "name": nameController.text,
        "description": descriptionController.text,
        "price": double.tryParse(priceController.text) ?? 0,
        "restaurant": {
          "id": selectedRestaurantId
        }
      };

      int? menuId;

      if (widget.menuId == null) {
        final created = await menuService.createMenu(menuData);
        menuId = created['id'];
      } else {
        print('Datos a enviar: $menuData');
        await menuService.updateMenu(widget.menuId!, menuData);
        menuId = widget.menuId!;
      }

      if (_imageFile != null && menuId != null) {
        await menuService.uploadImage(menuId, _imageFile!);
      }

      Navigator.pop(context, true);
    } catch (e, stacktrace) {
      print('Error al guardar menú: $e');
      print(stacktrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar menú: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuId == null ? 'Nuevo Menú' : 'Editar Menú'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                    image: _imageFile != null
                        ? DecorationImage(
                      image: FileImage(File(_imageFile!.path)),
                      fit: BoxFit.cover,
                    )
                        : (_imageUrl != null
                        ? DecorationImage(
                      image: NetworkImage(_imageUrl!),
                      fit: BoxFit.cover,
                    )
                        : null),
                  ),
                  child: (_imageFile == null && _imageUrl == null)
                      ? Icon(Icons.image, size: 80, color: Colors.grey[700])
                      : null,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.fastfood),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Ingrese un nombre' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Precio',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value == null ||
                    double.tryParse(value) == null
                    ? 'Ingrese un precio válido'
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedRestaurantId,
                decoration: InputDecoration(
                  labelText: 'Restaurante',
                  prefixIcon: Icon(Icons.restaurant),
                  border: OutlineInputBorder(),
                ),
                items: restaurants.map<DropdownMenuItem<int>>((restaurant) {
                  return DropdownMenuItem<int>(
                    value: restaurant['id'],
                    child: Text(restaurant['name']),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => selectedRestaurantId = value),
                validator: (value) =>
                value == null ? 'Seleccione un restaurante' : null,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveMenu,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(widget.menuId == null ? 'Crear' : 'Actualizar',
                    style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
