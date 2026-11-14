package com.track60.controller;

import com.track60.dto.ApiResponse;
import com.track60.model.NotificationDocument;
import com.track60.repository.NotificationRepository;
import com.track60.security.ScopeValidator;
import io.swagger.v3.oas.annotations.tags.Tag;
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
}

