---
name: playwright-cli
description: Automate browser interactions, test web pages and work with Playwright tests. Use when testing web UIs, automating browser workflows, generating E2E tests, mocking network requests, or debugging browser-based issues.
allowed-tools: Bash(playwright-cli *), Bash(npx *), Bash(npm *)
---

# Browser Automation with playwright-cli

## Quick start

```bash
# open new browser
playwright-cli open
# navigate to a page
playwright-cli goto https://playwright.dev
# take snapshot to see elements with refs
playwright-cli snapshot
# interact using refs
playwright-cli click e15
playwright-cli fill e5 "user@example.com" --submit
playwright-cli screenshot
playwright-cli close
```

## Commands

### Core

```bash
playwright-cli open [url]
playwright-cli goto <url>
playwright-cli type <text>
playwright-cli click <ref> [button]
playwright-cli dblclick <ref>
playwright-cli fill <ref> <text>
playwright-cli fill <ref> <text> --submit   # fill + press Enter
playwright-cli drag <startRef> <endRef>
playwright-cli hover <ref>
playwright-cli select <ref> <value>
playwright-cli upload ./file.pdf
playwright-cli check <ref>
playwright-cli uncheck <ref>
playwright-cli snapshot
playwright-cli snapshot --filename=after-click.yaml
playwright-cli snapshot --depth=4          # limit depth for efficiency
playwright-cli eval "document.title"
playwright-cli eval "el => el.id" e5
playwright-cli dialog-accept [prompt]
playwright-cli dialog-dismiss
playwright-cli resize 1920 1080
playwright-cli close
```

### Navigation

```bash
playwright-cli go-back
playwright-cli go-forward
playwright-cli reload
```

### Keyboard & Mouse

```bash
playwright-cli press Enter
playwright-cli press ArrowDown
playwright-cli keydown Shift
playwright-cli keyup Shift
playwright-cli mousemove 150 300
playwright-cli mousedown [right]
playwright-cli mousewheel 0 100
```

### Screenshots & PDF

```bash
playwright-cli screenshot
playwright-cli screenshot --filename=page.png
playwright-cli pdf --filename=page.pdf
```

### Tabs

```bash
playwright-cli tab-list
playwright-cli tab-new [url]
playwright-cli tab-close [index]
playwright-cli tab-select <index>
```

### Storage

```bash
playwright-cli state-save [filename]
playwright-cli state-load <filename>
playwright-cli cookie-list [--domain=example.com]
playwright-cli cookie-get session_id
playwright-cli cookie-set session_id abc123
playwright-cli cookie-delete session_id
playwright-cli cookie-clear
playwright-cli localstorage-list
playwright-cli localstorage-get theme
playwright-cli localstorage-set theme dark
playwright-cli localstorage-clear
```

### Network Mocking

```bash
playwright-cli route "**/*.jpg" --status=404
playwright-cli route "**/api/users" --body='[{"id":1}]' --content-type=application/json
playwright-cli route-list
playwright-cli unroute "**/*.jpg"
playwright-cli unroute
```

### DevTools

```bash
playwright-cli console [min-level]
playwright-cli network
playwright-cli run-code "async page => await page.context().grantPermissions(['geolocation'])"
playwright-cli run-code --filename=script.js
playwright-cli tracing-start
playwright-cli tracing-stop
playwright-cli video-start [filename]
playwright-cli video-stop
```

### Sessions

```bash
playwright-cli -s=myapp open https://example.com --persistent
playwright-cli -s=myapp click e6
playwright-cli list
playwright-cli close-all
playwright-cli kill-all
```

## Targeting Elements

After `playwright-cli snapshot`, use refs:
```bash
playwright-cli click e15       # ref from snapshot
playwright-cli click "#main > button.submit"  # CSS selector
playwright-cli click "getByRole('button', { name: 'Submit' })"  # locator
playwright-cli click "getByTestId('submit-btn')"
```

## Installation

```bash
npm install -g @playwright/cli@latest
# or local fallback
npx --no-install playwright-cli --version
```

## Specific Tasks

- **Running/Debugging Playwright tests** → [references/playwright-tests.md](references/playwright-tests.md)
- **Request mocking** → [references/request-mocking.md](references/request-mocking.md)
- **Test generation** → [references/test-generation.md](references/test-generation.md)
