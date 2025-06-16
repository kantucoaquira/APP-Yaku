import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turismoapp/screens/user/ReservationDetailScreen.dart';
import 'package:turismoapp/screens/user/user_home_screen.dart';
import 'services/reservation_service.dart';

class UserReservationScreen extends StatefulWidget {
  final String? clientId;
  final String? hotelId;
  final String? roomId;

  UserReservationScreen({this.clientId, this.hotelId, this.roomId});

  @override
  _UserReservationScreenState createState() => _UserReservationScreenState();
}

class _UserReservationScreenState extends State<UserReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ReservationService _reservationService = ReservationService();
  late TextEditingController _clientIdController;

  DateTime? _checkIn;
  DateTime? _checkOut;
  String? _clientId;
  String? _hotelId;
  String? _roomId;
  String? _restaurantId;

  bool _isLoading = false;
  String? _message;
  bool _hasActiveReservation = false;

  @override
  void initState() {
    super.initState();
    _clientIdController = TextEditingController();
    _hotelId = widget.hotelId;
    _roomId = widget.roomId;
    _loadClientIdIfNeeded();
  }

  Future<void> _loadClientIdIfNeeded() async {
    String? clientIdToUse;

    if (widget.clientId != null && widget.clientId!.isNotEmpty) {
      clientIdToUse = widget.clientId;
    } else {
      final prefs = await SharedPreferences.getInstance();
      clientIdToUse = prefs.getString('client_id');
    }

    if (clientIdToUse != null && clientIdToUse.isNotEmpty) {
      setState(() {
        _clientId = clientIdToUse;
        _clientIdController.text = clientIdToUse!;
      });
      await _checkActiveReservation();
    }
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    super.dispose();
  }

  Future<void> _checkActiveReservation() async {
    if (_clientId == null || _roomId == null) return;
    bool active = await _reservationService.hasActiveReservation(
      clientId: int.parse(_clientId!),
      roomId: int.parse(_roomId!),
    );
    setState(() {
      _hasActiveReservation = active;
    });
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;

    if (_checkIn == null || _checkOut == null) {
      setState(() {
        _message = "Por favor, selecciona fechas válidas";
      });
      return;
    }

    if (_checkOut!.isBefore(_checkIn!)) {
      setState(() {
        _message = "La fecha de Check-Out debe ser posterior a Check-In";
      });
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _message = null;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserHomeScreen()), // Reemplaza ConfirmationScreen por tu widget de confirmación
    );

    final reservationData = {
      "checkIn": _checkIn!.toIso8601String(),
      "checkOut": _checkOut!.toIso8601String(),
      "clientId": int.tryParse(_clientId ?? ""),
      "hotelId": int.tryParse(_hotelId ?? ""),
      "roomId": int.tryParse(_roomId ?? ""),
      "restaurantId": _restaurantId != null ? int.tryParse(_restaurantId!) : null,
    };

    final result = await _reservationService.createReservation(reservationData);

    setState(() {
      _isLoading = false;
    });

    if (result != null) {
      setState(() {
        _message = "Reserva creada exitosamente";
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ReservationDetailScreen(result)),
      );
    } else {
      setState(() {
        _message = "Error al crear la reserva";
      });
    }
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
        } else {
          _checkOut = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crear Reserva")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text(_checkIn == null
                    ? "Selecciona fecha de Check-In"
                    : "Check-In: ${_checkIn!.toLocal().toString().split(' ')[0]}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickDate(isCheckIn: true),
              ),
              ListTile(
                title: Text(_checkOut == null
                    ? "Selecciona fecha de Check-Out"
                    : "Check-Out: ${_checkOut!.toLocal().toString().split(' ')[0]}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickDate(isCheckIn: false),
              ),
              TextFormField(
                controller: _clientIdController,
                decoration: InputDecoration(labelText: "ID Cliente"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                (value == null || value.isEmpty) ? "Requerido" : null,
                onSaved: (value) => _clientId = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "ID Hotel"),
                keyboardType: TextInputType.number,
                initialValue: _hotelId,
                validator: (value) =>
                (value == null || value.isEmpty) ? "Requerido" : null,
                onSaved: (value) => _hotelId = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "ID Habitación"),
                keyboardType: TextInputType.number,
                initialValue: _roomId,
                validator: (value) =>
                (value == null || value.isEmpty) ? "Requerido" : null,
                onSaved: (value) => _roomId = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "ID Restaurante (Opcional)"),
                keyboardType: TextInputType.number,
                onSaved: (value) => _restaurantId = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: (_isLoading || _hasActiveReservation) ? null : _submitReservation,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(_hasActiveReservation ? "Reserva Activa" : "Generar Reserva"),
              ),
              if (_message != null) ...[
                SizedBox(height: 20),
                Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.toLowerCase().contains("error")
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
