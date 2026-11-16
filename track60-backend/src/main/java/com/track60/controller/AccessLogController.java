package com.track60.controller;

import com.track60.dto.ApiResponse;
import com.track60.exception.ApiException;
import com.track60.model.AccessLogDocument;
import com.track60.security.ScopeValidator;
import com.track60.service.AccessLogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/access-logs")
@RequiredArgsConstructor
@Tag(name = "Registro de Accesos", description = "Auditoría de IPs, ubicación aproximada y dispositivos")
public class AccessLogController {

    private final AccessLogService accessLogService;
    private final ScopeValidator scope;

    @GetMapping
    @Operation(summary = "Listar últimos 200 intentos de acceso (solo Ultra Admin)")
    public ApiResponse<List<AccessLogDocument>> list() {
        if (!scope.currentUser().isUltraAdmin()) {
            throw ApiException.forbidden("Solo Ultra Admin puede consultar el registro de accesos e IPs");
        }
        return ApiResponse.ok(accessLogService.getRecentLogs());
    }
}

