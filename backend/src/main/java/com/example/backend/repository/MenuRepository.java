package com.example.backend.repository;

import com.example.backend.model.Menu;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MenuRepository extends JpaRepository<Menu, Long> {
    List<Menu> findByUserId(Long userId);
    List<Menu> findByUserIdAndRestaurantId(Long userId, Long restaurantId);
}
