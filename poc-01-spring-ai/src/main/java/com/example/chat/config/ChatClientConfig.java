package com.example.chat.config;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Clock;

/**
 * Spring AI wiring. Exposes a {@link ChatClient} bean used by the service
 * layer. No system prompt is configured here on purpose — the client stays
 * generic and provider-neutral; callers pass whatever messages they need.
 */
@Configuration
public class ChatClientConfig {

    @Bean
    public ChatClient chatClient(ChatClient.Builder builder) {
        return builder.build();
    }

    /** System clock — injected into the daily token limiter (swappable in tests). */
    @Bean
    public Clock clock() {
        return Clock.systemDefaultZone();
    }
}
