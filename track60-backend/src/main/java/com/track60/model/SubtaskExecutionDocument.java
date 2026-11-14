package com.track60.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "evidencias")
@CompoundIndex(name = "idx_evid_plant_estado", def = "{'plantId': 1, 'estadoValidacion': 1}")
public class SubtaskExecutionDocument {
    @Id
    private String id;

    private String instanceId;
    private String subtaskId;
    private String plantId;
    private String userId;
    private String nombreSubtarea;
    private boolean completada;
    private String comentarioOperador;

    /**
     * URL segura en almacenamiento externo (Cloudinary / Cloudflare R2), nunca Base64
     */
    private String fotoUrl;
    private String fotoPublicId;

    private Double valorMedido;

    @Builder.Default
    private String estadoValidacion = "Pendiente"; // Pendiente, Reportada, Aprobada, Rechazada

    private String supervisorId;
    private String comentarioSupervisor;
    private Instant fechaReporte;
    private Instant fechaValidacion;

    @CreatedDate
    private Instant createdAt;
}

