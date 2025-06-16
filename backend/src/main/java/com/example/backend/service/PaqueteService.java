package com.example.backend.service;

import com.example.backend.dto.MenuDTO;
import com.example.backend.dto.PaqueteDTO;
import com.example.backend.dto.PaqueteRequestDTO;
import com.example.backend.dto.RoomDTO;
import com.example.backend.model.Menu;
import com.example.backend.model.Paquete;
import com.example.backend.model.Room;
import com.example.backend.repository.MenuRepository;
import com.example.backend.repository.PaqueteRepository;
import com.example.backend.repository.RoomRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class PaqueteService {

    @Autowired
    private PaqueteRepository paqueteRepository;
    @Autowired
    private MenuRepository menuRepository;
    @Autowired
    private RoomRepository roomRepository;

    public List<PaqueteDTO> listarTodos() {
        List<Paquete> paquetes = paqueteRepository.findAll();
        return paquetes.stream()
                .map(PaqueteDTO::new)
                .collect(Collectors.toList());
    }
    public PaqueteDTO crearDesdeDTO(PaqueteRequestDTO request) {
        Paquete paquete = new Paquete();
        paquete.setNombre(request.getNombre());

        // Cargar Menus y Rooms desde DB por sus IDs
        List<Menu> menus = menuRepository.findAllById(request.getMenuIds());
        List<Room> rooms = roomRepository.findAllById(request.getRoomIds());

        paquete.setMenus(menus);
        paquete.setRooms(rooms);

        // Calcular precio original sumando precios de menus y rooms
        double precioOriginal = 0.0;
        for (Menu menu : menus) {
            if (menu.getPrice() != null) {
                precioOriginal += menu.getPrice();
            }
        }
        for (Room room : rooms) {
            if (room.getPrice() != null) {
                precioOriginal += room.getPrice();
            }
        }
        paquete.setPrecioOriginal(precioOriginal);

        // Aplicar descuento si hay 2 o más items
        int totalItems = menus.size() + rooms.size();
        if (totalItems >= 2) {
            double descuento = precioOriginal * 0.10; // 10%
            paquete.setPrecioConDescuento(precioOriginal - descuento);
        } else {
            // Si solo 1 o menos, no hay descuento
            paquete.setPrecioConDescuento(precioOriginal);
        }

        // Guardar paquete en DB
        Paquete paqueteGuardado = paqueteRepository.save(paquete);

        return new PaqueteDTO(paqueteGuardado);
    }


    public PaqueteDTO crearPaquete(Paquete paquete) {
        Paquete nuevo = paqueteRepository.save(paquete);
        return new PaqueteDTO(nuevo);
    }
    public boolean eliminarPaquete(Long id) {
        Optional<Paquete> paqueteOpt = paqueteRepository.findById(id);
        if (paqueteOpt.isPresent()) {
            paqueteRepository.delete(paqueteOpt.get());
            return true;
        }
        return false;
    }

    public Optional<PaqueteDTO> obtenerPorId(Long id) {
        return paqueteRepository.findById(id).map(PaqueteDTO::new);
    }
}
