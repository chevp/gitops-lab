# PoC 01 – Chat (Spring Boot 4.x + Spring AI)

Simple chat application. **Provider-neutral by design**: the frontend and the
HTTP API know nothing about a specific LLM vendor — the provider lives solely in
the backend via **Spring AI**. Right now it runs against **OpenAI**, but
switching to another provider (Anthropic, Azure OpenAI, Ollama, …) is a
dependency + `application.yml` change, not a code change.

## Stack

| Layer       | Technology                                    |
|-------------|-----------------------------------------------|
| Frontend    | Plain JS (no framework)                       |
| Backend     | Spring Boot 4.0, Spring AI 2.0                |
| Provider    | OpenAI `gpt-4o-mini` (swappable)              |
| Persistence | Spring Data JPA + H2 (in-memory)              |
| Java        | 21                                            |

## Why provider-neutral?

The `ChatController` and the DTOs (`ChatRequest`, `ChatChunk`, …) carry no
vendor-specific fields. `ChatService` talks to the Spring AI `ChatClient` and
builds a generic `ChatOptions` (no `OpenAiChatOptions`). The only OpenAI-bound
pieces are the `spring-ai-starter-model-openai` dependency and the
`spring.ai.openai.*` block in `application.yml`.

## Frontend

Everything lives directly under `src/main/resources/static/`:

```
static/
├── index.html          # entry page (loads fonts/icons + css/js)
├── css/chat.css        # dark canvas + tan accent design
└── js/chat.js          # feed, composer, model picker, suggestions,
                        # NDJSON streaming client, error banner — all plain JS
```

No build step, no framework, no web components. The design (dark canvas, tan
accent, DM Sans / JetBrains Mono, streaming cursor) is adapted from an existing
chat feed but reimplemented as a single plain-JS file.

## Backend – layered architecture

```
com.example.chat
├── ChatApplication                 # Spring Boot entry point
├── config/
│   └── ChatClientConfig            # Spring AI ChatClient bean
├── dto/                            # provider-neutral wire format
│   ├── ChatMessage
│   ├── ChatRequest
│   ├── ChatChunk
│   └── ModelsResponse
├── domain/
│   └── ConversationMessage         # JPA entity (persisted turn)
├── repository/
│   └── ConversationMessageRepository
├── service/
│   ├── SpringAiMessageMapper       # DTO message -> Spring AI Message
│   └── ChatService                 # orchestration: persist + AI streaming
└── web/
    ├── ChatController               # /api/chat/models, /api/chat/stream
    └── ConversationController       # /api/conversations/{id} (history)
```

**Flow of one turn:** frontend → `ChatController` (NDJSON) → `ChatService`
(persists the user turn via the repository, maps messages via
`SpringAiMessageMapper`, streams from the Spring AI `ChatClient`) → token deltas
back to the browser → the assistant turn is persisted.

## HTTP endpoints

| Method | Path                        | Purpose                                |
|--------|-----------------------------|----------------------------------------|
| GET    | `/api/chat/models`          | available models (model picker)        |
| POST   | `/api/chat/stream`          | chat as an NDJSON stream (text deltas) |
| GET    | `/api/conversations/{id}`   | persisted history (repository)         |

Stream chunk format: `{"delta":"..."}` per token, final `{"done":true,"model":...,"tokenCount":N}`.

## Running it locally with an OpenAI key

You need an **OpenAI** API key (create one at
<https://platform.openai.com/api-keys>; requires billing credits — `gpt-4o-mini`
costs a fraction of a cent per chat).

### 1. Get the key
A secret key starts with `sk-...`.

### 2. Set the key + start

**Option A — only for this one shell session (recommended):**
```bash
cd /Users/chevp/workspace/learning/gitops-lab/poc-01
export OPENAI_API_KEY=sk-your-real-key
./mvnw spring-boot:run
```
The `export` applies only to *this* terminal. `application.yml` reads the value
via `${OPENAI_API_KEY}`.

**Option B — pass the key inline at startup (does not stay in the environment):**
```bash
OPENAI_API_KEY=sk-your-real-key ./mvnw spring-boot:run
```

### 3. Open the app
<http://localhost:8080/> — type a message, the answer streams token by token.

### Security note
Never put the key into `application.yml` or Git — the `${OPENAI_API_KEY}`
reference exists exactly for that reason. To avoid exporting it every time, add
it to your shell profile:
```bash
echo 'export OPENAI_API_KEY=sk-your-key' >> ~/.zshrc && source ~/.zshrc
```

## Quick test without the browser

```bash
# models
curl http://localhost:8080/api/chat/models

# streaming chat (needs a valid key)
curl -N -X POST http://localhost:8080/api/chat/stream \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-4o-mini","messages":[{"role":"user","content":"Say hi"}]}'

# persisted history (repository layer)
curl http://localhost:8080/api/conversations/poc-01
```

H2 console (optional): <http://localhost:8080/h2-console>
(JDBC URL `jdbc:h2:mem:chat`, user `sa`).
