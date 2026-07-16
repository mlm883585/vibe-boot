package com.vibeboot.starter;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalManagementPort;
import org.springframework.boot.test.web.server.LocalServerPort;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = {
                "management.server.address=127.0.0.1",
                "management.server.port=0"
        })
class VibeBootApplicationTests {

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(5))
            .build();

    @LocalServerPort
    private int serverPort;

    @LocalManagementPort
    private int managementPort;

    @Test
    void exposesStandardLivenessAndReadinessOnManagementPort() throws Exception {
        assertHealthUp("/actuator/health/liveness");
        assertHealthUp("/actuator/health/readiness");
    }

    @Test
    void doesNotExposeActuatorOnBusinessPort() throws Exception {
        HttpResponse<String> response = get(serverPort, "/actuator/health");

        assertEquals(404, response.statusCode());
    }

    @Test
    void exposesOnlyHealthManagementEndpoints() throws Exception {
        HttpResponse<String> response = get(managementPort, "/actuator/env");

        assertEquals(404, response.statusCode());
    }

    private void assertHealthUp(String path) throws Exception {
        HttpResponse<String> response = get(managementPort, path);

        assertEquals(200, response.statusCode());
        assertEquals("{\"status\":\"UP\"}", response.body());
    }

    private HttpResponse<String> get(int port, String path) throws IOException, InterruptedException {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("http://127.0.0.1:" + port + path))
                .timeout(Duration.ofSeconds(5))
                .GET()
                .build();
        return httpClient.send(request, HttpResponse.BodyHandlers.ofString());
    }
}
