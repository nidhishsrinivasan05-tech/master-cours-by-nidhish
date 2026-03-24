package com.example.app.service;

import com.example.app.dto.HealthResponse;
import org.springframework.stereotype.Service;

@Service
public class HealthService {
    public HealthResponse getHealth() {
        return new HealthResponse("ok", "java-service-package");
    }
}
