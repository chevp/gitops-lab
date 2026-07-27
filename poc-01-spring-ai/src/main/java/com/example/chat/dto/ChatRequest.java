package com.example.chat.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Provider-neutral chat request. Carries no vendor-specific fields — which LLM
 * actually answers is decided by the backend alone (Spring AI + config).
 * {@code model} and {@code temperature} are optional; if absent the defaults
 * from {@code application.yml} apply.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class ChatRequest {
    private String model;
    private Double temperature;
    private List<ChatMessage> messages;
}
