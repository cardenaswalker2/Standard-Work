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

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "solicitudes_capacidad")
public class CapacityRequestDocument {
    @Id
    private String id;

    @Indexed
    private String plantId;

    private String requesterId;
    private String requesterNombre;
    private int cuposSolicitados;
    private String justificacion;
    private String prioridad;

    @Builder.Default
    private String estado = "Pendiente"; // Pendiente, Aprobada, Rechazada

    private String reviewedBy;
    private String comentarioRevision;
    private Instant fechaRevision;

    @CreatedDate
    private Instant createdAt;
}

