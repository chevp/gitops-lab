// chat.js — the whole chat feed as a plain-JS app (NO web components, no
// shadow DOM). Combines feed, composer, model picker, suggestions, streaming
// client and error banner in a single file. Talks to a PROVIDER-NEUTRAL chat
// API (neither Ollama- nor OpenAI-specific) — the actual provider lives only
// in the backend (Spring AI). Endpoints (see ChatController):
//   GET  /api/chat/models  -> { models: ["<name>", ...] }
//   POST /api/chat/stream  -> NDJSON stream: {delta:"..."} .. {done:true, tokenCount}

const ENDPOINT = "/api/chat";

// ---------- small helpers ----------
const $ = (sel) => document.querySelector(sel);
const el = (tag, cls) => { const n = document.createElement(tag); if (cls) n.className = cls; return n; };
const escapeHtml = (s) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

// Minimal markdown for assistant text (paragraphs, line breaks, **bold**,
// *italic*, `code`) — enough for a simple chat.
function renderMarkdown(text) {
    return escapeHtml(text)
        .split(/\n{2,}/)
        .map((block) => {
            const inline = block
                .replace(/`([^`]+)`/g, "<code>$1</code>")
                .replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")
                .replace(/(^|[^*])\*([^*\n]+)\*/g, "$1<em>$2</em>")
                .replace(/\n/g, "<br>");
            return `<p>${inline}</p>`;
        })
        .join("");
}

const SUGGESTIONS = [
    { icon: "fa-lightbulb", title: "Explain a concept", hint: "What is GitOps in two sentences?" },
    { icon: "fa-code", title: "Code example", hint: "Show me a minimal Spring Boot controller snippet." },
    { icon: "fa-language", title: "Translate", hint: "Translate 'Good morning' into German." },
    { icon: "fa-list-check", title: "Brainstorm", hint: "Name 3 learning goals for a GitOps PoC." },
];

// ---------- app state ----------
const state = {
    messages: [],       // { role, content }
    model: "",
    models: [],
    streaming: false,
    controller: null,   // AbortController of the in-flight request
};

// ---------- DOM references ----------
let feedEl, errorSlot, inputEl, sendBtn, modelSelect, metaEl;

// ---------- rendering ----------
function renderFeed() {
    feedEl.innerHTML = "";
    if (state.messages.length === 0) {
        feedEl.appendChild(renderWelcome());
        return;
    }
    for (const m of state.messages) feedEl.appendChild(renderMessage(m));
    scrollToBottom();
}

function renderWelcome() {
    const wrap = el("div", "welcome");
    const h1 = el("h1"); h1.textContent = "How can I help?";
    const sub = el("p", "welcome-sub");
    sub.textContent = "Simple chat app powered by Spring AI and OpenAI. Ask a question or pick a suggestion.";
    wrap.append(h1, sub);
    const grid = el("div", "suggestion-grid");
    for (const s of SUGGESTIONS) {
        const btn = el("button", "suggestion");
        btn.innerHTML = `<i class="fa-solid ${s.icon} suggestion-icon"></i>
            <span class="suggestion-title">${escapeHtml(s.title)}</span>
            <span class="suggestion-hint">${escapeHtml(s.hint)}</span>`;
        btn.addEventListener("click", () => { inputEl.value = s.hint; send(); });
        grid.appendChild(btn);
    }
    wrap.appendChild(grid);
    return wrap;
}

// Builds one message row. For assistant messages it returns the .msg-content
// element (for live updates during the stream).
function renderMessage(m) {
    const row = el("div", `msg msg-${m.role}`);
    if (m.role === "user") {
        const bubble = el("div", "msg-bubble");
        bubble.textContent = m.content;
        row.appendChild(bubble);
        return row;
    }
    const content = el("div", "msg-content");
    if (m.role === "assistant") {
        content.innerHTML = m.content ? renderMarkdown(m.content) : `<span class="cursor"></span>`;
        row.appendChild(content);
        const actions = el("div", "msg-actions");
        const copy = el("button", "msg-action"); copy.title = "Copy";
        copy.innerHTML = `<i class="fa-regular fa-copy"></i>`;
        copy.addEventListener("click", () => {
            navigator.clipboard.writeText(m.content);
            copy.innerHTML = `<i class="fa-solid fa-check"></i>`;
            setTimeout(() => { copy.innerHTML = `<i class="fa-regular fa-copy"></i>`; }, 1200);
        });
        actions.appendChild(copy);
        row.appendChild(actions);
    } else { // error
        content.textContent = m.content;
        row.appendChild(content);
    }
    return row;
}

function scrollToBottom() { feedEl.scrollTop = feedEl.scrollHeight; }

function showError(message, detail) {
    errorSlot.innerHTML = "";
    const banner = el("div", "error-banner");
    banner.innerHTML = `<i class="fa-solid fa-triangle-exclamation"></i>
        <div class="err-body"><div>${escapeHtml(message)}</div>
        ${detail ? `<div class="err-detail">${escapeHtml(detail)}</div>` : ""}</div>`;
    const dismiss = el("button", "err-dismiss");
    dismiss.innerHTML = `<i class="fa-solid fa-xmark"></i>`;
    dismiss.addEventListener("click", () => banner.remove());
    banner.appendChild(dismiss);
    errorSlot.appendChild(banner);
}

function setMeta(text) { metaEl.textContent = text || ""; }

// ---------- backend calls ----------
async function loadModels() {
    try {
        const res = await fetch(`${ENDPOINT}/models`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const data = await res.json();
        state.models = data.models || [];
        modelSelect.innerHTML = "";
        for (const name of state.models) {
            const opt = el("option"); opt.value = name; opt.textContent = name;
            modelSelect.appendChild(opt);
        }
        state.model = state.models[0] || "";
        modelSelect.value = state.model;
    } catch (e) {
        showError("Could not load models.", `GET ${ENDPOINT}/models — ${e.message}`);
    }
}

// Streaming chat: reads the NDJSON response line by line and accumulates the
// text deltas.
async function streamChat(assistant, contentEl) {
    const t0 = performance.now();
    state.controller = new AbortController();

    const res = await fetch(`${ENDPOINT}/stream`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            model: state.model,
            temperature: 0.7,
            messages: state.messages
                .filter((m) => m.role === "user" || m.role === "assistant")
                .map((m) => ({ role: m.role, content: m.content })),
        }),
        signal: state.controller.signal,
    });
    if (!res.ok) {
        const text = await res.text().catch(() => "");
        // Prefer the backend's { message } (e.g. the daily-limit 429); fall
        // back to the raw body for anything unstructured.
        let msg = `HTTP ${res.status} — ${text.slice(0, 200)}`;
        try { const j = JSON.parse(text); if (j && j.message) msg = j.message; } catch { /* not JSON */ }
        throw new Error(msg);
    }

    const reader = res.body.getReader();
    const decoder = new TextDecoder();
    let buf = "";
    let tokens = 0;

    const pump = (line) => {
        const trimmed = line.trim();
        if (!trimmed) return;
        let chunk;
        try { chunk = JSON.parse(trimmed); } catch { return; }
        if (chunk.delta) {
            assistant.content += chunk.delta;
            contentEl.innerHTML = renderMarkdown(assistant.content) + `<span class="cursor"></span>`;
            scrollToBottom();
        }
        if (chunk.done) tokens = chunk.tokenCount || tokens;
    };

    while (true) {
        const { value, done } = await reader.read();
        if (done) break;
        buf += decoder.decode(value, { stream: true });
        let idx;
        while ((idx = buf.indexOf("\n")) !== -1) {
            pump(buf.slice(0, idx));
            buf = buf.slice(idx + 1);
        }
    }
    if (buf.trim()) pump(buf);

    contentEl.innerHTML = renderMarkdown(assistant.content); // remove cursor
    const ms = (performance.now() - t0).toFixed(0);
    setMeta(`${state.model} · ${ms} ms${tokens ? ` · ${tokens} tokens` : ""}`);
}

// ---------- sending ----------
async function send() {
    const text = inputEl.value.trim();
    if (!text || state.streaming || !state.model) return;

    errorSlot.innerHTML = "";
    inputEl.value = "";
    autosize();

    state.messages.push({ role: "user", content: text });
    const assistant = { role: "assistant", content: "" };
    state.messages.push(assistant);
    renderFeed();

    // grab the .msg-content of the last rendered assistant row
    const rows = feedEl.querySelectorAll(".msg-assistant .msg-content");
    const contentEl = rows[rows.length - 1];

    state.streaming = true;
    updateSendButton();
    try {
        await streamChat(assistant, contentEl);
    } catch (e) {
        if (e.name === "AbortError") {
            assistant.content = assistant.content || "(stopped)";
        } else {
            // drop the failed answer and show a banner
            state.messages.pop();
            showError("Request failed.", e.message);
        }
        renderFeed();
    } finally {
        state.streaming = false;
        state.controller = null;
        updateSendButton();
        inputEl.focus();
    }
}

function stop() { if (state.controller) state.controller.abort(); }

// Clears the current conversation and returns to the welcome screen.
function newChat() {
    if (state.streaming) stop();
    state.messages = [];
    errorSlot.innerHTML = "";
    setMeta("");
    inputEl.value = "";
    autosize();
    renderFeed();
    updateSendButton();
    inputEl.focus();
}

// ---------- composer behavior ----------
function autosize() {
    inputEl.style.height = "auto";
    inputEl.style.height = Math.min(inputEl.scrollHeight, 200) + "px";
}

function updateSendButton() {
    if (state.streaming) {
        sendBtn.className = "circle-btn stop";
        sendBtn.innerHTML = `<i class="fa-solid fa-stop"></i>`;
        sendBtn.disabled = false;
        sendBtn.onclick = stop;
    } else {
        sendBtn.className = "circle-btn send";
        sendBtn.innerHTML = `<i class="fa-solid fa-arrow-up"></i>`;
        sendBtn.disabled = !inputEl.value.trim();
        sendBtn.onclick = send;
    }
}

// ---------- bootstrap ----------
function mount() {
    document.body.innerHTML = `
        <div class="topbar">
            <span class="topbar-title">PoC 01 · Chat</span>
            <button class="new-chat" title="New chat">
                <i class="fa-solid fa-pen-to-square"></i><span>New chat</span>
            </button>
        </div>
        <div class="error-slot"></div>
        <div class="feed"></div>
        <div class="composer-wrap">
            <div class="composer">
                <textarea class="composer-input" rows="1" placeholder="Type a message…"></textarea>
                <div class="composer-bar">
                    <div class="composer-hint">Enter to send · Shift+Enter for a new line</div>
                    <div class="composer-actions">
                        <div class="model-picker">
                            <select class="model-select" aria-label="Model"></select>
                            <i class="fa-solid fa-chevron-down"></i>
                        </div>
                        <button class="circle-btn send" disabled></button>
                    </div>
                </div>
            </div>
            <div class="composer-meta"></div>
        </div>`;

    feedEl = $(".feed");
    errorSlot = $(".error-slot");
    inputEl = $(".composer-input");
    sendBtn = $(".circle-btn");
    modelSelect = $(".model-select");
    metaEl = $(".composer-meta");

    inputEl.addEventListener("input", () => { autosize(); updateSendButton(); });
    inputEl.addEventListener("keydown", (e) => {
        if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); send(); }
    });
    modelSelect.addEventListener("change", (e) => { state.model = e.target.value; });
    $(".new-chat").addEventListener("click", newChat);

    updateSendButton();
    renderFeed();
    loadModels();
    inputEl.focus();
}

mount();
