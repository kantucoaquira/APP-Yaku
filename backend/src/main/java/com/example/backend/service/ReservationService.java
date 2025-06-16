package com.example.backend.service;

import com.example.backend.model.Client;
import com.example.backend.model.Reservation;
import com.example.backend.repository.ReservationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ReservationService {

    private final ReservationRepository reservationRepository;

    public List<Reservation> findAll() {
        return reservationRepository.findAll();
    }

    public Optional<Reservation> findById(Long id) {
        return reservationRepository.findById(id);
    }

    public Reservation save(Reservation reservation) {
        return reservationRepository.save(reservation);
    }

    public void delete(Long id) {
        reservationRepository.deleteById(id);
    }

    public Reservation update(Reservation reservation) {
        // Aquí puedes hacer lógica adicional si quieres
        return reservationRepository.save(reservation);
    }
    public List<Reservation> findByClient(Client client) {
        return reservationRepository.findByClient(client);
    }
}
