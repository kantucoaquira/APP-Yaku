package com.example.backend.service;

import com.example.backend.dto.CartDTO;
import com.example.backend.dto.CartItemDTO;
import com.example.backend.model.*;
import com.example.backend.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class CartService {

    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final ClientRepository clientRepository;
    private final MenuRepository menuRepository;
    private final RoomRepository roomRepository;

    public CartService(CartRepository cartRepository, CartItemRepository cartItemRepository,
                       ClientRepository clientRepository, MenuRepository menuRepository,
                       RoomRepository roomRepository) {
        this.cartRepository = cartRepository;
        this.cartItemRepository = cartItemRepository;
        this.clientRepository = clientRepository;
        this.menuRepository = menuRepository;
        this.roomRepository = roomRepository;
    }

    @Transactional
    public Cart createOrGetPendingCart(Long clientId) {
        Client client = clientRepository.findById(clientId)
                .orElseThrow(() -> new RuntimeException("Cliente no encontrado"));

        Optional<Cart> existingCart = cartRepository.findByClientAndStatus(client, CartStatus.PENDIENTE);
        if (existingCart.isPresent()) {
            return existingCart.get();
        }

        Cart newCart = new Cart();
        newCart.setClient(client);
        newCart.setStatus(CartStatus.PENDIENTE);
        newCart.setCreatedAt(LocalDateTime.now());
        newCart.setTotal(0.0);

        return cartRepository.save(newCart);
    }

    @Transactional
    public Cart addItemToCart(Long cartId, CartItemDTO itemDTO) {
        Cart cart = cartRepository.findById(cartId)
                .orElseThrow(() -> new RuntimeException("Carrito no encontrado"));

        CartItem item = new CartItem();
        item.setCart(cart);
        item.setQuantity(itemDTO.getQuantity());

        if (itemDTO.getMenuId() != null) {
            Menu menu = menuRepository.findById(itemDTO.getMenuId())
                    .orElseThrow(() -> new RuntimeException("Menu no encontrado"));
            item.setMenu(menu);
            item.setRoom(null);
        } else if (itemDTO.getRoomId() != null) {
            Room room = roomRepository.findById(itemDTO.getRoomId())
                    .orElseThrow(() -> new RuntimeException("Room no encontrado"));
            item.setRoom(room);
            item.setMenu(null);
        } else {
            throw new RuntimeException("Debe especificar un MenuId o RoomId");
        }

        cart.getItems().add(item);
        updateCartTotal(cart);

        cartItemRepository.save(item);
        return cartRepository.save(cart);
    }

    private void updateCartTotal(Cart cart) {
        double total = 0;
        for (CartItem item : cart.getItems()) {
            if (item.getMenu() != null) {
                total += item.getMenu().getPrice() * item.getQuantity();
            } else if (item.getRoom() != null) {
                total += item.getRoom().getPrice() * item.getQuantity();
            }
        }
        cart.setTotal(total);
    }

    @Transactional
    public CartDTO getCart(Long cartId) {
        Cart cart = cartRepository.findById(cartId)
                .orElseThrow(() -> new RuntimeException("Carrito no encontrado"));
        return mapToDTO(cart);
    }

    private CartDTO mapToDTO(Cart cart) {
        CartDTO dto = new CartDTO();
        dto.setId(cart.getId());
        dto.setClientId(cart.getClient().getId());
        dto.setStatus(cart.getStatus().name());
        dto.setTotal(cart.getTotal());
        dto.setCreatedAt(cart.getCreatedAt());

        List<CartItemDTO> itemsDTO = cart.getItems().stream().map(item -> {
            CartItemDTO itemDTO = new CartItemDTO();
            if (item.getMenu() != null) {
                itemDTO.setMenuId(item.getMenu().getId());
            }
            if (item.getRoom() != null) {
                itemDTO.setRoomId(item.getRoom().getId());
            }
            itemDTO.setQuantity(item.getQuantity());
            return itemDTO;
        }).toList();

        dto.setItems(itemsDTO);
        return dto;
    }

    @Transactional
    public Cart updateStatus(Long cartId, CartStatus newStatus) {
        Cart cart = cartRepository.findById(cartId)
                .orElseThrow(() -> new RuntimeException("Carrito no encontrado"));
        cart.setStatus(newStatus);
        return cartRepository.save(cart);
    }
}
