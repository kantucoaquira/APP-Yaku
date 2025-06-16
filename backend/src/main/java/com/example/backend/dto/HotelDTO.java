package com.example.backend.dto;

import com.example.backend.model.Hotel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data // Genera getters, setters, toString, equals, hashCode
@NoArgsConstructor
@AllArgsConstructor
public class HotelDTO {
    private Long id;
    private String name;
    private String address;
    private String imageUrl; // Descomenta si lo usas

    // Constructor desde Hotel
    public HotelDTO(Hotel hotel) {
        this.id = hotel.getId();
        this.name = hotel.getName();
        this.address = hotel.getAddress();
        this.imageUrl = hotel.getImageUrl(); // Asegúrate que exista en tu modelo
    }
}