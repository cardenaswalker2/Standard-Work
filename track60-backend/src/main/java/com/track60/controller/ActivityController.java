package com.track60.controller;

import com.track60.dto.ApiResponse;
import com.track60.exception.ApiException;
import com.track60.model.ActivityDocument;
import com.track60.model.ActivityInstanceDocument;
import com.track60.model.CapacityRequestDocument;
import com.track60.model.SubtaskDocument;
import com.track60.repository.ActivityInstanceRepository;
import com.track60.repository.ActivityRepository;
import com.track60.repository.CapacityRequestRepository;
import com.track60.repository.SubtaskRepository;
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
    private final SubtaskRepository subtaskRepository;
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
            if (plantId == null || plantId.isBlank() || "ALL".equalsIgnoreCase(plantId)) {
                return ApiResponse.ok(instanceRepository.findByWeekKey(weekKey));
            }
            return ApiResponse.ok(instanceRepository.findByPlantIdAndWeekKey(plantId, weekKey));
        }
        if ("operador".equalsIgnoreCase(current.getRol())) {
            return ApiResponse.ok(instanceRepository.findByUserIdAndWeekKey(current.getUserId(), weekKey));
        }
        return ApiResponse.ok(instanceRepository.findByPlantIdAndWeekKey(current.getPlantId(), weekKey));
    }

    @PutMapping("/{id}")
    public ApiResponse<ActivityDocument> update(
            @PathVariable String id,
            @RequestBody ActivityDocument req) {
        scope.requireAdminOrSuperAdmin();
        ActivityDocument existing = activityRepository.findById(id)
                .orElseThrow(() -> ApiException.notFound("Actividad no encontrada"));
        scope.requirePlantAccess(existing.getPlantId());

        existing.setNombre(req.getNombre());
        existing.setDescripcion(req.getDescripcion());
        existing.setArea(req.getArea());
        existing.setCategory(req.getCategory());
        existing.setTimeStart(req.getTimeStart());
        existing.setTimeEnd(req.getTimeEnd());
        existing.setPrioridad(req.getPrioridad());
        existing.setDias(req.getDias());
        existing.setFija(req.isFija());
        existing.setReqFoto(req.isReqFoto());
        existing.setReqMedicion(req.isReqMedicion());
        existing.setReqComentario(req.isReqComentario());
        existing.setTipoActividad(req.getTipoActividad());
        existing.setRequierePlanAccion(req.isRequierePlanAccion());
        existing.setPlanAccionObligatorio(req.isPlanAccionObligatorio());
        existing.setInstrucciones(req.getInstrucciones());
        existing.setCriteriosCumplimiento(req.getCriteriosCumplimiento());
        if (req.getUserId() != null) existing.setUserId(req.getUserId());
        if (req.getPlantId() != null) existing.setPlantId(req.getPlantId());

        ActivityDocument saved = activityRepository.save(existing);

        List<ActivityInstanceDocument> instances = instanceRepository.findByActivityId(id);
        for (ActivityInstanceDocument inst : instances) {
            inst.setNombre(saved.getNombre());
            inst.setDescripcion(saved.getDescripcion());
            inst.setArea(saved.getArea());
            inst.setCategory(saved.getCategory());
            inst.setTimeStart(saved.getTimeStart());
            inst.setTimeEnd(saved.getTimeEnd());
            inst.setPrioridad(saved.getPrioridad());
            inst.setFija(saved.isFija());
            inst.setReqFoto(saved.isReqFoto());
            inst.setReqMedicion(saved.isReqMedicion());
            inst.setReqComentario(saved.isReqComentario());
            inst.setTipoActividad(saved.getTipoActividad());
            inst.setRequierePlanAccion(saved.isRequierePlanAccion());
            inst.setPlanAccionObligatorio(saved.isPlanAccionObligatorio());
            inst.setInstrucciones(saved.getInstrucciones());
            inst.setCriteriosCumplimiento(saved.getCriteriosCumplimiento());
        }
        if (!instances.isEmpty()) {
            instanceRepository.saveAll(instances);
        }
        return ApiResponse.ok(saved, "Actividad actualizada");
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable String id) {
        scope.requireAdminOrSuperAdmin();
        ActivityDocument existing = activityRepository.findById(id)
                .orElseThrow(() -> ApiException.notFound("Actividad no encontrada"));
        scope.requirePlantAccess(existing.getPlantId());
        subtaskRepository.deleteByActivityId(id);
        instanceRepository.deleteByActivityId(id);
        activityRepository.deleteById(id);
        return ApiResponse.ok(null, "Actividad eliminada");
    }

    @PostMapping("/instances/batch")
    public ApiResponse<List<ActivityInstanceDocument>> createInstancesBatch(
            @RequestBody List<ActivityInstanceDocument> instances) {
        scope.requireAdminOrSuperAdmin();
        var current = scope.currentUser();
        for (ActivityInstanceDocument inst : instances) {
            String targetPlant = current.isSuperAdmin() ? inst.getPlantId() : current.getPlantId();
            scope.requirePlantAccess(targetPlant);
            inst.setPlantId(targetPlant);
        }
        return ApiResponse.ok(instanceRepository.saveAll(instances), "Instancias sincronizadas");
    }

    @PutMapping("/instances/{id}")
    public ApiResponse<ActivityInstanceDocument> updateInstance(
            @PathVariable String id,
            @RequestBody ActivityInstanceDocument req) {
        ActivityInstanceDocument existing = instanceRepository.findById(id)
                .orElseThrow(() -> ApiException.notFound("Instancia no encontrada"));
        scope.requirePlantAccess(existing.getPlantId());
        existing.setDay(req.getDay());
        existing.setOrig(req.getOrig());
        existing.setUserId(req.getUserId());
        existing.setPlantId(req.getPlantId());
        existing.setDone(req.isDone());
        existing.setState(req.getState());
        existing.setObservaciones(req.getObservaciones());
        existing.setMotivoNoRealizada(req.getMotivoNoRealizada());
        existing.setSubtasksTotal(req.getSubtasksTotal());
        existing.setSubtasksReported(req.getSubtasksReported());
        existing.setSubtasksApproved(req.getSubtasksApproved());
        return ApiResponse.ok(instanceRepository.save(existing), "Instancia actualizada");
    }

    @DeleteMapping("/instances/{id}")
    public ApiResponse<Void> deleteInstance(@PathVariable String id) {
        scope.requireAdminOrSuperAdmin();
        ActivityInstanceDocument existing = instanceRepository.findById(id)
                .orElseThrow(() -> ApiException.notFound("Instancia no encontrada"));
        scope.requirePlantAccess(existing.getPlantId());
        instanceRepository.deleteById(id);
        return ApiResponse.ok(null, "Instancia eliminada");
    }

    @GetMapping("/subtasks")
    public ApiResponse<List<SubtaskDocument>> listSubtasks(@RequestParam(required = false) String activityId) {
        if (activityId != null && !activityId.isBlank()) {
            return ApiResponse.ok(subtaskRepository.findByActivityIdOrderByOrdenAsc(activityId));
        }
        return ApiResponse.ok(subtaskRepository.findAll());
    }

    @PostMapping("/{id}/subtasks/batch")
    public ApiResponse<List<SubtaskDocument>> replaceSubtasks(
            @PathVariable String id,
            @RequestBody List<SubtaskDocument> subtasks) {
        scope.requireAdminOrSuperAdmin();
        subtaskRepository.deleteByActivityId(id);
        for (SubtaskDocument st : subtasks) {
            st.setActivityId(id);
        }
        return ApiResponse.ok(subtaskRepository.saveAll(subtasks), "Subtareas sincronizadas");
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

