import 'package:flutter/material.dart';
import 'package:turismoapp/screens/admin/services/menu_service.dart';
import 'package:turismoapp/screens/admin/services/paquete_service.dart';
import 'package:turismoapp/screens/admin/services/room_service.dart';

class CrearPaquetePage extends StatefulWidget {
  @override
  _CrearPaquetePageState createState() => _CrearPaquetePageState();
}

class _CrearPaquetePageState extends State<CrearPaquetePage> {
  final _nombreController = TextEditingController();
  List<dynamic> _menus = [];
  List<dynamic> _rooms = [];
  List<int> _selectedMenuIds = [];
  List<int> _selectedRoomIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMenusAndRooms();
  }

  Future<void> _fetchMenusAndRooms() async {
    try {
      final menus = await MenuService().getMyMenus();
      final rooms = await RoomService().getMyRooms();
      setState(() {
        _menus = menus;
        _rooms = rooms;
      });
    } catch (e) {
      print('Error al cargar menús o habitaciones: $e');
    }
  }

  Future<void> _crearPaquete() async {
    setState(() => _isLoading = true);

    final data = {
      "nombre": _nombreController.text,
      "menuIds": _selectedMenuIds,
      "roomIds": _selectedRoomIds,
    };

    try {
      await PaqueteService().createPaquete(data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Paquete creado')));
      Navigator.pop(context);
    } catch (e) {
      print('Error al crear paquete: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al crear paquete')));
    }

    setState(() => _isLoading = false);
  }

  Widget _buildCheckboxList(List<dynamic> items, List<int> selectedIds, String labelKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map<Widget>((item) {
        final id = item['id'];
        final textoMostrar = item[labelKey]?.toString() ?? 'Sin nombre';

        return CheckboxListTile(
          title: Text(textoMostrar),
          value: selectedIds.contains(id),
          onChanged: (bool? selected) {
            setState(() {
              if (selected == true) {
                selectedIds.add(id);
              } else {
                selectedIds.remove(id);
              }
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Paquete')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Seleccionar Menús', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            _buildCheckboxList(_menus, _selectedMenuIds, 'name'),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Seleccionar Habitaciones', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            _buildCheckboxList(_rooms, _selectedRoomIds, 'name'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _crearPaquete,
              child: Text('Crear Paquete'),
            ),
          ],
        ),
      ),
    );
  }
}
