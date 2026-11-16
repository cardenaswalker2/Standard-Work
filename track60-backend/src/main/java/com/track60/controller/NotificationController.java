package com.track60.controller;

import com.track60.dto.ApiResponse;
import com.track60.exception.ApiException;
import com.track60.model.NotificationDocument;
import com.track60.repository.NotificationRepository;
import com.track60.security.ScopeValidator;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
@Tag(name = "Notificaciones")
public class NotificationController {

    private final NotificationRepository repository;
    private final ScopeValidator scope;

    @GetMapping
    public ApiResponse<List<NotificationDocument>> list() {
        var current = scope.currentUser();
        return ApiResponse.ok(repository.findByTargetUserIdInOrderByCreatedAtDesc(
                List.of("ALL", current.getUserId())));
    }

    @PostMapping
    public ApiResponse<NotificationDocument> broadcast(@RequestBody BroadcastRequest req) {
        scope.requireSuperAdmin();
        if (req.getTitle() == null || req.getTitle().isBlank() || req.getMessage() == null || req.getMessage().isBlank()) {
            throw ApiException.badRequest("Título y mensaje son obligatorios");
        }
        NotificationDocument doc = NotificationDocument.builder()
                .targetUserId("ALL")
                .titulo(req.getTitle().trim())
                .mensaje(req.getMessage().trim())
                .tipo(req.getType() != null && !req.getType().isBlank() ? req.getType() : "INFO")
                .leida(false)
                .build();
        return ApiResponse.ok(repository.save(doc), "Comunicado emitido");
    }

    @Data
    public static class BroadcastRequest {
        private String title;
        private String message;
        private String type;
    }
}

