package com.example.chat.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * One NDJSON line of the streaming response. During the stream each chunk
 * carries a {@code delta} (text fragment); the closing chunk carries
 * {@code done=true} plus {@code model} and {@code tokenCount}. Provider-neutral.
 */
@Getter
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ChatChunk {
    private final String delta;
    private final Boolean done;
    private final String model;
    private final Integer tokenCount;

    public static ChatChunk delta(String text) {
        return new ChatChunk(text, null, null, null);
    }

    public static ChatChunk done(String model, int tokenCount) {
        return new ChatChunk(null, true, model, tokenCount);
    }
}
