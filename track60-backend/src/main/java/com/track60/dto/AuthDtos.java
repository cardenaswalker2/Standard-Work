package com.track60.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

public class AuthDtos {

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class LoginRequest {
        /**
         * Puede ser cédula (colaborador) o PIN (directivo) o userId
         */
        @NotBlank(message = "El identificador o PIN es obligatorio")
        private String identifier;
        private String pin;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RefreshRequest {
        @NotBlank(message = "El refresh token es obligatorio")
        private String refreshToken;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserDto {
        private String id;
        private String cedula;
        private String nombre;
        private String cargo;
        private String area;
        private String iniciales;
        private String email;
        private boolean activo;
        private String rol;
        private String plantId;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AuthResponse {
        private String accessToken;
        private String refreshToken;
        private UserDto user;
    }
}

