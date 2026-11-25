package com.track60.security;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.Collection;
import java.util.List;

@Getter
@AllArgsConstructor
public class Track60UserPrincipal {
    private final String userId;
    private final String cedula;
    private final String nombre;
    private final String rol; // superadmin | admin_planta | supervisor | operador
    private final String plantId; // 'ALL' o ID de planta

    public String getSpringRole() {
        return switch (rol == null ? "" : rol.toLowerCase()) {
            case "ultra_admin" -> "ROLE_ULTRA_ADMIN";
            case "superadmin" -> "ROLE_SUPER_ADMIN";
            case "admin_planta" -> "ROLE_ADMIN";
            case "supervisor" -> "ROLE_SUPERVISOR";
            default -> "ROLE_COLABORADOR";
        };
    }

    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority(getSpringRole()));
    }

    public boolean isUltraAdmin() {
        return "ultra_admin".equalsIgnoreCase(rol);
    }

    public boolean isSuperAdmin() {
        return "superadmin".equalsIgnoreCase(rol) || isUltraAdmin();
    }

    public boolean isPlantAdmin() {
        return "admin_planta".equalsIgnoreCase(rol);
    }

    public boolean isSupervisor() {
        return "supervisor".equalsIgnoreCase(rol);
    }
}
