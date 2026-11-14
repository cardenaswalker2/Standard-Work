package com.track60.repository;

import com.track60.model.PlantDocument;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.Optional;

public interface PlantRepository extends MongoRepository<PlantDocument, String> {
    Optional<PlantDocument> findByCodigo(String codigo);
    boolean existsByCodigo(String codigo);
}

