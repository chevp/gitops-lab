package com.example.chat.service;

import com.example.chat.dto.ChatMessage;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * AI processing: translates the generic chat messages from the frontend
 * ({@code {role, content}}) into typed Spring AI {@link Message}s
 * ({@link SystemMessage}/{@link UserMessage}/{@link AssistantMessage}) that
 * the {@code ChatClient} understands.
 */
@Component
public class SpringAiMessageMapper {

    public List<Message> toSpringAiMessages(List<ChatMessage> messages) {
        if (messages == null) {
            return List.of();
        }
        return messages.stream().map(this::toSpringAiMessage).toList();
    }

    private Message toSpringAiMessage(ChatMessage m) {
        String content = m.getContent() == null ? "" : m.getContent();
        return switch (m.getRole() == null ? "user" : m.getRole()) {
            case "system" -> new SystemMessage(content);
            case "assistant" -> new AssistantMessage(content);
            default -> new UserMessage(content);
        };
    }
}
