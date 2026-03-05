package com.enterprise.api.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import java.util.*;

@RestController
@RequestMapping("/api/v1")
public class ApiController {

    @GetMapping("/")
    public ResponseEntity<Map<String, Object>> getInfo() {
        Map<String, Object> info = new HashMap<>();
        info.put("name", "Enterprise Java API");
        info.put("version", "1.0.0");
        info.put("status", "running");
        info.put("timestamp", new Date());

        Map<String, String> endpoints = new HashMap<>();
        endpoints.put("info", "GET /api/v1/");
        endpoints.put("health", "GET /actuator/health");
        endpoints.put("metrics", "GET /actuator/metrics");
        info.put("endpoints", endpoints);

        return ResponseEntity.ok(info);
    }

    @GetMapping("/hello")
    public ResponseEntity<Map<String, String>> hello(@RequestParam(defaultValue = "World") String name) {
        Map<String, String> response = new HashMap<>();
        response.put("message", "Hello, " + name + "!");
        response.put("from", "Enterprise Java API");
        return ResponseEntity.ok(response);
    }
}
