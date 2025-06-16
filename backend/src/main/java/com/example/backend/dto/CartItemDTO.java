package com.example.backend.dto;

import lombok.Data;

@Data
public class CartItemDTO {
    private Long menuId; // puede ser null si es room
    private Long roomId; // puede ser null si es menu
    private int quantity;
}