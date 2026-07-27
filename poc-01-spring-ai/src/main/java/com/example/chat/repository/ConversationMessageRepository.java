package com.example.chat.repository;

import com.example.chat.domain.ConversationMessage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/**
 * Repository layer for the chat history. Spring Data JPA derives the
 * implementation.
 */
public interface ConversationMessageRepository extends JpaRepository<ConversationMessage, Long> {

    List<ConversationMessage> findByConversationIdOrderByCreatedAtAsc(String conversationId);
}
