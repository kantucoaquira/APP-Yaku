    package com.example.backend.controller;

    import com.example.backend.dto.ClientDto;
    import com.example.backend.model.Client;
    import com.example.backend.security.services.UserDetailsImpl;
    import com.example.backend.service.ClientService;
    import lombok.RequiredArgsConstructor;
    import org.springframework.http.ResponseEntity;
    import org.springframework.security.core.Authentication;
    import org.springframework.web.bind.annotation.*;
    import org.springframework.web.multipart.MultipartFile;

    import java.io.IOException;

    @RestController
    @RequestMapping("/api/clients")
    @RequiredArgsConstructor
    public class ClientController {

        private final ClientService clientService;


        @PutMapping
        public ResponseEntity<?> updateClient(@RequestBody ClientDto clientDto, Authentication authentication) {
            UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
            Long userId = userDetails.getId();

            Client updatedClient = clientService.saveOrUpdateClient(userId, clientDto);
            return ResponseEntity.ok(updatedClient);
        }


        @PostMapping("/uploadImage")
        public ResponseEntity<?> uploadProfileImage(Authentication authentication, @RequestParam("image") MultipartFile file) {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().body("Archivo vacío");
            }

            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                return ResponseEntity.badRequest().body("Archivo no es una imagen válida");
            }

            UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
            Long userId = userDetails.getId();

            try {
                Client client = clientService.saveClientImage(userId, file);
                return ResponseEntity.ok(
                        java.util.Map.of("imageUrl", client.getImageUrl())
                );
            } catch (IOException e) {
                return ResponseEntity.status(500).body("Error al guardar la imagen");
            }
        }
        @GetMapping("/me")
        public ResponseEntity<?> getCurrentClient(Authentication authentication) {
            UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
            Long userId = userDetails.getId();

            ClientDto clientDto = clientService.getClientDtoByUserId(userId);
            if (clientDto == null) {
                return ResponseEntity.notFound().build();
            }

            return ResponseEntity.ok(clientDto);
        }

    }
