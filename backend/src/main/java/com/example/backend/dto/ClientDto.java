package com.example.backend.dto;

import com.example.backend.model.Client;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class ClientDto {
    private String name;
    private String phone;
    private String address;
    private String imageUrl;

    public ClientDto(Client client) {
        this.name = client.getName();
        this.phone = client.getPhone();
        this.address = client.getAddress();
        this.imageUrl = client.getImageUrl();
    }
}


