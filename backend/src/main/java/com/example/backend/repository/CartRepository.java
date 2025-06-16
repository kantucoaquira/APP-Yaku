package com.example.backend.repository;

import com.example.backend.model.Cart;
import com.example.backend.model.Client;
import com.example.backend.model.CartStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CartRepository extends JpaRepository<Cart, Long> {
    Optional<Cart> findByClientAndStatus(Client client, CartStatus status);
}
