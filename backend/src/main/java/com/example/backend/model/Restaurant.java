package com.example.backend.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name="restaurants")
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
public class Restaurant {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String address;
    private String phone;
    private String description;
}
