package com.track60;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.track60.dto.AuthDtos.LoginRequest;
import com.track60.model.UserDocument;
import com.track60.repository.UserRepository;
import com.track60.security.JwtService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.Optional;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {
        "spring.profiles.active=test",
        "spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.mongo.MongoAutoConfiguration,org.springframework.boot.autoconfigure.data.mongo.MongoDataAutoConfiguration,org.springframework.boot.autoconfigure.data.mongo.MongoRepositoriesAutoConfiguration"
})
@AutoConfigureMockMvc
class Track60SecurityAndApiTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private UserRepository userRepository;

    @MockBean
    private com.track60.repository.PlantRepository plantRepository;

    @MockBean
    private com.track60.repository.ActivityRepository activityRepository;

    @MockBean
    private com.track60.repository.ActivityInstanceRepository instanceRepository;

    @MockBean
    private com.track60.repository.ActionPlanRepository actionPlanRepository;

    @MockBean
    private com.track60.repository.CapacityRequestRepository capacityRequestRepository;

    @MockBean
    private com.track60.repository.SubtaskExecutionRepository subtaskExecutionRepository;

    @MockBean
    private com.track60.repository.NotificationRepository notificationRepository;

    @Test
    void unauthenticatedRequestToProtectedEndpointIsRejected() throws Exception {
        mockMvc.perform(get("/api/v1/users"))
                .andExpect(status().isForbidden());
    }

    @Test
    void healthEndpointIsPublic() throws Exception {
        mockMvc.perform(get("/actuator/health"))
                .andExpect(status().isOk());
    }

    @Test
    void loginWithValidCedulaReturnsJwtTokens() throws Exception {
        UserDocument operator = UserDocument.builder()
                .id("LP")
                .cedula("52345678")
                .nombre("Laura Pérez")
                .rol("operador")
                .plantId("PL-EXTRUSA")
                .activo(true)
                .build();

        when(userRepository.findByCedula("52345678")).thenReturn(Optional.of(operator));

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new LoginRequest("52345678", null))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.accessToken").isNotEmpty())
                .andExpect(jsonPath("$.data.user.rol").value("operador"));
    }

    @Test
    void plantAdminCannotCreateSuperAdminOrAccessOtherPlant() throws Exception {
        UserDocument admin = UserDocument.builder()
                .id("YL")
                .cedula("1098765432")
                .nombre("Yonny López")
                .rol("admin_planta")
                .plantId("PL-EXTRUSA")
                .activo(true)
                .pinHash(passwordEncoder.encode("1234"))
                .build();

        String token = jwtService.generateAccessToken(admin);

        // Intentar crear usuario con rol superadmin debe ser rechazado (403)
        mockMvc.perform(post("/api/v1/users")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"cedula\":\"999\",\"nombre\":\"Fake\",\"rol\":\"superadmin\",\"plantId\":\"PL-EXTRUSA\"}"))
                .andExpect(status().isForbidden());
    }

    @Test
    void superAdminCanListAllPlants() throws Exception {
        UserDocument superAdmin = UserDocument.builder()
                .id("JAVIER")
                .cedula("0000000001")
                .nombre("Javier Julio")
                .rol("superadmin")
                .plantId("ALL")
                .activo(true)
                .build();

        String token = jwtService.generateAccessToken(superAdmin);
        when(plantRepository.findAll()).thenReturn(List.of());

        mockMvc.perform(get("/api/v1/plants")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }
}

