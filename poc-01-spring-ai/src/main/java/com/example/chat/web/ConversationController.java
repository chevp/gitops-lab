package com.example.chat.web;

import com.example.chat.domain.ConversationMessage;
import com.example.chat.repository.ConversationMessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Reads the persisted chat history from the repository layer. Not used by the
 * frontend — it exists to make the stored turns visible
 * (e.g. {@code GET /api/conversations/poc-01}).
 */
@RestController
@RequestMapping("/api/conversations")
@RequiredArgsConstructor
public class ConversationController {

    private final ConversationMessageRepository repository;

    public record MessageView(String role, String content, String createdAt) {
        static MessageView from(ConversationMessage m) {
            return new MessageView(m.getRole(), m.getContent(), m.getCreatedAt().toString());
        }
    }

    @GetMapping("/{conversationId}")
    public List<MessageView> history(@PathVariable String conversationId) {
        return repository.findByConversationIdOrderByCreatedAtAsc(conversationId)
                .stream()
                .map(MessageView::from)
                .toList();
    }
}
