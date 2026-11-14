package com.track60.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "actividades")
@CompoundIndex(name = "idx_act_plant_user", def = "{'plantId': 1, 'userId': 1, 'esGlobal': 1}")
public class ActivityDocument {
    @Id
    private String id;

    @Indexed
    private String plantId;

    @Indexed
    private String userId;

    private String nombre;
    private String descripcion;
    private String area;
    private String category;
    private String timeStart;
    private String timeEnd;
    private boolean fija;

    @Builder.Default
    private String dias = "1,2,3,4,5";

    @Builder.Default
    private String prioridad = "Media";

    private boolean reqFoto;
    private boolean reqMedicion;
    private boolean reqComentario;
    private boolean esGlobal;

    @Builder.Default
    private String tipoActividad = "ejecucion"; // 'ejecucion' o 'registro'

    private boolean requierePlanAccion;
    private boolean planAccionObligatorio;
    private String instrucciones;
    private String criteriosCumplimiento;
    private String createdBy;

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;
}

