package com.track60.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "planes_accion")
@CompoundIndex(name = "idx_plan_plant_estado", def = "{'plantId': 1, 'estado': 1}")
public class ActionPlanDocument {
    @Id
    private String id;

    private String plantId;
    private String activityInstanceId;
    private String nombre;
    private String descripcion;
    private String causaRaiz;
    private String accionCorrectiva;
    private String responsableId;
    private String responsableNombre;
    private String prioridad;

    @Builder.Default
    private String estado = "Abierto"; // Abierto, En Progreso, En Revisión, Cerrado, Vencido

    private Instant fechaLimite;
    private String evidenciaCierreUrl;
    private String observaciones;

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;
}

