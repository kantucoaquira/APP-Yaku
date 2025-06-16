package com.example.backend.controller;

import com.example.backend.repository.ReservationRepository;
import com.example.backend.repository.UserRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class StatsController {

    private final UserRepository userRepository;
    private final ReservationRepository reservationRepository;

    public StatsController(UserRepository userRepository, ReservationRepository reservationRepository) {
        this.userRepository = userRepository;
        this.reservationRepository = reservationRepository;
    }

    @GetMapping("/stats")
    public Map<String, Object> getStats() {
        Map<String, Object> stats = new HashMap<>();

        long activeUsers = userRepository.count(); // Puedes filtrar si tienes campo activo
        long totalReservations = reservationRepository.count();

        double totalIncome = reservationRepository.findAll().stream()
                .mapToDouble(r -> {
                    if (r.getRoom() != null && r.getCheckIn() != null && r.getCheckOut() != null) {
                        long days = ChronoUnit.DAYS.between(r.getCheckIn(), r.getCheckOut());
                        return days * r.getRoom().getPrice();
                    }
                    return 0;
                }).sum();

        stats.put("activeUsers", activeUsers);
        stats.put("totalReservations", totalReservations);
        stats.put("totalIncome", totalIncome);

        return stats;
    }
}
