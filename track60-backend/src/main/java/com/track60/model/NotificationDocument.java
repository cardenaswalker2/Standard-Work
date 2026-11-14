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
@Document(collection = "notificaciones")
@CompoundIndex(name = "idx_notif_user_read", def = "{'targetUserId': 1, 'leida': 1}")
public class NotificationDocument {
    @Id
    private String id;

    private String targetUserId; // 'ALL' o ID específico
    private String plantId;
    private String titulo;
    private String mensaje;
    private String tipo; // info, alerta, corporativo, aprobacion
    private String autor;

    @Builder.Default
    private boolean leida = false;

    @CreatedDate
    private Instant createdAt;
}

