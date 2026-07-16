package com.vibeboot.starter;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = "com.vibeboot")
public class VibeBootApplication {

    public static void main(String[] args) {
        SpringApplication.run(VibeBootApplication.class, args);
    }
}
