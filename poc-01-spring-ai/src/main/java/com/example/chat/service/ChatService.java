package com.example.chat.service;

import com.example.chat.domain.ConversationMessage;
import com.example.chat.dto.ChatMessage;
import com.example.chat.dto.ChatRequest;
import com.example.chat.repository.ConversationMessageRepository;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.prompt.ChatOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

/**
 * Orchestrates one chat turn: persists the user input, streams the answer via
 * Spring AI (OpenAI) and persists the full assistant answer at the end. This
 * ties together the controller, repository and Spring AI layers.
 */
@Service
public class ChatService {

    private final ChatClient chatClient;
    private final SpringAiMessageMapper messageMapper;
    private final ConversationMessageRepository repository;
    private final TokenCounter tokenCounter;
    private final DailyTokenLimiter dailyTokenLimiter;
    private final String defaultModel;
    private final Double defaultTemperature;
    private final Integer maxTokens;
    private final int maxInputTokens;

    public ChatService(ChatClient chatClient,
                       SpringAiMessageMapper messageMapper,
                       ConversationMessageRepository repository,
                       TokenCounter tokenCounter,
                       DailyTokenLimiter dailyTokenLimiter,
                       @Value("${spring.ai.openai.chat.options.model}") String defaultModel,
                       @Value("${spring.ai.openai.chat.options.temperature}") Double defaultTemperature,
                       @Value("${app.chat.max-tokens:1000}") Integer maxTokens,
                       @Value("${app.chat.max-input-tokens:100}") int maxInputTokens) {
        this.chatClient = chatClient;
        this.messageMapper = messageMapper;
        this.repository = repository;
        this.tokenCounter = tokenCounter;
        this.dailyTokenLimiter = dailyTokenLimiter;
        this.defaultModel = defaultModel;
        this.defaultTemperature = defaultTemperature;
        this.maxTokens = maxTokens;
        this.maxInputTokens = maxInputTokens;
    }

    public String resolveModel(ChatRequest request) {
        return (request.getModel() != null && !request.getModel().isBlank()) ? request.getModel() : defaultModel;
    }

    /**
     * Streams the assistant answer as a sequence of text deltas. Persists the
     * last user message before the stream and the accumulated assistant answer
     * once it completes.
     */
    public Flux<String> streamReply(ChatRequest request, String conversationId) {
        persistLastUserMessage(request, conversationId);

        // Cap the input sent to the LLM at maxInputTokens (~100). The persisted
        // history above keeps the user's full message; only the prompt is trimmed.
        List<ChatMessage> cappedMessages = capInput(request.getMessages());
        int inputTokens = cappedMessages.stream().mapToInt(m -> tokenCounter.count(m.getContent())).sum();

        List<Message> aiMessages = messageMapper.toSpringAiMessages(cappedMessages);
        // Provider-neutral options: generic ChatOptions.Builder (no
        // OpenAI-specific type). In Spring AI 2.0 .options() takes the builder.
        ChatOptions.Builder options = ChatOptions.builder()
                .model(resolveModel(request))
                .temperature(resolveTemperature(request))
                .maxTokens(maxTokens); // cap output at ~1000 tokens per request

        StringBuilder assistant = new StringBuilder();
        return chatClient.prompt()
                .messages(aiMessages)
                .options(options)
                .stream()
                .content()
                .doOnNext(assistant::append)
                .doOnComplete(() -> {
                    persist(conversationId, "assistant", assistant.toString());
                    // Count real input + output tokens against the daily budget.
                    int outputTokens = tokenCounter.count(assistant.toString());
                    dailyTokenLimiter.record(inputTokens + outputTokens);
                });
    }

    /**
     * Trims the conversation so the combined content stays within
     * {@code maxInputTokens}, keeping the most recent messages and truncating
     * the boundary message if it only partly fits.
     */
    private List<ChatMessage> capInput(List<ChatMessage> messages) {
        if (messages == null) {
            return List.of();
        }
        List<ChatMessage> kept = new ArrayList<>();
        int budget = maxInputTokens;
        for (int i = messages.size() - 1; i >= 0 && budget > 0; i--) {
            ChatMessage m = messages.get(i);
            String content = m.getContent() == null ? "" : m.getContent();
            int tokens = tokenCounter.count(content);
            if (tokens <= budget) {
                kept.add(0, m);
                budget -= tokens;
            } else {
                kept.add(0, new ChatMessage(m.getRole(), tokenCounter.truncate(content, budget)));
                budget = 0;
            }
        }
        return kept;
    }

    private double resolveTemperature(ChatRequest request) {
        return request.getTemperature() != null ? request.getTemperature() : defaultTemperature;
    }

    private void persistLastUserMessage(ChatRequest request, String conversationId) {
        if (request.getMessages() == null) {
            return;
        }
        request.getMessages().stream()
                .filter(m -> "user".equals(m.getRole()))
                .reduce((first, second) -> second) // last user message
                .map(ChatMessage::getContent)
                .ifPresent(content -> persist(conversationId, "user", content));
    }

    private void persist(String conversationId, String role, String content) {
        repository.save(new ConversationMessage(conversationId, role, content, Instant.now()));
    }
}
