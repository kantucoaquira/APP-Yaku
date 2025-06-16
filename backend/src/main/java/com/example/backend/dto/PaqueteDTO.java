package com.example.backend.dto;

import com.example.backend.model.Paquete;
import com.example.backend.model.Menu;
import com.example.backend.model.Room;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.stream.Collectors;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaqueteDTO {

    private Long id;
    private String nombre;
    private List<MenuDTO> menus;
    private List<RoomDTO> rooms;
    private double precioOriginal;
    private double precioConDescuento;

    // Constructor desde entidad
    public PaqueteDTO(Paquete paquete) {
        this.id = paquete.getId();
        this.nombre = paquete.getNombre();
        this.precioOriginal = paquete.getPrecioOriginal();
        this.precioConDescuento = paquete.getPrecioConDescuento();

        this.menus = paquete.getMenus() != null
                ? paquete.getMenus().stream().map(MenuDTO::new).collect(Collectors.toList())
                : null;

        this.rooms = paquete.getRooms() != null
                ? paquete.getRooms().stream().map(RoomDTO::new).collect(Collectors.toList())
                : null;
    }
}
