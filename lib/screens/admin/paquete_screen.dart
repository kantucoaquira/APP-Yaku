import 'package:flutter/material.dart';
import 'package:turismoapp/screens/admin/admin_drawer.dart';
import 'package:turismoapp/screens/admin/services/paquete_service.dart';
import 'crear_paquete_page.dart';

class PaqueteScreen extends StatefulWidget {
  @override
  _PaqueteScreenState createState() => _PaqueteScreenState();
}

class _PaqueteScreenState extends State<PaqueteScreen> {
  List<dynamic> _paquetes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaquetes();
  }

  Future<void> _loadPaquetes() async {
    try {
      final data = await PaqueteService().getPaquetes();
      setState(() {
        _paquetes = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar paquetes: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _eliminarPaquete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar paquete'),
        content: Text('¿Estás seguro de que deseas eliminar este paquete?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Eliminar')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await PaqueteService().deletePaquete(id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Paquete eliminado')));
        _loadPaquetes();
      } catch (e) {
        print('Error al eliminar paquete: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar paquete')));
      }
    }
  }

  Widget _buildPaqueteItem(dynamic paquete) {
    final nombre = paquete['nombre'] ?? 'Sin nombre';

    final precioOriginal = paquete['precioOriginal']?.toString() ?? '-';
    final precioConDescuento = paquete['precioConDescuento']?.toString() ?? '-';

    final menus = (paquete['menus'] as List<dynamic>?)
        ?.map((m) => m['name'] ?? 'Sin nombre')
        .join(', ') ??
        'Sin menús';

    final rooms = (paquete['rooms'] as List<dynamic>?)
        ?.map((r) => r['name'] ?? 'Sin nombre')
        .join(', ') ??
        'Sin habitaciones';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        title: Text(nombre, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('Menús: $menus'),
            Text('Habitaciones: $rooms'),
            Text('Precio Original: \$${precioOriginal}'),
            Text('Precio con Descuento: \$${precioConDescuento}'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _eliminarPaquete(paquete['id']),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(),
      appBar: AppBar(title: Text('Paquetes')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadPaquetes,
        child: ListView.builder(
          itemCount: _paquetes.length,
          itemBuilder: (context, index) => _buildPaqueteItem(_paquetes[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CrearPaquetePage()),
          );
          _loadPaquetes();
        },
        child: Icon(Icons.add),
        tooltip: 'Crear Paquete',
      ),
    );
  }
}
