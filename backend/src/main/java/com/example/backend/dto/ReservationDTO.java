package com.example.backend.dto;

import com.example.backend.model.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReservationDTO {

    private Long id;

    private LocalDate checkIn;
    private LocalDate checkOut;

    private String status;

    private Long clientId;
    private String clientName;

    private Long hotelId;
    private String hotelName;

    private Long restaurantId;
    private String restaurantName;

    private Long roomId;
    private String roomName;
    private String roomAvailability;

    // Constructor desde entidad Reservation
    public ReservationDTO(Reservation reservation) {
        this.id = reservation.getId();
        this.checkIn = reservation.getCheckIn();
        this.checkOut = reservation.getCheckOut();
        this.status = reservation.getStatus();

        if (reservation.getClient() != null) {
            this.clientId = reservation.getClient().getId();
            this.clientName = reservation.getClient().getName();
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
            this.roomName = reservation.getRoom().getName();
            this.roomAvailability = reservation.getRoom().getAvailability().name(); // DISPONIBLE u OCUPADO
        }
    }

    // Conversión inversa: de DTO a entidad Reservation
    public Reservation toEntity() {
        Reservation reservation = new Reservation();
        reservation.setId(this.id);
        reservation.setCheckIn(this.checkIn);
        reservation.setCheckOut(this.checkOut);
        reservation.setStatus(this.status);

        // Asociaciones con solo IDs (los objetos reales se cargan en el servicio)
        if (this.clientId != null) {
            Client client = new Client();
            client.setId(this.clientId);
            reservation.setClient(client);
        }

        if (this.hotelId != null) {
            Hotel hotel = new Hotel();
            hotel.setId(this.hotelId);
            reservation.setHotel(hotel);
        }

        if (this.restaurantId != null) {
            Restaurant restaurant = new Restaurant();
            restaurant.setId(this.restaurantId);
            reservation.setRestaurant(restaurant);
        }

        if (this.roomId != null) {
            Room room = new Room();
            room.setId(this.roomId);
            reservation.setRoom(room);
        }

        return reservation;
    }
}
