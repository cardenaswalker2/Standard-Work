package com.track60.controller;

import com.track60.dto.ApiResponse;
import com.track60.exception.ApiException;
import com.track60.model.ActivityDocument;
import com.track60.model.ActivityInstanceDocument;
import com.track60.model.CapacityRequestDocument;
import com.track60.repository.ActivityInstanceRepository;
import com.track60.repository.ActivityRepository;
import com.track60.repository.CapacityRequestRepository;
import com.track60.security.ScopeValidator;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;

@RestController
@RequestMapping("/api/v1/activities")
@RequiredArgsConstructor
@Tag(name = "Actividades e Instancias")
public class ActivityController {

    private final ActivityRepository activityRepository;
    private final ActivityInstanceRepository instanceRepository;
    private final CapacityRequestRepository capacityRequestRepository;
    private final ScopeValidator scope;

    @Value("${track60.capacity.plant-admin-base-limit:2}")
    private int plantAdminBaseLimit;

    @GetMapping
    public ApiResponse<List<ActivityDocument>> list(@RequestParam(required = false) String plantId) {
        var current = scope.currentUser();
        if (current.isSuperAdmin()) {
            return ApiResponse.ok(plantId != null ? activityRepository.findByPlantId(plantId) : activityRepository.findAll());
        }
        return ApiResponse.ok(activityRepository.findByPlantId(current.getPlantId()));
    }

    @PostMapping
    public ApiResponse<ActivityDocument> create(@RequestBody ActivityDocument activity) {
        scope.requireAdminOrSuperAdmin();
        var current = scope.currentUser();
        String targetPlant = current.isSuperAdmin() ? activity.getPlantId() : current.getPlantId();
        scope.requirePlantAccess(targetPlant);

        // Validación de capacidad en el backend (regla 2 base + ampliaciones aprobadas)
        if (!current.isSuperAdmin() && !activity.isEsGlobal()) {
            long currentLocalCount = activityRepository.countByPlantIdAndEsGlobalFalse(targetPlant);
            int extraApproved = capacityRequestRepository.findByPlantIdAndEstado(targetPlant, "Aprobada")
                    .stream().mapToInt(CapacityRequestDocument::getCuposSolicitados).sum();
            int allowed = plantAdminBaseLimit + extraApproved;
            if (currentLocalCount >= allowed) {
                throw ApiException.conflict("Capacidad de creación alcanzada (" + currentLocalCount + "/" + allowed + "). Solicita una ampliación al Super Admin.");
            }
        }

        activity.setPlantId(targetPlant);
        activity.setCreatedBy(current.getUserId());
        return ApiResponse.ok(activityRepository.save(activity), "Actividad creada");
    }

    @GetMapping("/instances")
    public ApiResponse<List<ActivityInstanceDocument>> listInstances(
            @RequestParam(required = false) String plantId,
            @RequestParam(defaultValue = "W1") String weekKey) {
        var current = scope.currentUser();
        if (current.isSuperAdmin()) {
            String target = plantId != null ? plantId : "PL-EXTRUSA";
            return ApiResponse.ok(instanceRepository.findByPlantIdAndWeekKey(target, weekKey));
        }
        if ("operador".equalsIgnoreCase(current.getRol())) {
            return ApiResponse.ok(instanceRepository.findByUserIdAndWeekKey(current.getUserId(), weekKey));
        }
        return ApiResponse.ok(instanceRepository.findByPlantIdAndWeekKey(current.getPlantId(), weekKey));
    }

    @PatchMapping("/instances/{id}/complete")
    public ApiResponse<ActivityInstanceDocument> completeInstance(
            @PathVariable String id,
            @RequestParam(required = false) String observaciones) {
        var current = scope.currentUser();
        ActivityInstanceDocument inst = instanceRepository.findById(id)
                .orElseThrow(() -> ApiException.notFound("Instancia no encontrada"));
        scope.requirePlantAccess(inst.getPlantId());
        if ("operador".equalsIgnoreCase(current.getRol()) && !inst.getUserId().equals(current.getUserId())) {
            throw ApiException.forbidden("No puedes completar actividades de otro colaborador");
        }
        inst.setDone(true);
        inst.setState("Reportada");
        inst.setCompletedAt(Instant.now());
        if (observaciones != null) {
            inst.setObservaciones(observaciones);
        }
        return ApiResponse.ok(instanceRepository.save(inst), "Actividad reportada");
    }
}

