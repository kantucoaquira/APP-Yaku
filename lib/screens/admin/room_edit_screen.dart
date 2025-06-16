import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/room_service.dart';
import 'services/hotel_service.dart';

class RoomEditScreen extends StatefulWidget {
  final int? roomId;

  const RoomEditScreen({Key? key, this.roomId}) : super(key: key);

  @override
  _RoomEditScreenState createState() => _RoomEditScreenState();
}

class _RoomEditScreenState extends State<RoomEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final roomService = RoomService();
  final hotelService = HotelService();

  String name = '';
  String description = '';
  double? price;
  int? capacity;
  int? selectedHotelId;

  bool isLoading = false;
  XFile? _imageFile;
  String? _imageUrl; // <-- Aquí guardamos la URL de la imagen del servidor

  List<dynamic> hotels = [];

  @override
  void initState() {
    super.initState();
    _loadHotels();
    if (widget.roomId != null) {
      _loadRoom();
    }
  }

  Future<void> _loadHotels() async {
    try {
      final data = await hotelService.getHotels();
      setState(() {
        hotels = data;
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar hoteles')),
      );
    }
  }

  Future<void> _loadRoom() async {
    setState(() => isLoading = true);
    try {
      final room = await roomService.getRoomById(widget.roomId!);
      setState(() {
        name = room['name'] ?? '';
        description = room['description'] ?? '';
        price = (room['price'] != null) ? (room['price'] as num).toDouble() : null;
        capacity = room['capacity'];
        selectedHotelId = room['hotelId'];
        _imageUrl = room['imageUrl']; // <-- asignamos la URL recibida
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar habitación')),
      );
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
        _imageUrl = null; // Limpiamos la URL si selecciona nueva imagen local
      });
    }
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (selectedHotelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Seleccione un hotel')));
      return;
    }

    setState(() => isLoading = true);
    try {
      final roomData = {
        "name": name,
        "price": price,
        "capacity": capacity,
        "description": description,
        "hotel": {
          "id": selectedHotelId,
        },
      };
      if (_imageFile == null && _imageUrl != null) {
        roomData['imageUrl'] = _imageUrl;
      }

      int roomId;
      if (widget.roomId == null) {
        roomId = await roomService.createRoom(roomData); // obtener el ID nuevo
      } else {
        await roomService.updateRoom(widget.roomId!, roomData);
        roomId = widget.roomId!;
      }

      if (_imageFile != null) {
        await roomService.uploadImage(roomId, _imageFile!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                widget.roomId == null ? 'Habitación creada' : 'Habitación actualizada')),
      );
      Navigator.pop(context, true);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar habitación')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      // Imagen seleccionada localmente
      return Image.file(File(_imageFile!.path), height: 150, fit: BoxFit.cover);
    } else if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      // Mostrar imagen desde URL (servidor)
      return Image.network(_imageUrl!, height: 150, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 150,
          color: Colors.grey[300],
          child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
        ),
      );
    }
    // No hay imagen
    return Container(
      height: 150,
      color: Colors.grey[300],
      child: Icon(Icons.image, size: 100, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF93e5d2),
        title: Text(widget.roomId == null ? 'Nueva Habitación' : 'Editar Habitación'),
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
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: _buildImagePreview(),
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.meeting_room,color: Colors.brown,),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese nombre' : null,
                onSaved: (v) => name = v ?? '',
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: description,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.description,color: Colors.blue,),
                ),
                maxLines: 3,
                onSaved: (v) => description = v ?? '',
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: price?.toString(),
                decoration: InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.attach_money,color: Colors.green,),
                ),
                keyboardType:
                TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingrese precio';
                  if (double.tryParse(v) == null) return 'Debe ser un número válido';
                  return null;
                },
                onSaved: (v) => price = double.tryParse(v ?? ''),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: capacity?.toString(),
                decoration: InputDecoration(
                  labelText: 'Capacidad',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.people,color: Colors.orange,),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingrese capacidad';
                  if (int.tryParse(v) == null)
                    return 'Debe ser un número entero válido';
                  return null;
                },
                onSaved: (v) => capacity = int.tryParse(v ?? ''),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedHotelId,
                decoration: InputDecoration(
                  labelText: 'Hotel',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.hotel,color: Colors.purple,),
                ),
                items: hotels
                    .map(
                      (hotel) => DropdownMenuItem<int>(
                    value: hotel['id'],
                    child: Text(hotel['name'] ?? 'Hotel sin nombre'),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedHotelId = value;
                  });
                },
                validator: (v) => v == null ? 'Seleccione un hotel' : null,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2ae5a6),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: Text(
                  widget.roomId == null ? 'Crear' : 'Actualizar',
                  style: TextStyle(fontSize: 18,color: Colors.black),

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
