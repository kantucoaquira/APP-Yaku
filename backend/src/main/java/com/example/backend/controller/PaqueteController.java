package com.example.backend.controller;

import com.example.backend.dto.PaqueteDTO;
import com.example.backend.dto.PaqueteRequestDTO;
import com.example.backend.service.PaqueteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/paquetes")
@CrossOrigin(origins = "*")
public class PaqueteController {

    @Autowired
    private PaqueteService paqueteService;

    @GetMapping
    public List<PaqueteDTO> listarTodos() {
        return paqueteService.listarTodos();
    }

    @PostMapping
    public PaqueteDTO crearPaquete(@RequestBody PaqueteRequestDTO request) {
        return paqueteService.crearDesdeDTO(request);
    }

    @GetMapping("/{id}")
    public ResponseEntity<PaqueteDTO> obtenerPaquete(@PathVariable Long id) {
        return paqueteService.obtenerPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // NUEVO: Endpoint para eliminar paquete por id
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarPaquete(@PathVariable Long id) {
        boolean eliminado = paqueteService.eliminarPaquete(id);
        if (eliminado) {
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}
