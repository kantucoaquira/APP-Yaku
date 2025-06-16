package com.example.backend.service;

import com.example.backend.model.Hotel;
import com.example.backend.repository.HotelRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.*;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor // Genera un constructor para 'hotelRepository'
public class HotelService {

    private final HotelRepository hotelRepository;
    private final Path fileStorageLocation = Paths.get("uploads").toAbsolutePath().normalize();

    // Este constructor es generado automáticamente por Lombok gracias a @RequiredArgsConstructor
    // Pero aquí mostramos cómo integrarlo con la lógica del directorio uploads
    {
        try {
            Files.createDirectories(fileStorageLocation);
        } catch (IOException ex) {
            throw new RuntimeException("No se pudo crear la carpeta de uploads.", ex);
        }
    }

    // Métodos de CRUD
    public List<Hotel> findAll() {
        return hotelRepository.findAll();
    }

    public Optional<Hotel> findById(Long id) {
        return hotelRepository.findById(id);
    }

    public Hotel save(Hotel hotel) {
        return hotelRepository.save(hotel);
    }

    public void deleteById(Long id) {
        hotelRepository.deleteById(id);
    }
    public void delete(Long id) throws IOException {
        Hotel hotel = hotelRepository.findById(id).orElseThrow(() -> new RuntimeException("Hotel no encontrado"));
        if (hotel.getImageUrl() != null) {
            Path filePath = fileStorageLocation.resolve(Paths.get(hotel.getImageUrl()).getFileName());
            Files.deleteIfExists(filePath);
        }
        hotelRepository.deleteById(id);
    }

    public String storeImage(MultipartFile file) throws IOException {
        String fileName = StringUtils.cleanPath(file.getOriginalFilename());

        if (fileName.contains("..")) {
            throw new IllegalArgumentException("Nombre de archivo inválido: " + fileName);
        }

        Path targetLocation = fileStorageLocation.resolve(fileName);
        Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);

        return fileName;
    }

    public Path loadImagePath(String fileName) {
        return fileStorageLocation.resolve(fileName);
    }
}