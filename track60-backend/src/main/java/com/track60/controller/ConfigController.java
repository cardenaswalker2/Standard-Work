package com.track60.controller;

import com.track60.dto.ApiResponse;
import com.track60.model.AppConfigDocument;
import com.track60.repository.AppConfigRepository;
import com.track60.security.ScopeValidator;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/config")
@RequiredArgsConstructor
@Tag(name = "Configuración Corporativa")
public class ConfigController {

    private static final String GLOBAL_ID = "GLOBAL_CATALOGS";

    private final AppConfigRepository configRepository;
    private final ScopeValidator scope;

    @GetMapping("/catalogs")
    public ApiResponse<AppConfigDocument> getCatalogs() {
        AppConfigDocument doc = configRepository.findById(GLOBAL_ID).orElseGet(() ->
                AppConfigDocument.builder()
                        .id(GLOBAL_ID)
                        .areas(List.of("Producción", "Calidad", "Mantenimiento", "Seguridad / EHS", "Logística", "Operación", "Todas las Áreas"))
                        .categories(List.of("General", "Seguridad", "Calidad", "5S", "Mantenimiento", "OEE", "Operación", "Reunión"))
                        .build()
        );
        return ApiResponse.ok(doc);
    }

    @PutMapping("/catalogs")
    public ApiResponse<AppConfigDocument> updateCatalogs(@RequestBody AppConfigDocument req) {
        scope.requireAdminOrSuperAdmin();
        AppConfigDocument doc = configRepository.findById(GLOBAL_ID).orElse(new AppConfigDocument());
        doc.setId(GLOBAL_ID);
        if (req.getAreas() != null) {
            doc.setAreas(req.getAreas());
        }
        if (req.getCategories() != null) {
            doc.setCategories(req.getCategories());
        }
        return ApiResponse.ok(configRepository.save(doc), "Catálogos actualizados");
    }
}
