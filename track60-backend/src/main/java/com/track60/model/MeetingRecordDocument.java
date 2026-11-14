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
@Document(collection = "registros_informativos")
public class MeetingRecordDocument {
    @Id
    private String id;

    @Indexed
    private String instanceId;

    private String plantId;
    private String userId;
    private String titulo;
    private String asistentes;
    private String acuerdos;
    private String compromisos;
    private String observaciones;

    @CreatedDate
    private Instant createdAt;
}

