package com.example.backend.repository;

import com.example.backend.model.Habitacion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface HabitacionRepository extends JpaRepository<Habitacion, Long> {
    List<Habitacion> findByHotelId(Long hotelId);
}
