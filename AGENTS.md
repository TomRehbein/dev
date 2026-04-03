# AGENTS.md — Dev Environment Repository

This repo is a personal Linux dev-environment dotfiles and tooling installer for a
Debian/Ubuntu machine. It manages shell config, Neovim, tmux, and tool installation
scripts. There is no application code, no test suite, and no package manager lockfile
at the repo root.

---

## Repository Layout

```
install.sh          # Bootstrap: clone repo + run ./run + ./dev-env
run                 # Execute numbered scripts in runs/ (with optional filters)
dev-env             # Symlink/copy dotfiles from env/ into $HOME
runs/               # Numbered install scripts (01-libs, 02-tmux, …, 13-playwright-cli)
env/                # All dotfiles managed by this repo
  .bash_profile     # Login-shell env, PATH helpers, tool inits
  .bashrc           # Interactive shell: aliases, prompt, completions
  .gitconfig        # Shared Git config (identity goes in ~/.gitconfig.local)
  .gitignore_global # Global gitignore
  .local/scripts/   # User scripts: git-cloner, tmux-sessionizer, dev-env, ready-tmux
  .config/
    nvim/           # Neovim config (kickstart.nvim base + custom/ layer)
    tmux/           # Tmux config
    opencode/       # OpenCode AI agent config (AGENT.md, commands/, skills/)
    omp/            # oh-my-posh prompt theme
    tmux-sessionizer/
```

---

## Commands

### Full installation (fresh machine)

```bash
curl -fsSL https://raw.githubusercontent.com/TomRehbein/dev/main/install.sh | bash
```

### Deploy dotfiles only (idempotent, safe to re-run)

```bash
./dev-env           # copy env/ files into $HOME
./dev-env --dry     # preview what would be copied without touching anything
```

### Run all install scripts

```bash
./run               # runs every executable in runs/ sorted by name
./run --dry         # preview without executing
```

### Run a single install script (by name fragment)

```bash
./run rust          # runs runs/06-rust only
./run bun neovim    # runs runs/08-bun and runs/07-neovim
```

### Neovim: format Lua

Lua files are formatted with **stylua** (installed via Mason inside Neovim):

```bash
stylua env/.config/nvim/        # format entire nvim config
stylua env/.config/nvim/init.lua
```

Config: `env/.config/nvim/.stylua.toml` — 160 col, 2-space indent, single quotes, no call parens.

### Rust (in any Rust project checked out from this machine)

```bash
cargo build
cargo test                          # run all tests
cargo test <test_name>              # run a single test by name
cargo test -- --nocapture           # show stdout from tests
cargo clippy -- -D warnings        # lint (matches rust-analyzer checkOnSave config)
cargo fmt                           # format
```

### TypeScript / Bun (in TS projects on this machine)

```bash
bun install
bun run build
bun test                            # run all tests
bun test <file_or_pattern>          # run a single test file
bun run lint
```

---

## Bash / Shell Style

These conventions apply to all scripts in `runs/`, `dev-env`, `run`, and `env/.local/scripts/`.

### Shebang & safety

```bash
#!/usr/bin/env bash
set -e          # abort on first error (required in every script)
```

### Variables

- Always **double-quote** variable expansions: `"$var"`, `"$HOME/path"`, `"$to/$name"`.
- Declare locals in functions: `local name`.
- Use `UPPER_CASE` for exported/global variables; `lower_case` for locals.
- Prefer `$()` over backticks for command substitution.

### Error handling

- Use `set -e` at the top of every script — no exceptions.
- Send error messages to stderr: `echo "Error: …" >&2`.
- Validate required arguments early and exit non-zero on failure.
- Use `2>/dev/null` sparingly; prefer explicit checks (`[ -f … ]`, `command -v …`).

### Conditionals & checks

```bash
if command -v foo &>/dev/null; then …   # check tool existence
if [ -d "$dir" ]; then …               # POSIX file tests
if [[ "$var" =~ ^pattern$ ]]; then …   # regex (bash only)
```

### Functions

- Small, single-purpose functions with clear names (`copy_dir`, `switch_to`, `log`).
- `log()` / `execute()` pattern for dry-run support — use it when adding new operations.

### Git commit messages

Follow **Conventional Commits**: `type(scope): short description`

Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`

---

## Lua / Neovim Config Style

Config lives in `env/.config/nvim/`. The base is kickstart.nvim; customisations go
exclusively in `lua/custom/`.

### Formatting (enforced by stylua)

- **Indent**: 2 spaces (no tabs).
- **Line width**: 160 columns.
- **Quotes**: single-quote preferred (`AutoPreferSingle`).
- **Call parentheses**: omitted where optional (`call_parentheses = "None"`).
- Line endings: Unix (`\n`).

### Structure rules

- `lua/custom/set.lua` — vim options only.
- `lua/custom/remap.lua` — keymaps only.
- `lua/custom/autocmds.lua` — autocommands only.
- `lua/custom/plugins/` — one file per plugin group (e.g. `rust.lua`).
- Do not modify `init.lua` for plugin-specific logic; put it in `lua/custom/plugins/`.
- `rust_analyzer` is managed exclusively by `rustaceanvim` — do **not** add it to the
  `servers` table in `init.lua` (would attach two LSP instances).

### Patterns

```lua
-- Use opts = {} to pass config to setup() (preferred for simple plugins)
{ 'plugin/name', opts = { … } }

-- Use config = function() … end only when setup requires logic
{ 'plugin/name', config = function() … end }

-- Keymap descriptions always use [Bracket] notation for which-key groups
{ desc = '[S]earch [F]iles' }
```

---

## TypeScript / Bun Style (projects on this machine)

Sourced from `env/.config/opencode/AGENT.md` (the global AI assistant config).

- **Strict mode** on by default (`"strict": true`).
- **No `any`** — use `unknown` or proper types.
- **`const` first** — prefer immutability; avoid mutation where cost is low.
- **No `// TODO`** left in delivered code.
- **Bun-first** for scripts and tooling; fall back to Node.js only if required.
- Imports: named imports over default where possible; group and sort (stdlib → external → internal).
- Conventional Commits for Git messages (same as Bash section above).

---

## Git Workflow

- Default branch: `main`.
- `pull.rebase = true` — rebase on pull, never merge commits from remote.
- `branch.autosetuprebase = always` — all new branches track with rebase.
- Machine-local identity lives in `~/.gitconfig.local` (not committed).
- Commit message template: `~/.gitmessage` (not committed; deployed from `.gitmessage.example`).

### Useful aliases (configured in `.gitconfig`)

```bash
git acm "message"   # git add -A && git commit -m
git lg              # oneline graph log
git undo            # soft reset HEAD~1
git cleanup         # delete merged branches
git push-current    # push current branch with -u
```

---

## Environment Variables

| Variable | Set in | Purpose |
|---|---|---|
| `XDG_CONFIG_HOME` | `.bash_profile` | `$HOME/.config` |
| `DEV_ENV_HOME` | `.bash_profile` | `$HOME/personal/dev` |
| `PYENV_ROOT` | `.bash_profile` | `$HOME/.pyenv` |
| `NVM_DIR` | `.bash_profile` | `$HOME/.nvm` |
| `BUN_INSTALL` | `.bash_profile` | `$HOME/.bun` |

Machine-local overrides (API keys, work aliases) go in `~/.bash_profile.local` — never committed.

---

## What Not to Do

- Do not hardcode absolute paths; derive from `$HOME`, `$script_dir`, or `$XDG_CONFIG_HOME`.
- Do not commit secrets, `.env` files, or `~/.gitconfig.local`.
- Do not use `grep -qv` for positive filter matching — use `grep -q`.
- Do not add `rust_analyzer` to the nvim LSP servers table (rustaceanvim owns it).
- Do not install packages outside of the numbered `runs/` scripts.
- Do not leave unquoted variables in shell scripts.
