package com.track60.repository;

import com.track60.model.ActivityDocument;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.List;

public interface ActivityRepository extends MongoRepository<ActivityDocument, String> {
    List<ActivityDocument> findByPlantId(String plantId);
    List<ActivityDocument> findByEsGlobalTrue();
    long countByPlantIdAndEsGlobalFalse(String plantId);
}

