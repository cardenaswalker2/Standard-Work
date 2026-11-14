package com.track60.repository;

import com.track60.model.AuditLogDocument;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.List;

public interface AuditLogRepository extends MongoRepository<AuditLogDocument, String> {
    List<AuditLogDocument> findTop100ByOrderByCreatedAtDesc();
    List<AuditLogDocument> findTop100ByPlantIdOrderByCreatedAtDesc(String plantId);
}

