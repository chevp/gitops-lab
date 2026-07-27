package com.example.chat.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.time.Clock;
import java.time.LocalDate;

/**
 * Tracks token usage per calendar day and enforces a daily budget. In-memory
 * and process-local (fine for a single-instance PoC); the counter resets
 * automatically when the date rolls over. Thread-safe.
 */
@Component
public class DailyTokenLimiter {

    private final long dailyLimit;
    private final Clock clock;

    private LocalDate day;
    private long usedToday;

    public DailyTokenLimiter(@Value("${app.chat.max-tokens-per-day:2000}") long dailyLimit, Clock clock) {
        this.dailyLimit = dailyLimit;
        this.clock = clock;
        this.day = LocalDate.now(clock);
    }

    /** Throws {@link DailyTokenLimitExceededException} (HTTP 429) if the budget is used up. */
    public synchronized void ensureBudgetAvailable() {
        rollDayIfNeeded();
        if (usedToday >= dailyLimit) {
            throw new DailyTokenLimitExceededException(usedToday, dailyLimit);
        }
    }

    /** Adds the tokens consumed by a completed request to today's total. */
    public synchronized void record(int tokens) {
        rollDayIfNeeded();
        usedToday += Math.max(0, tokens);
    }

    public synchronized long remaining() {
        rollDayIfNeeded();
        return Math.max(0, dailyLimit - usedToday);
    }

    private void rollDayIfNeeded() {
        LocalDate today = LocalDate.now(clock);
        if (!today.equals(day)) {
            day = today;
            usedToday = 0;
        }
    }
}
