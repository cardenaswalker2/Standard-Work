package com.track60.repository;

import com.track60.model.UserDocument;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.List;
import java.util.Optional;

public interface UserRepository extends MongoRepository<UserDocument, String> {
    Optional<UserDocument> findByCedula(String cedula);
    List<UserDocument> findByPlantId(String plantId);
    List<UserDocument> findByPlantIdAndRol(String plantId, String rol);
    boolean existsByCedula(String cedula);
}

