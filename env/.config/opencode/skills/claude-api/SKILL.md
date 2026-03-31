---
name: claude-api
description: "Build apps with the Claude API or Anthropic SDK. Use when: code imports `anthropic`/`@anthropic-ai/sdk`/`claude_agent_sdk`, or user asks to use Claude API, Anthropic SDKs, or Agent SDK. Do NOT use when: general programming without Claude, or ML/data-science tasks unrelated to Claude."
---

# Building LLM-Powered Applications with Claude

This skill helps you build apps with the Claude API. Detect the project language first, then follow the relevant patterns.

## Defaults

- Model: `claude-opus-4-6` (unless user explicitly requests otherwise)
- Thinking: `thinking: {type: "adaptive"}` for anything remotely complex
- Streaming: use for long input/output or high `max_tokens`

## Current Models

| Model             | Model ID            | Context | Input $/1M | Output $/1M |
|-------------------|---------------------|---------|-----------|-------------|
| Claude Opus 4.6   | `claude-opus-4-6`   | 200K    | $5.00     | $25.00      |
| Claude Sonnet 4.6 | `claude-sonnet-4-6` | 200K    | $3.00     | $15.00      |
| Claude Haiku 4.5  | `claude-haiku-4-5`  | 200K    | $1.00     | $5.00       |

**Use exact model ID strings. Do NOT append date suffixes.**

---

## Language Detection

Check project files to infer language:
- `*.ts`, `*.tsx`, `package.json`, `tsconfig.json` → **TypeScript** (use `@anthropic-ai/sdk`)
- `*.py`, `requirements.txt`, `pyproject.toml` → **Python** (use `anthropic`)
- `*.js`/`*.jsx` (no `.ts`) → **TypeScript** (same SDK)

---

## Which Surface to Use

| Use Case | Surface |
|---|---|
| Classification, summarization, Q&A | Claude API (single call) |
| Multi-step pipelines with your own tools | Claude API + tool use |
| Agent with file/web/terminal access | Agent SDK |
| Custom agent with full control | Claude API + tool runner |

---

## TypeScript Quick Start

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

// Basic call
const response = await client.messages.create({
  model: "claude-opus-4-6",
  max_tokens: 16000,
  messages: [{ role: "user", content: "Hello!" }],
});

// With adaptive thinking
const response = await client.messages.create({
  model: "claude-opus-4-6",
  max_tokens: 16000,
  thinking: { type: "adaptive" },
  messages: [{ role: "user", content: "Complex task here" }],
});

// Streaming
const stream = client.messages.stream({
  model: "claude-opus-4-6",
  max_tokens: 64000,
  messages: [{ role: "user", content: "Long response task" }],
});
const finalMessage = await stream.finalMessage();
```

## Tool Use (TypeScript)

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

const tools: Anthropic.Tool[] = [
  {
    name: "get_weather",
    description: "Get current weather for a location",
    input_schema: {
      type: "object",
      properties: {
        location: { type: "string", description: "City name" },
      },
      required: ["location"],
    },
  },
];

// Tool runner handles the loop automatically
const runner = client.messages.runTools({
  model: "claude-opus-4-6",
  max_tokens: 4096,
  tools,
  messages: [{ role: "user", content: "What's the weather in Berlin?" }],
});

runner.on("message", (msg) => {
  if (msg.role === "tool_result") {
    // handle tool call
  }
});

const finalMessage = await runner.finalMessage();
```

## Agent SDK (TypeScript)

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

// Agent with built-in tools (file, web, bash access)
const response = await client.agents.completions.create({
  model: "claude-opus-4-6",
  input: "Analyze the files in the current directory",
  tools: [
    { type: "computer_20250124", name: "computer" },
    { type: "bash_20250124", name: "bash" },
    { type: "text_editor_20250124", name: "str_replace_based_edit_tool" },
  ],
});
```

---

## Common Pitfalls

- **Thinking on Opus/Sonnet 4.6**: Use `thinking: {type: "adaptive"}` — `budget_tokens` is deprecated
- **max_tokens**: Use ~16000 for non-streaming, ~64000 for streaming
- **Model IDs**: Use exact strings, no date suffixes
- **Structured outputs**: Use `output_config: {format: {...}}`, not deprecated `output_format`
- **Tool inputs**: Always parse with `JSON.parse()`, never string-match on serialized input

## Live Docs

Fetch latest docs via WebFetch:
- TypeScript SDK: `https://raw.githubusercontent.com/modelcontextprotocol/typescript-sdk/main/README.md`
- Anthropic SDK: `https://github.com/anthropics/anthropic-sdk-typescript`
- Agent SDK patterns: `https://docs.anthropic.com/en/api/claude-code-sdk`
