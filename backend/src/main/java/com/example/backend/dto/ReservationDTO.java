package com.example.backend.dto;

import com.example.backend.model.Reservation;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data // Genera getters, setters, toString, equals, hashCode
@NoArgsConstructor
@AllArgsConstructor
public class ReservationDTO {

    private Long id;

    private LocalDate checkIn;
    private LocalDate checkOut;

    private String status;

    private Long clientId;
    private String clientName; // Opcional, para mostrar en frontend

    private Long hotelId;
    private String hotelName;

    private Long restaurantId;
    private String restaurantName;

    private Long roomId;
    private String roomName;

    // Constructor desde Reservation
    public ReservationDTO(Reservation reservation) {
        this.id = reservation.getId();
        this.checkIn = reservation.getCheckIn();
        this.checkOut = reservation.getCheckOut();
        this.status = reservation.getStatus();

        if (reservation.getClient() != null) {
            this.clientId = reservation.getClient().getId();
            this.clientName = reservation.getClient().getName(); // Suponiendo que Client tiene getName()
        }

        if (reservation.getHotel() != null) {
            this.hotelId = reservation.getHotel().getId();
            this.hotelName = reservation.getHotel().getName();
        }

        if (reservation.getRestaurant() != null) {
            this.restaurantId = reservation.getRestaurant().getId();
            this.restaurantName = reservation.getRestaurant().getName();
        }

        if (reservation.getRoom() != null) {
            this.roomId = reservation.getRoom().getId();
            this.roomName = reservation.getRoom().getName(); // Suponiendo que Room tiene getName()
        }
    }
}
