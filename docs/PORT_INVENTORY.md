# Port Inventory — main branch

> Erstellt: 2026-06-07 · Basis: Branch `main` · Zweck: Portierung auf macOS + Arch Linux

---

## 1. Helfer-Skripte (Hauptverzeichnis)

### `install.sh`
Bootstrapper für Ersteinrichtung. Einmalig manuell aufgerufen (z.B. via `curl | bash`).

**Ablauf:**
1. `sudo apt update`
2. Installiert `git` via apt (falls fehlt)
3. Erstellt Verzeichnisse `~/personal`, `~/work`, `~/personal/obsidian`
4. Klont dieses Repo nach `~/personal/dev` (falls fehlt)
5. Ruft `./run` auf (alle Installationsskripte)
6. Ruft `./dev-env` auf (Dotfile-Deployment)
7. Gibt manuelle Nachschritte aus

### `run`
Führt alle ausführbaren Skripte in `./runs/` sortiert aus.
- `--dry`: Trockenrun (kein echtes Ausführen)
- Filter-Argument: Teilstring-Match auf Skriptname

### `dev-env`
Deployed alle Dotfiles und Configs aus `./env/` ins Home-Verzeichnis via **Copy** (kein Symlink).
- `--dry`: Trockenrun
- Funktionen: `copy_dir`, `copy_dir_files_only`, `copy_file`, `copy_file_if_missing`

---

## 2. Installationsskripte (`./runs/`)

Ausführungsreihenfolge: **01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 09 → 10 → 11 → 12 → 13 → 99**

| Skript | Methode | Was wird installiert | Abhängigkeiten |
|--------|---------|---------------------|----------------|
| `01-libs` | apt + git+make | `git`, `ripgrep`, `jq`, `tldr`, `unzip`, `build-essential`, `tmux`, `tree`, `htop`, `btop`, `git-delta`, `lldb`; `fzf` via git clone + install-script | apt, dpkg, sudo |
| `02-tmux` | apt + git | `tmux` via apt; `tpm` via git clone; Plugins via `tpm/bin/install_plugins` | tmux, git |
| `03-oh-my-posh` | curl + apt | `unzip` via apt; oh-my-posh binary via curl; Font `meslo` via `oh-my-posh font install` | curl, unzip |
| `04-nvm` | curl | nvm (latest tag); Node.js LTS + latest | curl |
| `05-pyenv` | apt + curl | 14 Build-Deps via apt; pyenv via `https://pyenv.run`; neueste Python-Version | apt, curl |
| `06-rust` | curl | rustup + stable toolchain via `https://sh.rustup.rs` | curl |
| `07-neovim` | apt + git + make | cmake, gettext, lua5.1 via apt; neovim from source via git + `make CMAKE_BUILD_TYPE=RelWithDebInfo` + `sudo make install` | apt, cmake, git, make, sudo |
| `08-bun` | curl | bun via `https://bun.sh/install` → `~/.bun/bin/` | curl |
| `09-uv` | curl | uv via `https://astral.sh/uv/install.sh` → `~/.local/bin/` | curl |
| `10-opencode` | curl | opencode binary via `https://opencode.ai/install` → `~/.local/bin/` | curl |
| `11-claude-code` | curl | claude CLI via `https://claude.ai/install.sh` → `~/.local/bin/` | curl |
| `12-opencode-dispatch` | git + bun | Klont `https://github.com/TomRehbein/opencode-dispatch`; `bun install && bun run build && bun link` | git, bun (08 vorher) |
| `13-playwright-cli` | npm global | `@playwright/cli@latest` via `npm install -g` | node/npm (04 vorher) |
| `99-checks` | — | Verifikation: `command -v`, `dpkg -s`, `check_file`; WSL-aware | alle vorigen |

**Harte Abhängigkeiten:**
- `12-opencode-dispatch` → bun aus `08-bun`
- `13-playwright-cli` → node/npm aus `04-nvm`
- `99-checks` → alle vorigen

---

## 3. Konfigurationsdateien (`./env/`)

Deployment: ausschließlich via **Copy** (kein Symlink).

### Dotfiles → `~/`

| Quelldatei | Ziel | Methode | Anmerkung |
|------------|------|---------|-----------|
| `env/.tmux-sessionizer` | `~/.tmux-sessionizer` | copy (überschreiben) | Session-Startup-Skript |
| `env/.bashrc` | `~/.bashrc` | copy (überschreiben) | |
| `env/.bash_profile` | `~/.bash_profile` | copy (überschreiben) | Login-Shell-Config |
| `env/.inputrc` | `~/.inputrc` | copy (überschreiben) | Readline-Keybindings |
| `env/.gitconfig` | `~/.gitconfig` | copy (überschreiben) | |
| `env/.gitignore_global` | `~/.gitignore_global` | copy (überschreiben) | |
| `env/.gitconfig.local.example` | `~/.gitconfig.local.example` | copy-if-missing | Erstdeploy: → `.gitconfig.local` |
| `env/.gitmessage.example` | `~/.gitmessage.example` | copy-if-missing | Erstdeploy: → `.gitmessage` |

### Config-Verzeichnisse → `~/.config/`

| Quelle | Ziel | Methode | Anmerkung |
|--------|------|---------|-----------|
| `env/.config/tmux/` | `~/.config/tmux/` | `copy_dir` (vollständig ersetzen) | `tmux.conf` + tpm + Plugins als eingecheckte Git-Repos |
| `env/.config/nvim/` | `~/.config/nvim/` | `copy_dir` (vollständig ersetzen) | kickstart.nvim-Basis + custom Plugins (Rust, neo-tree, etc.) |
| `env/.config/tmux-sessionizer/` | `~/.config/tmux-sessionizer/` | `copy_dir` (vollständig ersetzen) | Konfig für tmux-sessionizer |
| `env/.config/omp/` | `~/.config/omp/` | `copy_dir` (vollständig ersetzen) | oh-my-posh Theme (`the-unnamed.omp.json`) |
| `env/.config/opencode/` | `~/.config/opencode/` | `copy_dir_files_only` (nur Dateien) | opencode.json, AGENT.md, Skills, Commands, Plugins |

### `.claude/` und `.local/`

| Quelle | Ziel | Methode | Anmerkung |
|--------|------|---------|-----------|
| `env/.claude/` | `~/.claude/` | `copy_dir` (vollständig ersetzen) | CLAUDE.md (globale Claude-Instruktionen) |
| `env/.local/` | `~/.local/` | `copy_dir_files_only` (kein vollst. Ersatz) | Skripte: `tmux-sessionizer`, `ready-tmux`, `dev-env`, `git-cloner` |

### Nur als Template vorhanden (manuell kopieren)

| Datei | Zweck |
|-------|-------|
| `env/.claude.json.example` | MCP-Server-Konfig (Tavily, Mathematics) → manuell nach `~/.claude.json` |
| `env/.bash_profile.local.example` | Maschinen-lokale Env-Vars/Aliases → manuell nach `~/.bash_profile.local` |

---

## 4. Tool-Liste

| Tool | Methode | Paket / URL / Repo |
|------|---------|-------------------|
| git | apt | `git` |
| ripgrep | apt | `ripgrep` |
| jq | apt | `jq` |
| tldr | apt | `tldr` |
| unzip | apt | `unzip` |
| build-essential | apt | `build-essential` |
| tmux | apt | `tmux` |
| tree | apt | `tree` |
| htop | apt | `htop` |
| btop | apt | `btop` |
| git-delta | apt | `git-delta` |
| lldb | apt | `lldb` |
| cmake | apt | `cmake` (neovim Build-Dep) |
| gettext | apt | `gettext` (neovim Build-Dep) |
| lua5.1 / liblua5.1-0-dev | apt | `lua5.1`, `liblua5.1-0-dev` (neovim Build-Dep) |
| libssl-dev, zlib1g-dev, libbz2-dev, libreadline-dev, libsqlite3-dev, libncursesw5-dev, libxml2-dev, libxmlsec1-dev, libffi-dev, liblzma-dev | apt | Build-Deps für pyenv/Python |
| wget, xz-utils, tk-dev | apt | Build-Deps für pyenv/Python |
| fzf | git + install-script | `https://github.com/junegunn/fzf.git` → `~/personal/fzf/install --all` |
| tpm (Tmux Plugin Manager) | git | `https://github.com/tmux-plugins/tpm` |
| tmux-sensible | tpm | `tmux-plugins/tmux-sensible` |
| tmux-resurrect | tpm | `tmux-plugins/tmux-resurrect` |
| tmux-continuum | tpm | `tmux-plugins/tmux-continuum` |
| vim-tmux-navigator | tpm | `christoomey/vim-tmux-navigator` |
| tmux-yank | tpm | `tmux-plugins/tmux-yank` |
| oh-my-posh | curl | `https://ohmyposh.dev/install.sh` → `~/.local/bin/` |
| Meslo Nerd Font | oh-my-posh | `oh-my-posh font install meslo` |
| nvm | curl | `https://raw.githubusercontent.com/nvm-sh/nvm/${TAG}/install.sh` |
| Node.js (LTS + latest) | nvm | `nvm install --lts` + `nvm install node` |
| pyenv | curl | `https://pyenv.run` |
| Python (neueste stabile Version) | pyenv | `pyenv install <latest>` |
| rustup + Rust stable | curl | `https://sh.rustup.rs` → `~/.cargo/` |
| neovim | git + make | `https://github.com/neovim/neovim.git` → `make + sudo make install` → `/usr/local/bin/nvim` |
| bun | curl | `https://bun.sh/install` → `~/.bun/bin/` |
| uv | curl | `https://astral.sh/uv/install.sh` → `~/.local/bin/` |
| opencode | curl | `https://opencode.ai/install` → `~/.local/bin/` |
| claude CLI | curl | `https://claude.ai/install.sh` → `~/.local/bin/` |
| opencode-dispatch | git + bun | `https://github.com/TomRehbein/opencode-dispatch` → `bun install && bun run build && bun link` |
| @playwright/cli | npm global | `npm install -g @playwright/cli@latest` |

---

## 5. OS-Abhängigkeiten / Ubuntu-spezifische Stellen

### Direkter apt-/dpkg-Einsatz

| Datei | Stellen | Detail |
|-------|---------|--------|
| `install.sh` | Zeile 5, 8 | `sudo apt -y update`, `sudo apt -y install git` |
| `runs/01-libs` | Zeile 7, 13–14 | `dpkg -s` zum Check, `sudo apt -y install` |
| `runs/02-tmux` | Zeile 7–8 | `dpkg -s tmux`, `sudo apt install -y tmux` |
| `runs/03-oh-my-posh` | Zeile 14 | `sudo apt install unzip -y` |
| `runs/05-pyenv` | Zeile 12–15 | `sudo apt install -y` mit 14 Build-Deps |
| `runs/07-neovim` | Zeile 10 | `sudo apt install -y cmake gettext lua5.1 liblua5.1-0-dev` |
| `runs/99-checks` | Zeile 98, 115 | `dpkg -s` als Installationscheck für apt-Pakete |

### Debian/Ubuntu-spezifische Pfade in Configs

| Datei | Stelle | Detail |
|-------|--------|--------|
| `env/.bashrc` | Zeile 20 | `/usr/bin/lesspipe` (Debian-Paket `lesspipe`) |
| `env/.bashrc` | Zeile 24–25 | `$debian_chroot` / `/etc/debian_chroot` |
| `env/.bashrc` | Zeile 33 | `/usr/bin/tput` (hardcodierter Pfad) |
| `env/.bashrc` | Zeile 55–58 | `/usr/bin/dircolors` (GNU-Coreutils-Tool, kein macOS-Äquivalent) |
| `env/.bashrc` | Zeile 74–79 | `/usr/share/bash-completion/bash_completion` und `/etc/bash_completion` |

### WSL-spezifische Logik (nur Linux, kein macOS-Problem)

| Datei | Detail |
|-------|--------|
| `runs/99-checks` | `grep -qi microsoft /proc/version` für WSL-Detection; `/mnt/`-Pfad-Check für Windows-Binaries |
| `runs/03-oh-my-posh` | Prüft `$HOME/.local/bin/oh-my-posh` statt `command -v` (WSL-workaround) |
| `runs/10-opencode` | Prüft Pfad statt `command -v` (WSL-workaround) |
| `runs/11-claude-code` | Prüft Pfad statt `command -v` (WSL-workaround) |
| `env/.bashrc` | Zeile 106: WSL/Windows PATH-Passthrough für oh-my-posh |

### Paket-Namensunterschiede (Portierungsmapping)

| Ubuntu-Paket | macOS (Homebrew) | Arch (pacman/AUR) | Anmerkung |
|-------------|-----------------|------------------|-----------|
| `ripgrep` | `ripgrep` | `ripgrep` | identisch |
| `git-delta` | `git-delta` | `git-delta` (AUR) oder `delta` | Paketname prüfen |
| `build-essential` | Xcode Command Line Tools | `base-devel` | macOS: kein brew-Äquivalent |
| `lua5.1` / `liblua5.1-0-dev` | `lua` | `lua51` | abweichende Namen |
| `libncursesw5-dev` | nicht nötig (System) | `ncurses` | |
| `liblzma-dev` | nicht nötig (System) | `xz` | |
| `libffi-dev` | `libffi` | `libffi` | |
| `libreadline-dev` | `readline` | `readline` | |
| `tldr` | `tldr` | `tldr` (AUR: `tldr-git`) | |
| `btop` | `btop` | `btop` | identisch |
| `lldb` | Teil von Xcode CLT | `lldb` | macOS: kein separates Paket |
| `cmake` | `cmake` | `cmake` | identisch |
| `gettext` | `gettext` | `gettext` | identisch |
| `lesspipe` | kein Äquivalent | `lesspipe` (AUR) | `.bashrc` anpassen |
