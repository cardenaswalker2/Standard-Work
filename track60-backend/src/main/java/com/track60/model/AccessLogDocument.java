package com.track60.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "access_logs")
public class AccessLogDocument {
    @Id
    private String id;

    @Indexed
    private String userId;

    private String userNombre;
    private String identifier;
    private String rol;
    private String plantId;

    private boolean success;
    private String failureReason;

    @Indexed
    private String ipAddress;
    private String city;
    private String region;
    private String country;
    private String isp;

    private String deviceType;
    private String os;
    private String browser;
    private String userAgent;

    @CreatedDate
    @Indexed
    private Instant createdAt;
}

