package com.track60.controller;

import com.track60.dto.ApiResponse;
import com.track60.exception.ApiException;
import com.track60.model.SubtaskExecutionDocument;
import com.track60.repository.SubtaskExecutionRepository;
import com.track60.security.ScopeValidator;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/evidence")
@RequiredArgsConstructor
@Tag(name = "Evidencias y Fotografías")
public class EvidenceController {

    private final SubtaskExecutionRepository repository;
    private final ScopeValidator scope;

    @GetMapping("/pending")
    public ApiResponse<List<SubtaskExecutionDocument>> pending(@RequestParam(required = false) String plantId) {
        var current = scope.currentUser();
        String target = current.isSuperAdmin() && plantId != null ? plantId : current.getPlantId();
        return ApiResponse.ok(repository.findByPlantIdAndEstadoValidacion(target, "Reportada"));
    }

    @PostMapping("/report")
    public ApiResponse<SubtaskExecutionDocument> report(@RequestBody SubtaskExecutionDocument doc) {
        var current = scope.currentUser();
        doc.setPlantId(current.isSuperAdmin() ? doc.getPlantId() : current.getPlantId());
        doc.setUserId(current.getUserId());
        doc.setCompletada(true);
        doc.setEstadoValidacion("Reportada");
        doc.setFechaReporte(Instant.now());
        return ApiResponse.ok(repository.save(doc), "Evidencia registrada");
    }

    @PatchMapping("/{id}/validate")
    public ApiResponse<SubtaskExecutionDocument> validate(
            @PathVariable String id,
            @RequestParam boolean approve,
            @RequestParam(required = false) String comentario) {
        var current = scope.currentUser();
        if ("operador".equalsIgnoreCase(current.getRol())) {
            throw ApiException.forbidden("Solo supervisores o administradores pueden validar evidencias");
        }
        SubtaskExecutionDocument doc = repository.findById(id)
                .orElseThrow(() -> ApiException.notFound("Evidencia no encontrada"));
        scope.requirePlantAccess(doc.getPlantId());
        doc.setEstadoValidacion(approve ? "Aprobada" : "Rechazada");
        doc.setSupervisorId(current.getUserId());
        doc.setComentarioSupervisor(comentario);
        doc.setFechaValidacion(Instant.now());
        return ApiResponse.ok(repository.save(doc), approve ? "Evidencia aprobada" : "Evidencia rechazada");
    }

    @PostMapping("/upload-signature")
    public ApiResponse<Map<String, String>> uploadSignature(@RequestParam String filename) {
        var current = scope.currentUser();
        String safeName = filename.replaceAll("[^a-zA-Z0-9._-]", "_");
        return ApiResponse.ok(Map.of(
                "folder", "track60/" + current.getPlantId(),
                "publicId", current.getUserId() + "_" + System.currentTimeMillis() + "_" + safeName
        ), "Autorización de carga generada");
    }
}

