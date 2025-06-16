package com.example.backend.controller;

import com.example.backend.dto.RoomDTO;
import com.example.backend.model.Availability;
import com.example.backend.model.Room;
import com.example.backend.model.User;
import com.example.backend.repository.HotelRepository;
import com.example.backend.repository.UserRepository;
import com.example.backend.service.RoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/rooms")
@RequiredArgsConstructor
public class RoomController {

    private final RoomService roomService;
    private final HotelRepository hotelRepository;
    private final UserRepository userRepository;

    @GetMapping
    public List<RoomDTO> list() {
        return roomService.findAll().stream()
                .map(RoomDTO::new)
                .collect(Collectors.toList());
    }

    @GetMapping("/{id}")
    public ResponseEntity<RoomDTO> get(@PathVariable Long id) {
        return roomService.findById(id)
                .map(room -> ResponseEntity.ok(new RoomDTO(room)))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/hotel/{hotelId}")
    public List<RoomDTO> getByHotel(@PathVariable Long hotelId) {
        return roomService.findByHotelId(hotelId).stream()
                .map(RoomDTO::new)
                .collect(Collectors.toList());
    }

    @GetMapping("/disponibles")
    public List<RoomDTO> getDisponibles() {
        return roomService.findByAvailability(Availability.DISPONIBLE)
                .stream()
                .map(RoomDTO::new)
                .collect(Collectors.toList());
    }
    @GetMapping("/my-rooms")
    public ResponseEntity<List<RoomDTO>> getMyRooms(Authentication authentication) {
        String username = authentication.getName();  // Obtenemos el username autenticado
        User user = userRepository.findByUsername(username).orElse(null);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        List<RoomDTO> rooms = roomService.findByAdminId(user.getId());
        return ResponseEntity.ok(rooms);
    }



    @PostMapping
    public ResponseEntity<?> create(@RequestBody Room room, Authentication authentication) {
        String username = authentication.getName();
        User user = userRepository.findByUsername(username).orElse(null);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Usuario no autenticado");
        }

        boolean isAdmin = user.getRoles().stream()
                .anyMatch(role -> role.getName().name().equals("ROLE_ADMIN"));

        if (!isAdmin) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
        }

        Long hotelId = room.getHotel() != null ? room.getHotel().getId() : null;
        if (hotelId == null || !hotelRepository.existsById(hotelId)) {
            return ResponseEntity.badRequest().body("Hotel inválido o inexistente");
        }

        room.setCreatedBy(user);  // asigna admin creador
        Room createdRoom = roomService.save(room);
        return ResponseEntity.status(201).body(new RoomDTO(createdRoom));
    }
    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @RequestBody Room updatedData, Authentication authentication) {
        return roomService.findById(id).map(existingRoom -> {
            // Verificación de usuario
            String username = authentication.getName();
            User user = userRepository.findByUsername(username).orElse(null);
            if (user == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Usuario no autenticado");
            }

            // Verifica si el hotel es válido
            Long hotelId = updatedData.getHotel() != null ? updatedData.getHotel().getId() : null;
            if (hotelId == null || !hotelRepository.existsById(hotelId)) {
                return ResponseEntity.badRequest().body("Hotel inválido o inexistente");
            }

            // Actualiza solo los campos editables
            existingRoom.setName(updatedData.getName());
            existingRoom.setDescription(updatedData.getDescription());
            existingRoom.setPrice(updatedData.getPrice());
            existingRoom.setCapacity(updatedData.getCapacity());
            existingRoom.setHotel(updatedData.getHotel());
            // Mantenemos availability e imageUrl existentes si no se envían nuevos valores
            if (updatedData.getAvailability() != null) {
                existingRoom.setAvailability(updatedData.getAvailability());
            }
            if (updatedData.getImageUrl() != null) {
                existingRoom.setImageUrl(updatedData.getImageUrl());
            }

            Room saved = roomService.save(existingRoom);
            return ResponseEntity.ok(new RoomDTO(saved));
        }).orElse(ResponseEntity.notFound().build());
    }




    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        roomService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/uploadImage")
    public ResponseEntity<?> uploadImage(@PathVariable Long id, @RequestParam("image") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("Archivo vacío");
        }
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            return ResponseEntity.badRequest().body("Archivo no es una imagen válida");
        }

        return roomService.findById(id).map(room -> {
            try {
                String fileName = roomService.storeImage(file);
                String fileDownloadUri = ServletUriComponentsBuilder.fromCurrentContextPath()
                        .path("/uploads/")
                        .path(fileName)
                        .toUriString();

                room.setImageUrl(fileDownloadUri);
                roomService.save(room);

                return ResponseEntity.ok(new RoomDTO(room));
            } catch (Exception e) {
                return ResponseEntity.status(500).body("Error al guardar la imagen");
            }
        }).orElse(ResponseEntity.notFound().build());
    }
}
