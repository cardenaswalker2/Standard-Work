package com.track60.repository;

import com.track60.model.ActionPlanDocument;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.List;

public interface ActionPlanRepository extends MongoRepository<ActionPlanDocument, String> {
    List<ActionPlanDocument> findByPlantId(String plantId);
    List<ActionPlanDocument> findByResponsableId(String responsableId);
}

