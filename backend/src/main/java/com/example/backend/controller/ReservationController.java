package com.example.backend.controller;

import com.example.backend.dto.ReservationDTO;
import com.example.backend.model.Reservation;
import com.example.backend.service.ReservationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reservations")
@RequiredArgsConstructor
public class ReservationController {

    private final ReservationService reservationService;

    @GetMapping
    public List<ReservationDTO> list() {
        return reservationService.findAll().stream()
                .map(ReservationDTO::new)
                .toList();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ReservationDTO> get(@PathVariable Long id) {
        return reservationService.findById(id)
                .map(reservation -> ResponseEntity.ok(new ReservationDTO(reservation)))
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<ReservationDTO> create(@RequestBody Reservation reservation) {
        Reservation created = reservationService.save(reservation);
        return ResponseEntity.status(201).body(new ReservationDTO(created));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ReservationDTO> update(@PathVariable Long id, @RequestBody Reservation reservation) {
        reservation.setId(id);
        Reservation updated = reservationService.save(reservation);
        return ResponseEntity.ok(new ReservationDTO(updated));
    }


    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        reservationService.delete(id);
    }
}
