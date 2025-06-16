package com.example.backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class Habitacion {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String numero;
    private String tipo;
    private Double precio;
    private String descripcion;
    private Boolean disponible;

    @ManyToOne
    @JoinColumn(name = "hotel_id")
    private Hotel hotel;
}