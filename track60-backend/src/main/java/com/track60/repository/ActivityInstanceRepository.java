package com.track60.repository;

import com.track60.model.ActivityInstanceDocument;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.List;

public interface ActivityInstanceRepository extends MongoRepository<ActivityInstanceDocument, String> {
    List<ActivityInstanceDocument> findByPlantIdAndWeekKey(String plantId, String weekKey);
    List<ActivityInstanceDocument> findByUserIdAndWeekKey(String userId, String weekKey);
    List<ActivityInstanceDocument> findByPlantId(String plantId);
}

