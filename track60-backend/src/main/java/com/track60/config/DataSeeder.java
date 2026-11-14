package com.track60.config;

import com.track60.model.PlantDocument;
import com.track60.model.UserDocument;
import com.track60.repository.PlantRepository;
import com.track60.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PlantRepository plantRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        if (plantRepository.count() == 0) {
            plantRepository.saveAll(List.of(
                    PlantDocument.builder()
                            .id("PL-EXTRUSA")
                            .codigo("PL-EXTRUSA")
                            .nombre("Planta Extrusa")
                            .descripcion("Proceso de Extrusión")
                            .colorHex("#002F6C")
                            .areas(List.of("Extrusión", "Calidad", "Logística", "Mantenimiento"))
                            .capacidadBaseLocal(2)
                            .build(),
                    PlantDocument.builder()
                            .id("PL-TERMO")
                            .codigo("PL-TERMO")
                            .nombre("Planta Termoformado")
                            .descripcion("Proceso de Termoformado")
                            .colorHex("#0284C7")
                            .areas(List.of("Termoformado", "Calidad", "Empaque"))
                            .capacidadBaseLocal(2)
                            .build()
            ));
            log.info("Plantas iniciales sembradas en MongoDB");
        }

        if (userRepository.count() == 0) {
            userRepository.saveAll(List.of(
                    UserDocument.builder()
                            .id("JAVIER")
                            .cedula("0000000001")
                            .nombre("Javier Julio")
                            .cargo("Superadministrador General")
                            .area("Dirección Corporativa")
                            .iniciales("JJ")
                            .email("javier.julio@darnel.com")
                            .activo(true)
                            .rol("superadmin")
                            .plantId("ALL")
                            .pinHash(passwordEncoder.encode("1428"))
                            .build(),
                    UserDocument.builder()
                            .id("YL")
                            .cedula("1098765432")
                            .nombre("Yonny López")
                            .cargo("Jefe de Planta / Operaciones")
                            .area("Dirección de Planta")
                            .iniciales("YL")
                            .email("yonny.lopez@darnel.com")
                            .activo(true)
                            .rol("admin_planta")
                            .plantId("PL-EXTRUSA")
                            .pinHash(passwordEncoder.encode("1234"))
                            .build(),
                    UserDocument.builder()
                            .id("CM")
                            .cedula("1045678901")
                            .nombre("Carlos Méndez")
                            .cargo("Supervisor de Turno")
                            .area("Extrusión")
                            .iniciales("CM")
                            .email("carlos.mendez@darnel.com")
                            .activo(true)
                            .rol("supervisor")
                            .plantId("PL-EXTRUSA")
                            .pinHash(passwordEncoder.encode("3344"))
                            .build(),
                    UserDocument.builder()
                            .id("LP")
                            .cedula("52345678")
                            .nombre("Laura Pérez")
                            .cargo("Operadora de Extrusión")
                            .area("Extrusión")
                            .iniciales("LP")
                            .email("laura.perez@darnel.com")
                            .activo(true)
                            .rol("operador")
                            .plantId("PL-EXTRUSA")
                            .build()
            ));
            log.info("Usuarios base sembrados con PIN cifrado BCrypt");
        }
    }
}

