package com.example.backend.controller;

import com.example.backend.dto.RestaurantDTO;
import com.example.backend.model.Restaurant;
import com.example.backend.service.RestaurantService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/restaurants")
@RequiredArgsConstructor
public class RestaurantController {

    private final RestaurantService restaurantService;

    @GetMapping
    public List<RestaurantDTO> list() {
        return restaurantService.findAll().stream()
                .map(RestaurantDTO::new)
                .collect(Collectors.toList());
    }

    @GetMapping("/{id}")
    public ResponseEntity<RestaurantDTO> get(@PathVariable Long id) {
        return restaurantService.findById(id)
                .map(restaurant -> ResponseEntity.ok(new RestaurantDTO(restaurant)))
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<RestaurantDTO> create(@RequestBody Restaurant restaurant) {
        Restaurant createdRestaurant = restaurantService.save(restaurant);
        return ResponseEntity.status(201).body(new RestaurantDTO(createdRestaurant));
    }

    @PutMapping("/{id}")
    public ResponseEntity<RestaurantDTO> update(@PathVariable Long id, @RequestBody Restaurant restaurant) {
        restaurant.setId(id);
        Restaurant updatedRestaurant = restaurantService.save(restaurant);
        return ResponseEntity.ok(new RestaurantDTO(updatedRestaurant));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        restaurantService.delete(id);
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

        return restaurantService.findById(id).map(restaurant -> {
            try {
                String fileName = restaurantService.storeImage(file);
                String fileDownloadUri = ServletUriComponentsBuilder.fromCurrentContextPath()
                        .path("/uploads/")
                        .path(fileName)
                        .toUriString();

                restaurant.setImageUrl(fileDownloadUri);
                restaurantService.save(restaurant);

                return ResponseEntity.ok(new RestaurantDTO(restaurant));
            } catch (Exception e) {
                return ResponseEntity.status(500).body("Error al guardar la imagen");
            }
        }).orElse(ResponseEntity.notFound().build());
    }
}
