package com.example.backend.dto;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class CartDTO {
    private Long id;
    private Long clientId;
    private List<CartItemDTO> items;
    private Double total;
    private String status;
    private LocalDateTime createdAt;
}