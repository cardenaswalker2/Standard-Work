package com.track60.repository;

import com.track60.model.AccessLogDocument;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface AccessLogRepository extends MongoRepository<AccessLogDocument, String> {
    List<AccessLogDocument> findTop200ByOrderByCreatedAtDesc();
}

