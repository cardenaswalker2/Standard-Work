package com.track60.repository;

import com.track60.model.SubtaskExecutionDocument;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.List;

public interface SubtaskExecutionRepository extends MongoRepository<SubtaskExecutionDocument, String> {
    List<SubtaskExecutionDocument> findByInstanceId(String instanceId);
    List<SubtaskExecutionDocument> findByPlantIdAndEstadoValidacion(String plantId, String estadoValidacion);
}

