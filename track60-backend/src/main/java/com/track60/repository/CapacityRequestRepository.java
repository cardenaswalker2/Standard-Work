package com.track60.repository;

import com.track60.model.CapacityRequestDocument;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.List;

public interface CapacityRequestRepository extends MongoRepository<CapacityRequestDocument, String> {
    List<CapacityRequestDocument> findByPlantId(String plantId);
    List<CapacityRequestDocument> findByPlantIdAndEstado(String plantId, String estado);
    List<CapacityRequestDocument> findByEstado(String estado);
}

