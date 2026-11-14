package com.track60.security;

import com.track60.exception.ApiException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
public class ScopeValidator {

    public Track60UserPrincipal currentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !(auth.getPrincipal() instanceof Track60UserPrincipal principal)) {
            throw ApiException.unauthorized("Sesión no autenticada");
        }
        return principal;
    }

    public void requireSuperAdmin() {
        if (!currentUser().isSuperAdmin()) {
            throw ApiException.forbidden("Requiere rol Super Administrador");
        }
    }

    public void requireAdminOrSuperAdmin() {
        Track60UserPrincipal u = currentUser();
        if (!u.isSuperAdmin() && !u.isPlantAdmin()) {
            throw ApiException.forbidden("Requiere rol Administrador");
        }
    }

    public void requirePlantAccess(String targetPlantId) {
        Track60UserPrincipal u = currentUser();
        if (u.isSuperAdmin()) {
            return;
        }
        if (targetPlantId == null || !targetPlantId.equals(u.getPlantId())) {
            throw ApiException.forbidden("No tienes acceso a información de otra planta");
        }
    }
}

