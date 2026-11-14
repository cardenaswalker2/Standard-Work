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
@Document(collection = "usuarios")
@CompoundIndex(name = "idx_user_plant_rol", def = "{'plantId': 1, 'rol': 1, 'activo': 1}")
public class UserDocument {
    @Id
    private String id;

    @Indexed(unique = true)
    private String cedula;

    private String nombre;
    private String cargo;
    private String area;
    private String iniciales;

    @Indexed(sparse = true)
    private String email;

    @Builder.Default
    private boolean activo = true;

    /**
     * Roles compatibles con Flutter:
     * superadmin | admin_planta | supervisor | operador
     */
    private String rol;

    /**
     * 'ALL' para Superadmin, o ID de planta específica (ej. PL-EXTRUSA)
     */
    @Indexed
    private String plantId;

    /**
     * Hash BCrypt del PIN / contraseña (nunca se devuelve en respuestas REST)
     */
    private String pinHash;

    private String observaciones;

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;
}

