package com.track60.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "plantas")
public class PlantDocument {
    @Id
    private String id;

    @Indexed(unique = true)
    private String codigo;

    private String nombre;
    private String descripcion;

    @Builder.Default
    private String colorHex = "#002F6C";

    @Builder.Default
    private List<String> areas = new ArrayList<>();

    @Builder.Default
    private boolean activa = true;

    @Builder.Default
    private int capacidadBaseLocal = 2;

    @CreatedDate
    private Instant createdAt;
}

