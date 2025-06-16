package com.example.backend.dto;

import com.example.backend.model.Restaurant;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RestaurantDTO {

    private Long id;
    private String name;
    private String address;
    private String phone;
    private String description;
    private String imageUrl;

    // Constructor
    public RestaurantDTO(Restaurant restaurant) {
        this.id = restaurant.getId();
        this.name = restaurant.getName();
        this.address = restaurant.getAddress();
        this.phone = restaurant.getPhone();
        this.description = restaurant.getDescription();
        this.imageUrl = restaurant.getImageUrl();
    }
}
