package com.track60.repository;

import com.track60.model.NotificationDocument;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.List;

public interface NotificationRepository extends MongoRepository<NotificationDocument, String> {
    List<NotificationDocument> findByTargetUserIdInOrderByCreatedAtDesc(List<String> targets);
}

