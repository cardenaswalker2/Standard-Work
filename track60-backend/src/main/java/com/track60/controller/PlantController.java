package com.track60.controller;

import com.track60.dto.ApiResponse;
import com.track60.exception.ApiException;
import com.track60.model.PlantDocument;
import com.track60.repository.PlantRepository;
import com.track60.security.ScopeValidator;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/plants")
@RequiredArgsConstructor
@Tag(name = "Plantas / Procesos")
public class PlantController {

    private final PlantRepository plantRepository;
    private final ScopeValidator scope;

    @GetMapping
    public ApiResponse<List<PlantDocument>> list() {
        var user = scope.currentUser();
        if (user.isSuperAdmin()) {
            return ApiResponse.ok(plantRepository.findAll());
        }
        return ApiResponse.ok(plantRepository.findById(user.getPlantId()).map(List::of).orElse(List.of()));
    }

    @PostMapping
    public ApiResponse<PlantDocument> create(@Valid @RequestBody PlantDocument plant) {
        scope.requireSuperAdmin();
        if (plant.getCodigo() != null && plantRepository.existsByCodigo(plant.getCodigo())) {
            throw ApiException.conflict("Ya existe una planta/proceso con ese código");
        }
        if (plant.getId() == null || plant.getId().isBlank()) {
            plant.setId(plant.getCodigo());
        }
        return ApiResponse.ok(plantRepository.save(plant), "Proceso creado");
    }

    @PutMapping("/{id}")
    public ApiResponse<PlantDocument> update(@PathVariable String id, @RequestBody PlantDocument req) {
        scope.requireSuperAdmin();
        PlantDocument existing = plantRepository.findById(id)
                .orElseThrow(() -> ApiException.notFound("Proceso no encontrado"));
        existing.setNombre(req.getNombre());
        existing.setDescripcion(req.getDescripcion());
        existing.setAreas(req.getAreas());
        existing.setActiva(req.isActiva());
        return ApiResponse.ok(plantRepository.save(existing), "Proceso actualizado");
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable String id) {
        scope.requireSuperAdmin();
        if (!plantRepository.existsById(id)) {
            throw ApiException.notFound("Proceso no encontrado");
        }
        plantRepository.deleteById(id);
        return ApiResponse.ok(null, "Proceso eliminado");
    }
}

