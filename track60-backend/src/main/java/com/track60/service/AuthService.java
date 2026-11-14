package com.track60.service;

import com.track60.dto.AuthDtos.*;
import com.track60.exception.ApiException;
import com.track60.model.UserDocument;
import com.track60.repository.UserRepository;
import com.track60.security.JwtService;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;

    public AuthResponse login(LoginRequest req) {
        String id = req.getIdentifier().trim();
        UserDocument user = userRepository.findByCedula(id)
                .or(() -> userRepository.findById(id.toUpperCase()))
                .orElse(null);

        // Si no encontró por cédula/ID, buscar directivo cuyo PIN coincida
        if (user == null) {
            user = userRepository.findAll().stream()
                    .filter(u -> u.isActivo() && !"operador".equalsIgnoreCase(u.getRol()))
                    .filter(u -> u.getPinHash() != null && passwordEncoder.matches(id, u.getPinHash()))
                    .findFirst()
                    .orElse(null);
        } else if (!"operador".equalsIgnoreCase(user.getRol()) && req.getPin() != null && !req.getPin().isBlank()) {
            if (user.getPinHash() == null || !passwordEncoder.matches(req.getPin().trim(), user.getPinHash())) {
                throw ApiException.unauthorized("PIN incorrecto");
            }
        }

        if (user == null || !user.isActivo()) {
            throw ApiException.unauthorized("Credenciales inválidas o usuario inactivo");
        }

        return AuthResponse.builder()
                .accessToken(jwtService.generateAccessToken(user))
                .refreshToken(jwtService.generateRefreshToken(user))
                .user(toDto(user))
                .build();
    }

    public AuthResponse refresh(RefreshRequest req) {
        if (!jwtService.isValid(req.getRefreshToken())) {
            throw ApiException.unauthorized("Refresh token inválido o expirado");
        }
        Claims claims = jwtService.parseClaims(req.getRefreshToken());
        if (!"refresh".equals(claims.get("type", String.class))) {
            throw ApiException.unauthorized("Tipo de token inválido");
        }
        UserDocument user = userRepository.findById(claims.getSubject())
                .orElseThrow(() -> ApiException.unauthorized("Usuario no encontrado"));
        if (!user.isActivo()) {
            throw ApiException.unauthorized("Usuario inactivo");
        }
        return AuthResponse.builder()
                .accessToken(jwtService.generateAccessToken(user))
                .refreshToken(jwtService.generateRefreshToken(user))
                .user(toDto(user))
                .build();
    }

    public static UserDto toDto(UserDocument u) {
        return UserDto.builder()
                .id(u.getId())
                .cedula(u.getCedula())
                .nombre(u.getNombre())
                .cargo(u.getCargo())
                .area(u.getArea())
                .iniciales(u.getIniciales())
                .email(u.getEmail())
                .activo(u.isActivo())
                .rol(u.getRol())
                .plantId(u.getPlantId())
                .build();
    }
}

