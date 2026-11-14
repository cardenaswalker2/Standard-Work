package com.track60.repository;

import com.track60.model.ActivityTemplateDocument;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface ActivityTemplateRepository extends MongoRepository<ActivityTemplateDocument, String> {
}

