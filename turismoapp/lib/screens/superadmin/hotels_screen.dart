import 'package:flutter/material.dart';
import 'hotel_edit_screen.dart';
import 'services/hotel_service.dart';

class HotelsScreen extends StatefulWidget {
  @override
  _HotelsScreenState createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  final hotelService = HotelService();

  List<dynamic> hotels = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchHotels() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await hotelService.getHotels();
      setState(() {
        hotels = data;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar hoteles';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteHotel(int id) async {
    try {
      await hotelService.deleteHotel(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hotel eliminado')),
      );
      fetchHotels();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar hotel')),
      );
    }
  }

  void _navigateToEdit(int? hotelId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HotelEditScreen(hotelId: hotelId)),
    );
    if (result == true) {
      fetchHotels();
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Filtro'),
        content: Text('Funcionalidad de filtro próximamente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cerrar'))
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Exportar'),
        content: Text('Funcionalidad de exportación próximamente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cerrar'))
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchHotels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Hospedajes'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _showExportDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : hotels.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "No hay hospedajes disponibles",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh),
              label: Text('Recargar'),
              onPressed: fetchHotels,
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Agregar nuevo hospedaje'),
              onPressed: () => _navigateToEdit(null),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          final hotel = hotels[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            key: ValueKey(hotel['id']),
            child: ListTile(
              leading: (hotel['imageUrl'] != null && hotel['imageUrl'].isNotEmpty)
                  ? Image.network(
                hotel['imageUrl'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
                  : Icon(Icons.hotel, size: 60),
              title: Text(hotel['name'] ?? 'Nombre no disponible'),
              subtitle: Text(hotel['address'] ?? 'Dirección no disponible'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'editar') {
                    _navigateToEdit(hotel['id']);
                  } else if (value == 'eliminar') {
                    _deleteHotel(hotel['id']);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'editar', child: Text('Editar')),
                  PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(null),
        child: Icon(Icons.add),
        tooltip: 'Agregar nuevo hospedaje',
      ),
    );
  }
}
