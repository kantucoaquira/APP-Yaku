import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turismoapp/screens/superadmin/services/reservation_service.dart';

class ReservationEditScreen extends StatefulWidget {
  final int? reservationId; // null para nuevo, no null para editar

  const ReservationEditScreen({Key? key, this.reservationId}) : super(key: key);

  @override
  _ReservationEditScreenState createState() => _ReservationEditScreenState();
}

class _ReservationEditScreenState extends State<ReservationEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final reservationService = ReservationService();

  String roomType = '';
  int numberOfPeople = 1;
  DateTime? startDate;
  DateTime? endDate;
  String services = '';
  String code = '';
  double total = 0.0;

  XFile? _imageFile;

  bool isLoading = false;

  Future<void> _loadReservation() async {
    if (widget.reservationId == null) return;
    setState(() => isLoading = true);
    try {
      final reservation = await reservationService.getReservationById(widget.reservationId!);
      setState(() {
        roomType = reservation['roomType'] ?? '';
        numberOfPeople = reservation['numberOfPeople'] ?? 1;
        startDate = DateTime.parse(reservation['startDate']);
        endDate = DateTime.parse(reservation['endDate']);
        services = reservation['services'] ?? '';
        code = reservation['code'] ?? '';
        total = (reservation['total'] ?? 0).toDouble();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al cargar reserva')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime initialDate = isStart ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now().add(Duration(days: 1)));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (endDate != null && endDate!.isBefore(startDate!)) {
            endDate = startDate!.add(Duration(days: 1));
          }
        } else {
          endDate = picked;
          if (startDate != null && startDate!.isAfter(endDate!)) {
            startDate = endDate!.subtract(Duration(days: 1));
          }
        }
      });
    }
  }

  Future<void> _saveReservation() async {
    if (!_formKey.currentState!.validate()) return;

    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione fechas válidas')));
      return;
    }

    _formKey.currentState!.save();

    setState(() => isLoading = true);

    try {
      final reservationData = {
        "roomType": roomType,
        "numberOfPeople": numberOfPeople,
        "startDate": startDate!.toIso8601String(),
        "endDate": endDate!.toIso8601String(),
        "services": services,
        "code": code,
        "total": total,
      };

      int? reservationId;

      if (widget.reservationId == null) {
        final createdReservation = await reservationService.createReservation(reservationData);
        reservationId = createdReservation['id'];
      } else {
        await reservationService.updateReservation(widget.reservationId!, reservationData);
        reservationId = widget.reservationId!;
      }

      // Si quieres subir imagen, añade aquí lógica para subir _imageFile con reservationId

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al guardar reserva')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadReservation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reservationId == null ? 'Nueva Reserva' : 'Editar Reserva'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: roomType,
                decoration: const InputDecoration(labelText: 'Tipo de Habitación'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese el tipo de habitación' : null,
                onSaved: (value) => roomType = value ?? '',
              ),
              TextFormField(
                initialValue: numberOfPeople.toString(),
                decoration: const InputDecoration(labelText: 'Número de personas'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese número de personas';
                  if (int.tryParse(value) == null || int.parse(value) < 1) return 'Ingrese un número válido';
                  return null;
                },
                onSaved: (value) => numberOfPeople = int.parse(value ?? '1'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(startDate == null ? 'Fecha inicio' : 'Inicio: ${startDate!.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text(endDate == null ? 'Fecha fin' : 'Fin: ${endDate!.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              TextFormField(
                initialValue: services,
                decoration: const InputDecoration(labelText: 'Servicios'),
                maxLines: 2,
                onSaved: (value) => services = value ?? '',
              ),
              TextFormField(
                initialValue: code,
                decoration: const InputDecoration(labelText: 'Código'),
                onSaved: (value) => code = value ?? '',
              ),
              TextFormField(
                initialValue: total == 0 ? '' : total.toString(),
                decoration: const InputDecoration(labelText: 'Total (S/)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese el total';
                  if (double.tryParse(value) == null) return 'Ingrese un número válido';
                  return null;
                },
                onSaved: (value) => total = double.parse(value ?? '0'),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile != null
                    ? Image.file(File(_imageFile!.path), height: 150)
                    : Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 100, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveReservation,
                child: Text(widget.reservationId == null ? 'Crear' : 'Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
