package com.example.backend.controller;

import com.example.backend.dto.HabitacionDTO;
import com.example.backend.model.Habitacion;
import com.example.backend.service.HabitacionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/habitaciones")
@CrossOrigin
public class HabitacionController {

    @Autowired
    private HabitacionService habitacionService;

    @GetMapping
    public List<Habitacion> listar() {
        return habitacionService.listar();
    }

    @PostMapping
    public ResponseEntity<Habitacion> guardar(@RequestBody HabitacionDTO dto) {
        Habitacion habitacion = habitacionService.guardar(dto);
        return ResponseEntity.ok(habitacion);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        habitacionService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
