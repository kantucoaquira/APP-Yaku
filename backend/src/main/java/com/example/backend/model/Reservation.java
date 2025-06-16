package com.example.backend.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "reservations")
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
public class Reservation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private LocalDate checkIn;
    private LocalDate checkOut;

    private String status; // PENDIENTE, CONFIRMADA, CANCELADA

    @ManyToOne
    @JoinColumn(name = "client_id", nullable = false)
    private Client client;

    @ManyToOne
    @JoinColumn(name = "hotel_id", nullable = false)
    private Hotel hotel; // Incluido explícitamente

    @ManyToOne
    @JoinColumn(name = "restaurant_id") // Opcional
    private Restaurant restaurant;

    @ManyToOne
    @JoinColumn(name = "room_id", nullable = false)
    private Room room;

    public void reserveRoom() {
        if (room != null) {
            room.setAvailability(Availability.OCUPADO);
        }
    }

    public void releaseRoom() {
        if (room != null) {
            room.setAvailability(Availability.DISPONIBLE);
        }
    }
}
