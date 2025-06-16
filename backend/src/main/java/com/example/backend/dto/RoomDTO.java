package com.example.backend.dto;

import com.example.backend.model.Room;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RoomDTO {

    private Long id;
    private String name;
    private Double price;
    private Integer capacity;
    private String description;
    private String imageUrl;
    private Long hotelId;
    private String hotelName;      // <--- agregar este campo
    private String availability;

    public RoomDTO(Room room) {
        this.id = room.getId();
        this.name = room.getName();
        this.price = room.getPrice();
        this.capacity = room.getCapacity();
        this.description = room.getDescription();
        this.imageUrl = room.getImageUrl();
        this.hotelId = room.getHotel() != null ? room.getHotel().getId() : null;
        this.hotelName = room.getHotel() != null ? room.getHotel().getName() : null;  // <--- asignar nombre hotel
        this.availability = room.getAvailability() != null ? room.getAvailability().name() : null;
    }
}
