package com.track60.controller;

import com.track60.dto.ApiResponse;
import com.track60.exception.ApiException;
import com.track60.model.CapacityRequestDocument;
import com.track60.repository.CapacityRequestRepository;
import com.track60.security.ScopeValidator;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;

@RestController
@RequestMapping("/api/v1/capacity-requests")
@RequiredArgsConstructor
@Tag(name = "Solicitudes de Capacidad")
public class CapacityRequestController {

    private final CapacityRequestRepository repository;
    private final ScopeValidator scope;

    @GetMapping
    public ApiResponse<List<CapacityRequestDocument>> list() {
        var current = scope.currentUser();
        if (current.isSuperAdmin()) {
            return ApiResponse.ok(repository.findAll());
        }
        return ApiResponse.ok(repository.findByPlantId(current.getPlantId()));
    }

    @PostMapping
    public ApiResponse<CapacityRequestDocument> create(@RequestBody CapacityRequestDocument req) {
        scope.requireAdminOrSuperAdmin();
        var current = scope.currentUser();
        req.setPlantId(current.isSuperAdmin() ? req.getPlantId() : current.getPlantId());
        req.setRequesterId(current.getUserId());
        req.setRequesterNombre(current.getNombre());
        req.setEstado("Pendiente");
        return ApiResponse.ok(repository.save(req), "Solicitud de ampliación enviada");
    }

    @PatchMapping("/{id}/review")
    public ApiResponse<CapacityRequestDocument> review(
            @PathVariable String id,
            @RequestParam boolean approve,
            @RequestParam(required = false) String comentario) {
        scope.requireSuperAdmin();
        CapacityRequestDocument req = repository.findById(id)
                .orElseThrow(() -> ApiException.notFound("Solicitud no encontrada"));
        req.setEstado(approve ? "Aprobada" : "Rechazada");
        req.setReviewedBy(scope.currentUser().getUserId());
        req.setComentarioRevision(comentario);
        req.setFechaRevision(Instant.now());
        return ApiResponse.ok(repository.save(req), approve ? "Capacidad ampliada" : "Solicitud rechazada");
    }
}

