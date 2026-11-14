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
@Document(collection = "ejecuciones_actividades")
@CompoundIndex(name = "idx_inst_plant_week_day", def = "{'plantId': 1, 'weekKey': 1, 'day': 1, 'userId': 1}")
public class ActivityInstanceDocument {
    @Id
    private String id;

    private String activityId;
    private String userId;
    private String plantId;
    private String weekKey;
    private String nombre;
    private String descripcion;
    private String area;
    private String category;
    private String timeStart;
    private String timeEnd;
    private String prioridad;
    private int day;
    private int orig;
    private boolean fija;
    private boolean done;

    @Builder.Default
    private String state = "Pendiente"; // Pendiente, Reportada, Aprobada, RequiereCorreccion, Reprogramada

    private Instant completedAt;
    private String observaciones;
    private String motivoNoRealizada;
    private int subtasksTotal;
    private int subtasksReported;
    private int subtasksApproved;

    @Builder.Default
    private String tipoActividad = "ejecucion";

    private boolean requierePlanAccion;
    private boolean planAccionObligatorio;
    private String instrucciones;
    private String criteriosCumplimiento;
    private boolean reqFoto;
    private boolean reqMedicion;
    private boolean reqComentario;

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;
}

