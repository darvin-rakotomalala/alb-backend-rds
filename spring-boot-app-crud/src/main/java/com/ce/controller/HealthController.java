package com.ce.controller;

import io.swagger.v3.oas.annotations.Operation;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import software.amazon.awssdk.imds.Ec2MetadataClient;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
public class HealthController {

    @Operation(summary = "Health Check Endpoint")
    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> healthCheck() {
        Map<String, String> response = new HashMap<>();
        // EC2 instance details (IMDS)
        try (Ec2MetadataClient imds = Ec2MetadataClient.create()) {

            String instanceId = imds.get("/latest/meta-data/instance-id").asString();
            String privateIp = imds.get("/latest/meta-data/local-ipv4").asString();
            String az = imds.get("/latest/meta-data/placement/availability-zone").asString();

            response.put("Status", "UP");
            response.put("Message", "Spring Boot AWS CRUD Application is running");
            response.put("EC2 instance ID: {}", instanceId);
            response.put("EC2 private IP: {}", privateIp);
            response.put("Availability zone: {}", az);
        } catch (Exception e) {
            log.warn("Not running on EC2 or IMDS unreachable: {}", e.getMessage());
        }
        return ResponseEntity.ok(response);
    }
}
