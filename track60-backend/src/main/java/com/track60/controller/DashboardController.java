package com.track60.controller;

import com.track60.dto.ApiResponse;
import com.track60.model.ActivityInstanceDocument;
import com.track60.repository.ActionPlanRepository;
import com.track60.repository.ActivityInstanceRepository;
import com.track60.repository.UserRepository;
import com.track60.security.ScopeValidator;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/dashboard")
@RequiredArgsConstructor
@Tag(name = "Dashboard & Indicadores")
public class DashboardController {

    private final ActivityInstanceRepository instanceRepository;
    private final ActionPlanRepository planRepository;
    private final UserRepository userRepository;
    private final ScopeValidator scope;

    @GetMapping("/summary")
    public ApiResponse<Map<String, Object>> summary(@RequestParam(required = false) String plantId) {
        var current = scope.currentUser();
        String targetPlant = current.isSuperAdmin() && plantId != null ? plantId : current.getPlantId();

        List<ActivityInstanceDocument> instances = "ALL".equals(targetPlant)
                ? instanceRepository.findAll()
                : instanceRepository.findByPlantId(targetPlant);

        long total = instances.size();
        long completed = instances.stream().filter(ActivityInstanceDocument::isDone).count();
        long pending = total - completed;
        double compliancePct = total == 0 ? 0.0 : Math.round((completed * 1000.0) / total) / 10.0;

        long openPlans = ("ALL".equals(targetPlant)
                ? planRepository.findAll()
                : planRepository.findByPlantId(targetPlant))
                .stream().filter(p -> !"Cerrado".equalsIgnoreCase(p.getEstado())).count();

        long activeUsers = ("ALL".equals(targetPlant)
                ? userRepository.findAll()
                : userRepository.findByPlantId(targetPlant))
                .stream().filter(u -> u.isActivo()).count();

        return ApiResponse.ok(Map.of(
                "plantId", targetPlant,
                "totalActivities", total,
                "completedActivities", completed,
                "pendingActivities", pending,
                "compliancePercentage", compliancePct,
                "openActionPlans", openPlans,
                "activeUsers", activeUsers
        ));
    }
}

