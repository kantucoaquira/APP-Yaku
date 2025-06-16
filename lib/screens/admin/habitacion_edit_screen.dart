import 'package:flutter/material.dart';
import 'services/habitacion_service.dart';
import 'services/hotel_service.dart';

class HabitacionEditScreen extends StatefulWidget {
  final int? habitacionId;

  const HabitacionEditScreen({Key? key, this.habitacionId}) : super(key: key);

  @override
  _HabitacionEditScreenState createState() => _HabitacionEditScreenState();
}

class _HabitacionEditScreenState extends State<HabitacionEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final habitacionService = HabitacionService();
  final hotelService = HotelService();

  // Ahora usamos TextEditingController para mejor control de inputs
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  bool disponible = true;
  int? hotelIdSeleccionado;
  List<dynamic> hoteles = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarHoteles();
    if (widget.habitacionId != null) {
      _cargarHabitacion();
    }
  }

  Future<void> _cargarHoteles() async {
    try {
      hoteles = await hotelService.getHotels();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al cargar hoteles')));
    }
  }

  Future<void> _cargarHabitacion() async {
    setState(() => isLoading = true);
    try {
      final hab = await habitacionService.getHabitacionById(widget.habitacionId!);
      setState(() {
        _numeroController.text = hab['numero'] ?? '';
        _tipoController.text = hab['tipo'] ?? '';
        _precioController.text = hab['precio']?.toString() ?? '0';
        _descripcionController.text = hab['descripcion'] ?? '';
        disponible = hab['disponible'] ?? true;
        hotelIdSeleccionado = hab['hotel']['id'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al cargar habitación')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _guardarHabitacion() async {
    if (!_formKey.currentState!.validate() || hotelIdSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos requeridos')),
      );
      return;
    }

    setState(() => isLoading = true);

    final data = {
      "numero": _numeroController.text,
      "tipo": _tipoController.text,
      "precio": double.tryParse(_precioController.text) ?? 0,
      "descripcion": _descripcionController.text,
      "disponible": disponible,
      "hotelId": hotelIdSeleccionado,
    };

    try {
      if (widget.habitacionId == null) {
        await habitacionService.createHabitacion(data);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Habitación creada')));
      } else {
        await habitacionService.updateHabitacion(widget.habitacionId!, data);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Habitación actualizada')));
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al guardar habitación')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: validator ??
                (value) => (value == null || value.isEmpty) ? 'Campo obligatorio' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habitacionId == null ? 'Nueva Habitación' : 'Editar Habitación'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _numeroController,
                    label: 'Número',
                  ),
                  _buildTextField(
                    controller: _tipoController,
                    label: 'Tipo',
                  ),
                  _buildTextField(
                    controller: _precioController,
                    label: 'Precio',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Campo obligatorio';
                      final n = double.tryParse(value);
                      if (n == null || n <= 0) return 'Precio inválido';
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _descripcionController,
                    label: 'Descripción',
                    maxLines: 3,
                  ),
                  DropdownButtonFormField<int>(
                    value: hotelIdSeleccionado,
                    decoration: InputDecoration(
                      labelText: 'Hotel',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: hoteles.map((hotel) {
                      return DropdownMenuItem<int>(
                        value: hotel['id'],
                        child: Text(hotel['name']),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() {
                      hotelIdSeleccionado = value;
                    }),
                    validator: (value) =>
                    value == null ? 'Seleccione un hotel' : null,
                  ),
                  SwitchListTile(
                    title: Text('Disponible'),
                    value: disponible,
                    onChanged: (value) => setState(() {
                      disponible = value;
                    }),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _guardarHabitacion,
                    icon: Icon(Icons.save),
                    label: Text(widget.habitacionId == null ? 'Crear' : 'Actualizar'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      textStyle: TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
