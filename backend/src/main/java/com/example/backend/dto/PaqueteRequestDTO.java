package com.example.backend.dto;

import lombok.Data;

import java.util.List;

@Data
public class PaqueteRequestDTO {
    private String nombre;
    private double precioOriginal;
    private double precioConDescuento;
    private List<Long> menuIds;
    private List<Long> roomIds;
}
