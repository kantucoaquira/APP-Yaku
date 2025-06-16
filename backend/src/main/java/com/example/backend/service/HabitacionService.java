package com.example.backend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

import com.example.backend.model.Habitacion;
import com.example.backend.model.Hotel;
import com.example.backend.dto.HabitacionDTO;
import com.example.backend.repository.HabitacionRepository;
import com.example.backend.repository.HotelRepository;

import java.util.List;

@Service
public class HabitacionService {

    @Autowired
    private HabitacionRepository habitacionRepository;

    @Autowired
    private HotelRepository hotelRepository;

    public List<Habitacion> listar() {
        return habitacionRepository.findAll();
    }

    public Habitacion guardar(HabitacionDTO dto) {
        Habitacion habitacion = new Habitacion();
        habitacion.setNumero(dto.numero);
        habitacion.setTipo(dto.tipo);
        habitacion.setPrecio(dto.precio);
        habitacion.setDescripcion(dto.descripcion);
        habitacion.setDisponible(dto.disponible);
        habitacion.setHotel(hotelRepository.findById(dto.hotelId).orElseThrow());
        return habitacionRepository.save(habitacion);
    }

    public void eliminar(Long id) {
        habitacionRepository.deleteById(id);
    }
}
