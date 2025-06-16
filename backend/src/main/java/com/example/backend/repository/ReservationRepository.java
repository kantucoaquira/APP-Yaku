package com.example.backend.repository;

import com.example.backend.model.Client;
import com.example.backend.model.Reservation;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReservationRepository extends JpaRepository<Reservation, Long> {
    List<Reservation> findByClient(Client client);

}
