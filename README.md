# Dev-Setup – macOS (Apple Silicon)

macOS-Port des Ubuntu-Dev-Setups. Paketmanager: Homebrew. Default-Shell: zsh.
Getestet auf Apple Silicon (M-Series, `/opt/homebrew`).

---

## Voraussetzungen

| Anforderung | Mindestversion / Hinweis |
|---|---|
| macOS | 13 Ventura oder neuer |
| Xcode Command Line Tools | werden von `install.sh` automatisch geprüft/installiert |
| Homebrew | wird von `install.sh` automatisch installiert, falls nicht vorhanden |
| Shell | zsh (macOS-Standard ab Catalina) |
| Internetzugang | für alle Installer erforderlich |

> Intel-Macs: `/usr/local` statt `/opt/homebrew` – `lib/os.sh` erkennt das automatisch via `brew shellenv`.

---

## Installation (One-liner)

```bash
curl -fsSL https://raw.githubusercontent.com/TomRehbein/dev/macos/install.sh | bash
```

Das Skript:
1. Prüft ob macOS erkannt wird (bricht andernfalls ab).
2. Installiert Xcode CLT und Homebrew, falls nicht vorhanden.
3. Klont dieses Repo nach `~/personal/dev`.
4. Führt `./run` (alle `runs/`-Skripte) und `./dev-env` (Configs) aus.

---

## Manuelle Installation (Schritt für Schritt)

```bash
# 1. Repo klonen
git clone https://github.com/TomRehbein/dev ~/personal/dev
cd ~/personal/dev

# 2. Alle Tools installieren (runs/01 bis runs/13)
./run

# 3. Dotfiles und Configs deployen
./dev-env

# 4. Neue Shell öffnen oder:
source ~/.zprofile
```

---

## Installierte Tools

| Schritt | Tool / Paket | Installationsweg |
|---|---|---|
| `01-libs` | git, ripgrep, jq, unzip, tmux, tree, htop, btop, git-delta, lldb | `brew install` |
| `02-tmux` | tmux + TPM-Plugins | brew + git clone |
| `03-oh-my-posh` | oh-my-posh, Meslo-Font | curl-Installer |
| `04-nvm` | nvm, Node.js LTS + latest | curl-Installer |
| `05-pyenv` | pyenv, Python (latest stable) | curl-Installer |
| `06-rust` | rustup, cargo | curl-Installer (rustup.rs) |
| `07-neovim` | neovim (aus Source) | git clone + make, nach `/opt/homebrew` |
| `08-bun` | bun | curl-Installer (bun.sh) |
| `09-uv` | uv | curl-Installer (astral.sh) |
| `10-opencode` | opencode | curl-Installer |
| `11-claude-code` | claude (Claude Code CLI) | npm global |
| `12-opencode-dispatch` | opencode-dispatch | npm global |
| `13-playwright-cli` | playwright-cli | npm global |

---

## Nach der Installation – manuelle Schritte

```
1. Git-Identität eintragen:
   $EDITOR ~/.gitconfig.local

2. Optional: Commit-Template anpassen:
   $EDITOR ~/.gitmessage

3. Machine-spezifische Config anlegen:
   cp ~/personal/dev/env/.bash_profile.local.example ~/.bash_profile.local
   $EDITOR ~/.bash_profile.local

4. MCP-Server für Claude/opencode einrichten:
   cp ~/personal/dev/env/.claude.json.example ~/.claude.json
   $EDITOR ~/.claude.json   # TAVILY_API_KEY eintragen

5. Neue Shell öffnen (oder: source ~/.zprofile)

6. Ersten nvim-Start abwarten – lazy.nvim installiert alle Plugins automatisch.
```

---

## Abweichungen gegenüber dem Ubuntu-Setup

### Ersetzte Tools

| Ubuntu | macOS | Grund |
|---|---|---|
| `apt` | `brew install` | Homebrew ist der Standard-Paketmanager auf macOS |
| `dpkg -s` | `brew list` | Paket-Check muss zum Paketmanager passen |
| `tldr` (Node-basiert) | `tldr` via brew | brew liefert den Rust-Client (tealdeer-kompatibel) |
| `build-essential` | Xcode CLT + brew-Deps | macOS-Äquivalent; CLT stellt `clang`, `make` usw. bereit |
| `apt install lua5.1` | `brew install lua` | Paketname auf macOS abweichend |

### Weggelassene Teile

| Element | Grund |
|---|---|
| WSL-Detection (in `99-checks`) | Nicht relevant auf macOS |
| WSL-Pfad-Checks (`/mnt/c/...`) | macOS hat kein WSL-Subsystem |
| `dircolors` in `.bashrc` | GNU-Tool, auf macOS nicht verfügbar; Farben laufen über `LSCOLORS` (BSD) |
| Debian-spezifische `.bashrc`-Blöcke | Durch OS-Guards deaktiviert; zsh ist primäre Shell |
| `lesspipe` (apt) | Auf macOS via brew verfügbar, aber nicht im Standard-Setup enthalten |

### Strukturelle Unterschiede

- **Shell**: zsh statt bash. Die Login-Config liegt in `~/.zprofile` (sourct `~/.shell_common.sh`). Interaktive Config in `~/.zshrc`. Bash-spezifische Blöcke in `.bashrc` sind durch OS-Guards deaktiviert.
- **Homebrew-Pfad**: Fix `/opt/homebrew` (Apple Silicon). `lib/os.sh` → `ensure_brew()` evaluiert `brew shellenv` wenn brew nicht auf PATH ist.
- **Neovim-Installationspfad**: Source-Build installiert nach `/opt/homebrew` (statt `/usr/local` auf Ubuntu/Arch).
- **Shell-Common**: `env/.shell_common.sh` ist branch-übergreifend geteilt. Der Homebrew-Block darin ist mit `[ -x /opt/homebrew/bin/brew ]` geguardet – auf Linux ein No-op.
- **find-Syntax**: `./run` verwendet `-perm -u+x` statt GNU-`-executable` (BSD-`find`-Kompatibilität).
- **ls-Farben**: `.bashrc` verwendet `LSCOLORS` (BSD) statt `LS_COLORS` + `dircolors` (GNU).

---

## Bekannte Stolperfallen

- **Homebrew nicht auf PATH**: Tritt auf wenn `brew shellenv` noch nicht in der Shell evaluiert wurde. `lib/os.sh::ensure_brew()` behebt das für alle `runs/`-Skripte automatisch.
- **zsh als Default**: Wenn bash explizit gestartet wird, greifen die zsh-Configs nicht. Die Basis-Config (`~/.shell_common.sh`) funktioniert in beiden Shells.
- **Xcode CLT Update nach macOS-Upgrade**: Nach einem macOS-Majorupdate müssen die CLT neu installiert werden: `xcode-select --install`.
- **nvm in Nicht-interaktiven Shells**: nvm ist eine Shell-Funktion, kein Binary. `runs/13-playwright-cli` setzt den Node-PATH explizit, damit npm-Globals auch in Subshells funktionieren.
- **BSD vs. GNU Coreutils**: `sed -i` benötigt auf macOS ein leeres Suffix: `sed -i '' ...`. `date`, `readlink`, `find` verhalten sich teilweise anders als die GNU-Varianten.
