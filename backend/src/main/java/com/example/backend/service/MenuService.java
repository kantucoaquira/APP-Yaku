package com.example.backend.service;

import com.example.backend.model.Menu;
import com.example.backend.repository.MenuRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MenuService {

    private final MenuRepository menuRepository;
    private final Path fileStorageLocation = Paths.get("uploads").toAbsolutePath().normalize();

    public List<Menu> findAll() {
        return menuRepository.findAll();
    }

    public List<Menu> findByUserId(Long userId) {
        return menuRepository.findByUserId(userId);
    }

    public Optional<Menu> findById(Long id) {
        return menuRepository.findById(id);
    }

    public Menu save(Menu menu) {
        return menuRepository.save(menu);
    }

    public void delete(Long id) {
        menuRepository.deleteById(id);
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
