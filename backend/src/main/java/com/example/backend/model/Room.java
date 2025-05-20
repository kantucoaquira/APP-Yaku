package com.example.backend.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name="rooms")
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
public class Room {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String number; // número habitación
    private String type; // simple, doble, suite, etc.
    private Double price;
    private boolean available;

    @ManyToOne
    @JoinColumn(name = "hotel_id")
    private Hotel hotel;
}
