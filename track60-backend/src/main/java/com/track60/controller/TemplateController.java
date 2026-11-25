package com.track60.controller;

import com.track60.dto.ApiResponse;
import com.track60.exception.ApiException;
import com.track60.model.ActivityTemplateDocument;
import com.track60.repository.ActivityTemplateRepository;
import com.track60.security.ScopeValidator;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/templates")
@RequiredArgsConstructor
@Tag(name = "Plantillas de Actividad")
public class TemplateController {

    private final ActivityTemplateRepository templateRepository;
    private final ScopeValidator scope;

    @GetMapping
    public ApiResponse<List<ActivityTemplateDocument>> list() {
        return ApiResponse.ok(templateRepository.findAll());
    }

    @PostMapping
    public ApiResponse<ActivityTemplateDocument> create(@RequestBody ActivityTemplateDocument template) {
        scope.requireAdminOrSuperAdmin();
        return ApiResponse.ok(templateRepository.save(template), "Plantilla creada");
    }

    @PutMapping("/{id}")
    public ApiResponse<ActivityTemplateDocument> update(
            @PathVariable String id,
            @RequestBody ActivityTemplateDocument req) {
        scope.requireAdminOrSuperAdmin();
        ActivityTemplateDocument existing = templateRepository.findById(id)
                .orElseThrow(() -> ApiException.notFound("Plantilla no encontrada"));
        existing.setNombre(req.getNombre());
        existing.setDescripcion(req.getDescripcion());
        existing.setArea(req.getArea());
        existing.setCategory(req.getCategory());
        existing.setPrioridad(req.getPrioridad());
        existing.setFija(req.isFija());
        existing.setReqFoto(req.isReqFoto());
        existing.setReqMedicion(req.isReqMedicion());
        existing.setReqComentario(req.isReqComentario());
        existing.setTipoActividad(req.getTipoActividad());
        existing.setRequierePlanAccion(req.isRequierePlanAccion());
        existing.setPlanAccionObligatorio(req.isPlanAccionObligatorio());
        existing.setInstrucciones(req.getInstrucciones());
        existing.setCriteriosCumplimiento(req.getCriteriosCumplimiento());
        existing.setSubtareasJson(req.getSubtareasJson());
        return ApiResponse.ok(templateRepository.save(existing), "Plantilla actualizada");
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable String id) {
        scope.requireAdminOrSuperAdmin();
        if (!templateRepository.existsById(id)) {
            throw ApiException.notFound("Plantilla no encontrada");
        }
        templateRepository.deleteById(id);
        return ApiResponse.ok(null, "Plantilla eliminada");
    }
}
