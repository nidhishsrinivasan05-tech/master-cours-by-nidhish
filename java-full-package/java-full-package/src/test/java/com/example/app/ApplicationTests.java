package com.example.app;

import com.example.app.controller.HealthController;
import com.example.app.service.HealthService;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class ApplicationTests {
    @Test
    void healthServiceReturnsOk() {
        HealthService service = new HealthService();
        assertEquals("ok", service.getHealth().status());
    }

    @Test
    void controllerDelegates() {
        HealthController controller = new HealthController(new HealthService());
        assertEquals("java-service-package", controller.health().service());
    }
}
