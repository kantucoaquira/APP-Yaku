package com.example.backend.service;

import com.example.backend.model.Availability;
import com.example.backend.model.Room;
import com.example.backend.repository.RoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import com.example.backend.dto.RoomDTO;
import java.util.stream.Collectors;

import java.io.IOException;
import java.nio.file.*;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class RoomService {

    private final RoomRepository roomRepository;

    private final Path fileStorageLocation = Paths.get("uploads").toAbsolutePath().normalize();

    public List<Room> findAll() {
        return roomRepository.findAll();
    }
    public List<Room> findByHotelId(Long hotelId) {
        return roomRepository.findByHotelId(hotelId);
    }

    public Optional<Room> findById(Long id) {
        return roomRepository.findById(id);
    }

    public Room save(Room room) {
        return roomRepository.save(room);
    }

    public void delete(Long id) {
        roomRepository.deleteById(id);
    }
    public List<Room> findByAvailability(Availability availability) {
        return roomRepository.findByAvailability(availability);
    }
    public List<RoomDTO> findAllDTO() {
        return roomRepository.findAll().stream()
                .map(RoomDTO::new)
                .collect(Collectors.toList());
    }

    public List<RoomDTO> findByHotelIdDTO(Long hotelId) {
        return roomRepository.findByHotelId(hotelId).stream()
                .map(RoomDTO::new)
                .collect(Collectors.toList());
    }

    public Optional<RoomDTO> findByIdDTO(Long id) {
        return roomRepository.findById(id)
                .map(RoomDTO::new);
    }

    public RoomDTO saveDTO(Room room) {
        Room saved = roomRepository.save(room);
        return new RoomDTO(saved);
    }
    public List<RoomDTO> findByAdminId(Long adminId) {
        return roomRepository.findByCreatedById(adminId)
                .stream()
                .map(RoomDTO::new)
                .collect(Collectors.toList());
    }

    public String storeImage(MultipartFile file) throws IOException {
        if (!Files.exists(fileStorageLocation)) {
            Files.createDirectories(fileStorageLocation);
        }

        String originalFileName = file.getOriginalFilename();
        String extension = "";

        if (originalFileName != null && originalFileName.contains(".")) {
            extension = originalFileName.substring(originalFileName.lastIndexOf("."));
        }

        String fileName = java.util.UUID.randomUUID().toString() + extension;
        Path targetLocation = fileStorageLocation.resolve(fileName);
        Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);
        return fileName;
    }
}
