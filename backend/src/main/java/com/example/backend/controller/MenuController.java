package com.example.backend.controller;

import com.example.backend.dto.MenuDTO;
import com.example.backend.model.Menu;
import com.example.backend.model.Restaurant;
import com.example.backend.service.MenuService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import com.example.backend.model.User;
import com.example.backend.security.services.UserDetailsImpl;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/menus")
@RequiredArgsConstructor
public class MenuController {

    private final MenuService menuService;

    // Listar menus filtrando por usuarioId
    @GetMapping
    public List<MenuDTO> list(Authentication authentication,
                              @RequestParam(required = false) Boolean my) {
        if (Boolean.TRUE.equals(my)) {
            UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
            return menuService.findByUserId(userDetails.getId()).stream()
                    .map(MenuDTO::new)
                    .collect(Collectors.toList());
        }

        return menuService.findAll().stream()
                .map(MenuDTO::new)
                .collect(Collectors.toList());
    }


    @GetMapping("/{id}")
    public ResponseEntity<MenuDTO> get(@PathVariable Long id) {
        return menuService.findById(id)
                .map(menu -> ResponseEntity.ok(new MenuDTO(menu)))
                .orElse(ResponseEntity.notFound().build());
    }
    @GetMapping("/my")
    public List<MenuDTO> getMyMenus(Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        return menuService.findByUserId(userDetails.getId()).stream()
                .map(MenuDTO::new)
                .collect(Collectors.toList());
    }


    @PostMapping
    public ResponseEntity<?> create(@RequestBody Menu menu, Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();

        if (menu.getRestaurant() == null || menu.getRestaurant().getId() == null) {
            return ResponseEntity.badRequest().body("Falta el ID del restaurante");
        }

        // Aquí podrías validar si el restaurante existe, si es necesario
        Restaurant restaurant = new Restaurant();
        restaurant.setId(menu.getRestaurant().getId());

        User user = new User();
        user.setId(userDetails.getId());

        menu.setUser(user);
        menu.setRestaurant(restaurant);

        Menu createdMenu = menuService.save(menu);
        return ResponseEntity.status(201).body(new MenuDTO(createdMenu));
    }


    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @RequestBody Menu menuData, Authentication authentication) {
        return menuService.findById(id).map(existingMenu -> {
            // Actualizar los campos que se pueden modificar
            existingMenu.setName(menuData.getName());
            existingMenu.setDescription(menuData.getDescription());
            existingMenu.setPrice(menuData.getPrice());

            // Actualizar restaurante solo si se pasa un ID válido
            if (menuData.getRestaurant() != null && menuData.getRestaurant().getId() != null) {
                Restaurant restaurant = new Restaurant();
                restaurant.setId(menuData.getRestaurant().getId());
                existingMenu.setRestaurant(restaurant);
            }

            // ⚠️ Reasignar el user autenticado (¡clave!)
            UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
            User user = new User();
            user.setId(userDetails.getId());
            existingMenu.setUser(user);

            Menu updated = menuService.save(existingMenu);
            return ResponseEntity.ok(new MenuDTO(updated));
        }).orElse(ResponseEntity.notFound().build());
    }


    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        menuService.delete(id);
        return ResponseEntity.noContent().build();
    }

    // Subida de imagen para menú
    @PostMapping("/{id}/uploadImage")
    public ResponseEntity<?> uploadImage(@PathVariable Long id, @RequestParam("image") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("Archivo vacío");
        }
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            return ResponseEntity.badRequest().body("Archivo no es una imagen válida");
        }

        return menuService.findById(id).map(menu -> {
            try {
                String fileName = menuService.storeImage(file);
                String fileDownloadUri = ServletUriComponentsBuilder.fromCurrentContextPath()
                        .path("/uploads/")
                        .path(fileName)
                        .toUriString();

                menu.setImageUrl(fileDownloadUri);
                menuService.save(menu);

                return ResponseEntity.ok(new MenuDTO(menu));
            } catch (Exception e) {
                return ResponseEntity.status(500).body("Error al guardar la imagen");
            }
        }).orElse(ResponseEntity.notFound().build());
    }
}
