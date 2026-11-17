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

    @PatchMapping("/{id}/reset-pin")
    public ApiResponse<UserDto> resetPin(@PathVariable String id, @RequestBody ResetPinRequest req) {
        scope.requireSuperAdmin();
        if (req.getPin() == null || req.getPin().trim().length() < 4) {
            throw ApiException.badRequest("El PIN debe tener al menos 4 dígitos");
        }
        UserDocument user = userRepository.findById(id)
                .orElseThrow(() -> ApiException.notFound("Usuario no encontrado"));
        user.setPinHash(passwordEncoder.encode(req.getPin().trim()));
        return ApiResponse.ok(AuthService.toDto(userRepository.save(user)), "PIN actualizado");
    }

    @PatchMapping("/{id}/role")
    public ApiResponse<UserDto> updateRoleAndPlant(@PathVariable String id, @RequestBody UpdateRoleRequest req) {
        if (!scope.currentUser().isUltraAdmin()) {
            throw ApiException.forbidden("Solo el Ultra Admin puede reasignar roles globales");
        }
        UserDocument user = userRepository.findById(id)
                .orElseThrow(() -> ApiException.notFound("Usuario no encontrado"));
        if (req.getRol() != null && !req.getRol().isBlank()) {
            user.setRol(req.getRol().trim());
        }
        if (req.getPlantId() != null && !req.getPlantId().isBlank()) {
            user.setPlantId(req.getPlantId().trim());
        }
        return ApiResponse.ok(AuthService.toDto(userRepository.save(user)), "Rol y planta actualizados");
    }

    @PutMapping("/{id}")
    public ApiResponse<UserDto> updateUser(@PathVariable String id, @RequestBody UpdateUserRequest req) {
        scope.requireAdminOrSuperAdmin();
        var current = scope.currentUser();
        UserDocument user = userRepository.findById(id)
                .orElseThrow(() -> ApiException.notFound("Usuario no encontrado"));

        if (!current.isSuperAdmin()) {
            scope.requirePlantAccess(user.getPlantId());
            if ("ultra_admin".equalsIgnoreCase(user.getRol()) || "superadmin".equalsIgnoreCase(user.getRol())) {
                throw ApiException.forbidden("No puedes editar cuentas corporativas");
            }
        }

        if (req.getCedula() != null && !req.getCedula().isBlank()) {
            String newCedula = req.getCedula().trim();
            if (!newCedula.equals(user.getCedula()) && userRepository.existsByCedula(newCedula)) {
                throw ApiException.conflict("Ya existe otro usuario con esa cédula");
            }
            user.setCedula(newCedula);
        }
        if (req.getNombre() != null && !req.getNombre().isBlank()) {
            user.setNombre(req.getNombre().trim());
        }
        if (req.getCargo() != null) {
            user.setCargo(req.getCargo().trim());
        }
        if (req.getArea() != null) {
            user.setArea(req.getArea().trim());
        }
        if (req.getIniciales() != null) {
            user.setIniciales(req.getIniciales().trim());
        }
        if (req.getEmail() != null) {
            user.setEmail(req.getEmail().trim().isEmpty() ? null : req.getEmail().trim());
        }
        if (req.getRol() != null && !req.getRol().isBlank()) {
            if ("ultra_admin".equalsIgnoreCase(req.getRol()) && !current.isUltraAdmin()) {
                throw ApiException.forbidden("Solo Ultra Admin puede asignar el rol Ultra Admin");
            }
            if ("superadmin".equalsIgnoreCase(req.getRol()) && !current.isSuperAdmin()) {
                throw ApiException.forbidden("Solo Super Admin puede asignar el rol Super Admin");
            }
            user.setRol(req.getRol().trim());
        }
        if (req.getPlantId() != null && !req.getPlantId().isBlank() && current.isSuperAdmin()) {
            user.setPlantId(req.getPlantId().trim());
        }
        if (req.getActivo() != null) {
            user.setActivo(req.getActivo());
        }
        if (req.getPin() != null && !req.getPin().trim().isEmpty()) {
            if (req.getPin().trim().length() < 4) {
                throw ApiException.badRequest("El PIN debe tener al menos 4 dígitos");
            }
            user.setPinHash(passwordEncoder.encode(req.getPin().trim()));
        }

        return ApiResponse.ok(AuthService.toDto(userRepository.save(user)), "Usuario actualizado completamente");
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteUser(@PathVariable String id) {
        scope.requireAdminOrSuperAdmin();
        var current = scope.currentUser();
        if (id.equals(current.getUserId())) {
            throw ApiException.badRequest("No puedes eliminar tu propia cuenta");
        }
        UserDocument user = userRepository.findById(id)
                .orElseThrow(() -> ApiException.notFound("Usuario no encontrado"));
        if (!current.isSuperAdmin()) {
            scope.requirePlantAccess(user.getPlantId());
            if ("ultra_admin".equalsIgnoreCase(user.getRol()) || "superadmin".equalsIgnoreCase(user.getRol())) {
                throw ApiException.forbidden("No puedes eliminar cuentas corporativas");
            }
        } else if (!current.isUltraAdmin() && "ultra_admin".equalsIgnoreCase(user.getRol())) {
            throw ApiException.forbidden("Solo Ultra Admin puede eliminar cuentas Ultra Admin");
        }
        userRepository.deleteById(id);
        return ApiResponse.ok(null, "Usuario eliminado");
    }

    @Data
    public static class UpdateUserRequest {
        private String cedula;
        private String nombre;
        private String cargo;
        private String area;
        private String iniciales;
        private String email;
        private String rol;
        private String plantId;
        private Boolean activo;
        private String pin;
    }

    @Data
    public static class ResetPinRequest {
        private String pin;
    }

    @Data
    public static class UpdateRoleRequest {
        private String rol;
        private String plantId;
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

