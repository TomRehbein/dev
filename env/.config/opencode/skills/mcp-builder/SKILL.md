---
name: mcp-builder
description: Guide for creating high-quality MCP (Model Context Protocol) servers that enable LLMs to interact with external services through well-designed tools. Use when building MCP servers to integrate external APIs or services, whether in Python (FastMCP) or Node/TypeScript (MCP SDK).
license: Complete terms in LICENSE.txt
---

# MCP Server Development Guide

## Overview

Create MCP (Model Context Protocol) servers that enable LLMs to interact with external services through well-designed tools. The quality of an MCP server is measured by how well it enables LLMs to accomplish real-world tasks.

---

# Process

## High-Level Workflow

Creating a high-quality MCP server involves four main phases:

### Phase 1: Deep Research and Planning

#### 1.1 Understand Modern MCP Design

**API Coverage vs. Workflow Tools:**
Balance comprehensive API endpoint coverage with specialized workflow tools. Workflow tools can be more convenient for specific tasks, while comprehensive coverage gives agents flexibility to compose operations.

**Tool Naming and Discoverability:**
Clear, descriptive tool names help agents find the right tools quickly. Use consistent prefixes (e.g., `github_create_issue`, `github_list_repos`) and action-oriented naming.

**Context Management:**
Design tools that return focused, relevant data.

**Actionable Error Messages:**
Error messages should guide agents toward solutions with specific suggestions and next steps.

#### 1.2 Recommended Stack

- **Language**: TypeScript (high-quality SDK support, static typing, good linting)
- **Transport**: Streamable HTTP for remote servers (stateless JSON). stdio for local servers.
- **TypeScript SDK**: Fetch from `https://raw.githubusercontent.com/modelcontextprotocol/typescript-sdk/main/README.md`
- **MCP Best Practices**: `https://modelcontextprotocol.io/sitemap.xml` (then fetch specific pages with `.md` suffix)

#### 1.3 Plan Your Implementation

Review the service's API documentation to identify key endpoints, authentication requirements, and data models.

### Phase 2: Implementation

#### 2.1 Project Structure (TypeScript)

```
my-mcp-server/
├── src/
│   ├── index.ts        # Entry point + server setup
│   ├── tools/          # Tool implementations
│   └── utils/          # Shared utilities (API client, error handling)
├── package.json
└── tsconfig.json
```

#### 2.2 Core Infrastructure

Create shared utilities:
- API client with authentication
- Error handling helpers
- Response formatting (JSON/Markdown)
- Pagination support

#### 2.3 Implement Tools

For each tool:

**Input Schema (Zod):**
```typescript
import { z } from "zod";

server.registerTool("tool_name", {
  description: "Concise description of what this tool does",
  inputSchema: z.object({
    param1: z.string().describe("Description of param1"),
    param2: z.number().optional().describe("Optional param"),
  }),
  annotations: {
    readOnlyHint: true,
    destructiveHint: false,
  },
  execute: async (args) => {
    // implementation
    return { content: [{ type: "text", text: result }] };
  },
});
```

**Annotations:**
- `readOnlyHint`: true/false
- `destructiveHint`: true/false
- `idempotentHint`: true/false
- `openWorldHint`: true/false

### Phase 3: Review and Test

```bash
# Build check
npm run build

# Test with MCP Inspector
npx @modelcontextprotocol/inspector
```

Review for:
- No duplicated code (DRY principle)
- Consistent error handling
- Full type coverage
- Clear tool descriptions

### Phase 4: Create Evaluations

Create 10 evaluation questions to test whether LLMs can effectively use your MCP server:

```xml
<evaluation>
  <qa_pair>
    <question>Complex realistic question requiring multiple tool calls</question>
    <answer>Single, clear, verifiable answer</answer>
  </qa_pair>
</evaluation>
```

Each question must be:
- **Independent**: Not dependent on other questions
- **Read-only**: Only non-destructive operations required
- **Complex**: Requiring multiple tool calls
- **Realistic**: Based on real use cases
- **Verifiable**: Single clear answer
- **Stable**: Answer won't change over time

---

# Quick TypeScript Example

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
  name: "my-service",
  version: "1.0.0",
});

server.registerTool("get_item", {
  description: "Get an item by ID from the service",
  inputSchema: z.object({
    id: z.string().describe("The item ID"),
  }),
  annotations: { readOnlyHint: true },
  execute: async ({ id }) => {
    const data = await fetch(`https://api.example.com/items/${id}`);
    const json = await data.json();
    return {
      content: [{ type: "text", text: JSON.stringify(json, null, 2) }],
    };
  },
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

---

# Reference

- **MCP Spec**: `https://modelcontextprotocol.io/specification/draft.md`
- **TypeScript SDK**: `https://raw.githubusercontent.com/modelcontextprotocol/typescript-sdk/main/README.md`
- **Python SDK**: `https://raw.githubusercontent.com/modelcontextprotocol/python-sdk/main/README.md`
