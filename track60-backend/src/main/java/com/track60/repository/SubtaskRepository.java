package com.track60.repository;

import com.track60.model.SubtaskDocument;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.List;

public interface SubtaskRepository extends MongoRepository<SubtaskDocument, String> {
    List<SubtaskDocument> findByActivityIdOrderByOrdenAsc(String activityId);
    void deleteByActivityId(String activityId);
}

