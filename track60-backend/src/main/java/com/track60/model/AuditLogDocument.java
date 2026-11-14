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
@Document(collection = "auditoria")
public class AuditLogDocument {
    @Id
    private String id;

    @Indexed
    private String userId;

    private String userNombre;
    private String rol;
    private String plantId;
    private String accion;
    private String entidad;
    private String entidadId;
    private String detalle;

    @CreatedDate
    private Instant createdAt;
}

