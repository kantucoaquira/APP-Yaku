package com.example.backend.controller;

import com.example.backend.dto.ReservationDTO;
import com.example.backend.model.*;
import com.example.backend.security.services.UserDetailsImpl;
import com.example.backend.service.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/reservations")
@RequiredArgsConstructor
public class ReservationController {

    private final ReservationService reservationService;
    private final ClientService clientService;
    private final HotelService hotelService;
    private final RestaurantService restaurantService;
    private final RoomService roomService;

    @GetMapping
    public ResponseEntity<List<ReservationDTO>> getAllReservations() {
        List<ReservationDTO> reservations = reservationService.findAll()
                .stream()
                .map(ReservationDTO::new)
                .collect(Collectors.toList());
        return ResponseEntity.ok(reservations);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ReservationDTO> getReservationById(@PathVariable Long id) {
        Optional<Reservation> reservationOpt = reservationService.findById(id);
        if (reservationOpt.isPresent()) {
            ReservationDTO dto = new ReservationDTO(reservationOpt.get());
            return ResponseEntity.ok(dto);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    @GetMapping("/my")
    public ResponseEntity<List<ReservationDTO>> getMyReservations(Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        Long userId = userDetails.getId();

        // Suponiendo que tienes un método en ClientService
        Optional<Client> clientOpt = clientService.findByUserId(userId);

        if (clientOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(null);
        }

        Client client = clientOpt.get();
        List<Reservation> reservations = reservationService.findByClient(client);

        List<ReservationDTO> dtos = reservations.stream()
                .map(ReservationDTO::new)
                .collect(Collectors.toList());

        return ResponseEntity.ok(dtos);
    }


    @PostMapping
    public ResponseEntity<?> createReservation(@RequestBody ReservationDTO dto) {

        // Convertir DTO a entidad (con IDs cargados)
        Reservation reservation = dto.toEntity();

        Optional<Client> clientOpt = clientService.findById(dto.getClientId());
        if (clientOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Cliente no encontrado");
        }
        reservation.setClient(clientOpt.get());

        Optional<Hotel> hotelOpt = hotelService.findById(dto.getHotelId());
        if (hotelOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Hotel no encontrado");
        }
        Hotel hotel = hotelOpt.get();
        reservation.setHotel(hotel);

        if (dto.getRestaurantId() != null) {
            Optional<Restaurant> restaurantOpt = restaurantService.findById(dto.getRestaurantId());
            if (restaurantOpt.isEmpty()) {
                return ResponseEntity.badRequest().body("Restaurante no encontrado");
            }
            reservation.setRestaurant(restaurantOpt.get());
        }

        Optional<Room> roomOpt = roomService.findById(dto.getRoomId());
        if (roomOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Habitación no encontrada");
        }
        Room room = roomOpt.get();

        if (!room.getAvailability().equals(Availability.DISPONIBLE)) {
            return ResponseEntity.badRequest().body("La habitación no está disponible.");
        }

        if (!room.getHotel().getId().equals(hotel.getId())) {
            return ResponseEntity.badRequest().body("La habitación no pertenece al hotel seleccionado.");
        }

        // Cambiar disponibilidad
        room.setAvailability(Availability.OCUPADO);
        roomService.save(room);
        reservation.setRoom(room);

        reservation.setStatus("PENDIENTE"); // Estado inicial por defecto

        Reservation saved = reservationService.save(reservation);
        return ResponseEntity.ok(new ReservationDTO(saved));
    }


    @PutMapping("/{id}/cancel")
    public ResponseEntity<?> cancelReservation(@PathVariable Long id) {
        Optional<Reservation> reservationOpt = reservationService.findById(id);

        if (reservationOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Reservation reservation = reservationOpt.get();

        if ("CANCELADA".equalsIgnoreCase(reservation.getStatus())) {
            return ResponseEntity.badRequest().body("La reserva ya está cancelada.");
        }

        // Cambiar estado
        reservation.setStatus("CANCELADA");

        // Liberar habitación
        Room room = reservation.getRoom();
        if (room != null && room.getAvailability() == Availability.OCUPADO) {
            room.setAvailability(Availability.DISPONIBLE);
            roomService.save(room);
        }

        reservation.setRoom(room);
        Reservation updated = reservationService.save(reservation);

        return ResponseEntity.ok(new ReservationDTO(updated));
    }

}
