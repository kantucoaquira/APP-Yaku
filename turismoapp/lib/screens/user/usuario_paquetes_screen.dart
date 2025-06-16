import 'package:flutter/material.dart';
import 'package:turismoapp/screens/admin/services/paquete_service.dart';
import 'user_drawer.dart';

class UsuarioPaqueteScreen extends StatefulWidget {
  @override
  _UsuarioPaqueteScreenState createState() => _UsuarioPaqueteScreenState();
}

class _UsuarioPaqueteScreenState extends State<UsuarioPaqueteScreen> {
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

  void _seleccionarPaquete(dynamic paquete) {
    // Aquí irías a la pantalla de reserva
    // Por ahora solo lo imprimimos
    print('Paquete seleccionado para reserva: ${paquete['nombre']}');
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (_) => ReservaPaquetePage(paquete: paquete),
    // ));
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
        onTap: () => _seleccionarPaquete(paquete),
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
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: UserDrawer(),
      appBar: AppBar(title: Text('Paquetes Disponibles')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadPaquetes,
        child: ListView.builder(
          itemCount: _paquetes.length,
          itemBuilder: (context, index) =>
              _buildPaqueteItem(_paquetes[index]),
        ),
      ),
    );
  }
}
