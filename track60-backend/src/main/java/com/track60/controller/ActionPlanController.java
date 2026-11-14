package com.track60.controller;

import com.track60.dto.ApiResponse;
import com.track60.exception.ApiException;
import com.track60.model.ActionPlanDocument;
import com.track60.repository.ActionPlanRepository;
import com.track60.security.ScopeValidator;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/action-plans")
@RequiredArgsConstructor
@Tag(name = "Planes de Acción")
public class ActionPlanController {

    private final ActionPlanRepository planRepository;
    private final ScopeValidator scope;

    @GetMapping
    public ApiResponse<List<ActionPlanDocument>> list(@RequestParam(required = false) String plantId) {
        var current = scope.currentUser();
        if (current.isSuperAdmin()) {
            return ApiResponse.ok(plantId != null ? planRepository.findByPlantId(plantId) : planRepository.findAll());
        }
        return ApiResponse.ok(planRepository.findByPlantId(current.getPlantId()));
    }

    @PostMapping
    public ApiResponse<ActionPlanDocument> create(@RequestBody ActionPlanDocument plan) {
        var current = scope.currentUser();
        String targetPlant = current.isSuperAdmin() ? plan.getPlantId() : current.getPlantId();
        scope.requirePlantAccess(targetPlant);
        plan.setPlantId(targetPlant);
        return ApiResponse.ok(planRepository.save(plan), "Plan de acción creado");
    }

    @PatchMapping("/{id}/status")
    public ApiResponse<ActionPlanDocument> updateStatus(
            @PathVariable String id,
            @RequestParam String estado,
            @RequestParam(required = false) String observaciones) {
        ActionPlanDocument plan = planRepository.findById(id)
                .orElseThrow(() -> ApiException.notFound("Plan de acción no encontrado"));
        scope.requirePlantAccess(plan.getPlantId());
        plan.setEstado(estado);
        if (observaciones != null) {
            plan.setObservaciones(observaciones);
        }
        return ApiResponse.ok(planRepository.save(plan), "Estado del plan actualizado");
    }
}

