package com.example.backend.repository;

import com.example.backend.model.Availability;
import com.example.backend.model.Room;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RoomRepository extends JpaRepository<Room, Long> {
    @EntityGraph(attributePaths = {"hotel"})
    List<Room> findByHotelId(Long hotelId);

    @EntityGraph(attributePaths = {"hotel"})
    List<Room> findByAvailability(Availability availability);

    @EntityGraph(attributePaths = {"hotel"})
    List<Room> findAll();
    List<Room> findByCreatedById(Long userId);


}
