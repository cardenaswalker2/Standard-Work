package com.track60.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "plantillas")
public class ActivityTemplateDocument {
    @Id
    private String id;

    private String nombre;
    private String descripcion;
    private String area;

    @Builder.Default
    private String category = "Operación";

    @Builder.Default
    private String prioridad = "Alta";

    private boolean fija;
    private boolean reqFoto;
    private boolean reqMedicion;

    @Builder.Default
    private boolean reqComentario = true;

    @Builder.Default
    private String tipoActividad = "ejecucion";

    private boolean requierePlanAccion;
    private boolean planAccionObligatorio;
    private String instrucciones;
    private String criteriosCumplimiento;

    @Builder.Default
    private String subtareasJson = "[]";

    @CreatedDate
    private Instant createdAt;
}

