package com.track60.controller;

import com.track60.dto.ApiResponse;
import com.track60.dto.AuthDtos.UserDto;
import com.track60.exception.ApiException;
import com.track60.model.UserDocument;
import com.track60.repository.UserRepository;
import com.track60.security.ScopeValidator;
import com.track60.service.AuthService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Tag(name = "Usuarios")
public class UserController {

    private final UserRepository userRepository;
    private final ScopeValidator scope;
    private final PasswordEncoder passwordEncoder;

    @GetMapping
    public ApiResponse<List<UserDto>> list(@RequestParam(required = false) String plantId) {
        var current = scope.currentUser();
        List<UserDocument> users;
        if (current.isSuperAdmin()) {
            users = (plantId != null && !plantId.isBlank())
                    ? userRepository.findByPlantId(plantId)
                    : userRepository.findAll();
        } else {
            users = userRepository.findByPlantId(current.getPlantId());
        }
        return ApiResponse.ok(users.stream().map(AuthService::toDto).toList());
    }

    @PostMapping
    public ApiResponse<UserDto> create(@RequestBody CreateUserRequest req) {
        scope.requireAdminOrSuperAdmin();
        var current = scope.currentUser();
        String targetPlant = current.isSuperAdmin() ? req.getPlantId() : current.getPlantId();
        scope.requirePlantAccess(targetPlant);

        if ("superadmin".equalsIgnoreCase(req.getRol()) && !current.isSuperAdmin()) {
            throw ApiException.forbidden("No puedes crear usuarios Super Admin");
        }
        if (userRepository.existsByCedula(req.getCedula())) {
            throw ApiException.conflict("Ya existe un usuario con esa cédula");
        }

        UserDocument doc = UserDocument.builder()
                .cedula(req.getCedula().trim())
                .nombre(req.getNombre().trim())
                .cargo(req.getCargo())
                .area(req.getArea())
                .iniciales(req.getIniciales())
                .email(req.getEmail())
                .rol(req.getRol() != null ? req.getRol() : "operador")
                .plantId(targetPlant)
                .activo(true)
                .pinHash(req.getPin() != null && !req.getPin().isBlank()
                        ? passwordEncoder.encode(req.getPin().trim()) : null)
                .build();

        return ApiResponse.ok(AuthService.toDto(userRepository.save(doc)), "Usuario creado");
    }

    @PatchMapping("/{id}/status")
    public ApiResponse<UserDto> toggleStatus(@PathVariable String id, @RequestParam boolean activo) {
        scope.requireAdminOrSuperAdmin();
        UserDocument user = userRepository.findById(id)
                .orElseThrow(() -> ApiException.notFound("Usuario no encontrado"));
        scope.requirePlantAccess(user.getPlantId());
        user.setActivo(activo);
        return ApiResponse.ok(AuthService.toDto(userRepository.save(user)), "Estado actualizado");
    }

    @Data
    public static class CreateUserRequest {
        private String cedula;
        private String nombre;
        private String cargo;
        private String area;
        private String iniciales;
        private String email;
        private String rol;
        private String plantId;
        private String pin;
    }
}

