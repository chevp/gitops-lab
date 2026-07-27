package com.example.chat.web;

import com.example.chat.dto.ChatChunk;
import com.example.chat.dto.ChatRequest;
import com.example.chat.dto.ModelsResponse;
import com.example.chat.service.ChatService;
import com.example.chat.service.DailyTokenLimiter;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import java.io.IOException;
import java.io.OutputStream;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Provider-neutral chat HTTP facade. Knows no vendor-specific formats — the
 * concrete LLM provider lives solely in the {@link ChatService} (Spring AI) and
 * is swappable via dependency + {@code application.yml}.
 *
 * <ul>
 *   <li>{@code GET  /api/chat/models} — available models (model picker)</li>
 *   <li>{@code POST /api/chat/stream} — chat as an NDJSON stream (text deltas)</li>
 * </ul>
 */
@RestController
@RequestMapping("/api/chat")
public class ChatController {

    /** Fixed conversation id for this PoC (a single session). */
    private static final String CONVERSATION_ID = "poc-01";

    private final ChatService chatService;
    private final DailyTokenLimiter dailyTokenLimiter;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final String defaultModel;

    public ChatController(ChatService chatService,
                          DailyTokenLimiter dailyTokenLimiter,
                          @Value("${spring.ai.openai.chat.options.model}") String defaultModel) {
        this.chatService = chatService;
        this.dailyTokenLimiter = dailyTokenLimiter;
        this.defaultModel = defaultModel;
    }

    /** Model list for the model picker. Here the configured default model. */
    @GetMapping(value = "/models", produces = MediaType.APPLICATION_JSON_VALUE)
    public ModelsResponse models() {
        return new ModelsResponse(List.of(defaultModel));
    }

    /**
     * Streaming chat as NDJSON: one JSON line per token {@code {"delta":"..."}},
     * followed by a final {@code {"done":true,"model":...,"tokenCount":N}}.
     */
    @PostMapping(value = "/stream", produces = "application/x-ndjson")
    public StreamingResponseBody stream(@RequestBody ChatRequest request) {
        // Reject early with 429 if today's token budget is already spent. The
        // service records real input+output tokens against the budget on
        // completion (see ChatService#streamReply).
        dailyTokenLimiter.ensureBudgetAvailable();

        final String model = chatService.resolveModel(request);

        return outputStream -> {
            AtomicInteger tokenCount = new AtomicInteger();
            chatService.streamReply(request, CONVERSATION_ID)
                    .toStream()
                    .forEach(delta -> {
                        writeLine(outputStream, ChatChunk.delta(delta));
                        tokenCount.incrementAndGet();
                    });
            writeLine(outputStream, ChatChunk.done(model, tokenCount.get()));
            outputStream.flush();
        };
    }

    private void writeLine(OutputStream out, ChatChunk chunk) {
        try {
            out.write(objectMapper.writeValueAsBytes(chunk));
            out.write('\n');
            out.flush(); // push immediately -> real token streaming in the frontend
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("Could not serialize chunk", e);
        } catch (IOException e) {
            throw new RuntimeException("Stream interrupted", e);
        }
    }
}
