package com.track60.controller;

import com.track60.dto.ApiResponse;
import com.track60.dto.AuthDtos.*;
import com.track60.repository.UserRepository;
import com.track60.security.ScopeValidator;
import com.track60.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Autenticación", description = "Login, refresh JWT y perfil autenticado")
public class AuthController {

    private final AuthService authService;
    private final ScopeValidator scope;
    private final UserRepository userRepository;

    @PostMapping("/login")
    @Operation(summary = "Iniciar sesión con cédula o PIN directivo")
    public ApiResponse<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.ok(authService.login(request), "Inicio de sesión exitoso");
    }

    @PostMapping("/refresh")
    @Operation(summary = "Renovar token de acceso")
    public ApiResponse<AuthResponse> refresh(@Valid @RequestBody RefreshRequest request) {
        return ApiResponse.ok(authService.refresh(request), "Token renovado");
    }

    @GetMapping("/me")
    @Operation(summary = "Obtener perfil del usuario autenticado")
    public ApiResponse<UserDto> me() {
        String userId = scope.currentUser().getUserId();
        return userRepository.findById(userId)
                .map(AuthService::toDto)
                .map(ApiResponse::ok)
                .orElseThrow();
    }
}

