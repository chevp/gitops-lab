package com.example.chat.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

/** Response for {@code GET /api/chat/models}: the available model names. */
@Getter
@AllArgsConstructor
public class ModelsResponse {
    private final List<String> models;
}
