package com.track60.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "subtareas")
public class SubtaskDocument {
    @Id
    private String id;

    @Indexed
    private String activityId;

    private int orden;
    private String nombre;
    private String descripcion;
    private String instruccion;

    @Builder.Default
    private boolean esObligatoria = true;

    private boolean requiereFoto;
    private boolean requiereComentario;
    private boolean requiereMedicion;
    private String unidadMedida;
    private Double valorMinimo;
    private Double valorMaximo;
}

