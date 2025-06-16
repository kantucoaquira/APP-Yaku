package com.example.backend.dto;

import com.example.backend.model.Menu;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MenuDTO {

    private Long id;
    private String name;
    private String description;
    private Double price;
    private String imageUrl;

    // Si quieres filtrar por usuario, podrías agregar un campo userId o similar
    private Long userId;

    // Constructor que convierte de entidad a DTO
    public MenuDTO(Menu menu) {
        this.id = menu.getId();
        this.name = menu.getName();
        this.description = menu.getDescription();
        this.price = menu.getPrice();
        this.imageUrl = menu.getImageUrl();

        // Asumiendo que el menú tiene una relación con usuario (o restaurante)
        if (menu.getUser() != null) {
            this.userId = menu.getUser().getId();
        }
    }
}
