package com.example.backend.service;

import com.example.backend.dto.ClientDto;
import com.example.backend.model.Client;
import com.example.backend.model.User;
import com.example.backend.repository.ClientRepository;
import com.example.backend.repository.UserRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.io.IOException;
import java.nio.file.*;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ClientService {

    private final ClientRepository clientRepository;
    private final UserRepository userRepository;

    private final Path fileStorageLocation = Paths.get("uploads").toAbsolutePath().normalize();


    @PostConstruct
    public void init() {
        try {
            Files.createDirectories(fileStorageLocation);
        } catch (IOException e) {
            throw new RuntimeException("No se pudo crear el directorio de almacenamiento", e);
        }
    }

    public Optional<Client> findById(Long id) {
        return clientRepository.findById(id);
    }

    public Optional<Client> findByUserId(Long userId) {
        return clientRepository.findByUserId(userId);
    }

    public Client saveOrUpdateClient(Long userId, ClientDto clientDto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        Client client = clientRepository.findByUser(user).orElse(new Client());
        client.setUser(user);
        client.setName(clientDto.getName());
        client.setPhone(clientDto.getPhone());
        client.setAddress(clientDto.getAddress());

        // Solo actualiza la imagen si viene en el DTO
        if (clientDto.getImageUrl() != null) {
            client.setImageUrl(clientDto.getImageUrl());
        }

        return clientRepository.save(client);
    }
    public Client updateClient(String username, ClientDto dto) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        Client client = clientRepository.findByUser(user)
                .orElseThrow(() -> new RuntimeException("Cliente no encontrado"));

        client.setName(dto.getName());
        client.setPhone(dto.getPhone());
        client.setAddress(dto.getAddress());

        return clientRepository.save(client);
    }



    public String storeImage(MultipartFile file) throws IOException {
        if (file.isEmpty()) {
            throw new IOException("El archivo está vacío");
        }

        if (!file.getContentType().startsWith("image/")) {
            throw new IOException("El archivo no es una imagen válida");
        }

        String originalFileName = Paths.get(file.getOriginalFilename()).getFileName().toString();
        String extension = "";

        if (originalFileName.contains(".")) {
            extension = originalFileName.substring(originalFileName.lastIndexOf("."));
        }

        String fileName = UUID.randomUUID().toString() + extension;
        Path targetLocation = fileStorageLocation.resolve(fileName);
        Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);
        return fileName;
    }

    public ClientDto getClientDtoByUserId(Long userId) {
        return clientRepository.findByUserId(userId)
                .map(ClientDto::new)
                .orElse(null);
    }
    public Long findClientIdByUserId(Long userId) {
        return clientRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Cliente no encontrado"))
                .getId();
    }

    public Client saveClientImage(Long userId, MultipartFile file) throws IOException {
        Client client = clientRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Cliente no encontrado"));

        String fileName = storeImage(file);

        String fileDownloadUri = ServletUriComponentsBuilder.fromCurrentContextPath()
                .path("/uploads/")
                .path(fileName)
                .toUriString();

        client.setImageUrl(fileDownloadUri);
        return clientRepository.save(client);
    }
}
