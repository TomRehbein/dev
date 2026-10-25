MCP-Server, die standardmäßig aus sind (Kontext sparen). Nicht von Claude Code geladen.

Godot für ein Projekt aktivieren (im Projektordner, nur lokal für dich):

    claude mcp add-json -s local godot "$(jq -c .mcpServers.godot ~/.claude/mcp-disabled/godot.json)"

Wieder entfernen: `claude mcp remove -s local godot`
Einmalig für eine Session: `claude --mcp-config ~/.claude/mcp-disabled/godot.json`
