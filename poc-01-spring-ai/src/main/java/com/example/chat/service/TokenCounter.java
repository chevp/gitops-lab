package com.example.chat.service;

import com.knuddels.jtokkit.Encodings;
import com.knuddels.jtokkit.api.Encoding;
import com.knuddels.jtokkit.api.EncodingType;
import org.springframework.stereotype.Component;

/**
 * Counts and truncates text by LLM tokens using jtokkit. Uses the
 * {@code o200k_base} encoding (the tokenizer of the GPT-4o / 4o-mini family),
 * so counts closely match what the provider bills.
 */
@Component
public class TokenCounter {

    private final Encoding encoding = Encodings.newDefaultEncodingRegistry()
            .getEncoding(EncodingType.O200K_BASE);

    public int count(String text) {
        return text == null ? 0 : encoding.countTokens(text);
    }

    /** Returns {@code text} shortened to at most {@code maxTokens} tokens. */
    public String truncate(String text, int maxTokens) {
        if (text == null || maxTokens <= 0) {
            return "";
        }
        if (encoding.countTokens(text) <= maxTokens) {
            return text;
        }
        return encoding.decode(encoding.encode(text, maxTokens).getTokens());
    }
}
