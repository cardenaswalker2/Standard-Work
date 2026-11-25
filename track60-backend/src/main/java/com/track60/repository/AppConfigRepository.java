package com.track60.repository;

import com.track60.model.AppConfigDocument;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface AppConfigRepository extends MongoRepository<AppConfigDocument, String> {
}
