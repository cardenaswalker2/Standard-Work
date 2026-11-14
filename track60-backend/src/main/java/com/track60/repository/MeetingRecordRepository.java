package com.track60.repository;

import com.track60.model.MeetingRecordDocument;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.Optional;

public interface MeetingRecordRepository extends MongoRepository<MeetingRecordDocument, String> {
    Optional<MeetingRecordDocument> findByInstanceId(String instanceId);
}

