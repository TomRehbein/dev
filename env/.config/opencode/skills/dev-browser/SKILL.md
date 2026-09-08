---
name: dev-browser
description: Access a customer/portal system in the browser using a pre-authenticated session. Use when a task requires being logged into a customer system, internal HIRSCHTEC tool, or any site that needs credentials — instead of asking for or attempting to enter a password.
allowed-tools: Bash(dev-browser status) Bash(dev-browser list) Bash(dev-browser use *) Bash(playwright-cli:*)
---

# dev-browser — working with credentialed systems

Customer/portal logins are handled entirely outside your reach. Tom logs in
manually once per system; the resulting browser session (cookies) is saved to
disk. You load that saved session — you never see a password, TOTP code, or
1Password output, and you must never try to obtain one.

## Hard rules

- **Never** run `op`, `op.exe`, or anything that reads from 1Password.
- **Never** run `dev-browser login` — that's Tom's manual step only.
- **Never** read files under `~/.local/state/dev-browser/sessions/` directly,
  and never print cookie/localStorage values (e.g. via `playwright-cli
  cookie-list`, `localstorage-list`, or `eval`) into your output unless the
  task specifically requires inspecting a non-secret value.
- If a session is missing or expired, **stop and tell Tom** to run
  `dev-browser login <profile>`. Do not try to log in yourself, even if a
  login form is visible on the page.

## Workflow

```bash
# see what's available and whether sessions are still fresh
dev-browser status

# load a profile's session, then drive the browser normally
dev-browser use <profile>
playwright-cli snapshot
playwright-cli click e15
```

`dev-browser use <profile>` loads the saved session into the default
playwright-cli session and navigates to the profile's URL. From there, use
the regular playwright-cli commands (see the `playwright-cli` skill for the
full command reference: snapshot, click, fill, goto, screenshot, etc.).

## Profiles

Available profiles: `dev-browser list`. Each profile maps to one customer
system (URL + expected session lifetime). If the profile you need doesn't
exist yet, tell Tom instead of guessing a URL.
