package com.track60.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "configuracion_global")
public class AppConfigDocument {
    @Id
    private String id;

    @Builder.Default
    private List<String> areas = new ArrayList<>();

    @Builder.Default
    private List<String> categories = new ArrayList<>();
}
