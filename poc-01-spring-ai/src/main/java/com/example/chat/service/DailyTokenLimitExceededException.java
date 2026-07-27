package com.example.chat.service;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Thrown when the per-day token budget is exhausted. Mapped to HTTP 429 so the
 * frontend surfaces it in the error banner.
 */
@ResponseStatus(HttpStatus.TOO_MANY_REQUESTS)
public class DailyTokenLimitExceededException extends RuntimeException {

    public DailyTokenLimitExceededException(long used, long limit) {
        super("Daily token limit reached (" + used + "/" + limit + "). Please try again tomorrow.");
    }
}
