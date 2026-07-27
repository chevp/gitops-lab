package com.example.chat.web;

import com.example.chat.service.DailyTokenLimitExceededException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * Turns domain exceptions into clean JSON responses so the frontend can show a
 * meaningful message instead of the generic servlet error page.
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    /** JSON error body: {@code {status, code, message}}. */
    public record ApiError(int status, String code, String message) {
    }

    @ExceptionHandler(DailyTokenLimitExceededException.class)
    public ResponseEntity<ApiError> handleDailyLimit(DailyTokenLimitExceededException ex) {
        return ResponseEntity.status(HttpStatus.TOO_MANY_REQUESTS)
                .body(new ApiError(HttpStatus.TOO_MANY_REQUESTS.value(), "daily_token_limit", ex.getMessage()));
    }
}
