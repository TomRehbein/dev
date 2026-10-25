# Dev-Setup, macOS (Apple Silicon)

macOS-Variante des Ubuntu-Dev-Setups. Paketmanager: Homebrew. Default-Shell: zsh.
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
| SSH-Key bei GitHub | nur für `16-personal-tools` (private Repos) |

> Nur Apple Silicon. `/opt/homebrew` ist fest verdrahtet (`lib/os.sh`, `install.sh`, `env/.shell_common.sh`). Intel-Macs (`/usr/local`) sind nicht getestet und bräuchten Anpassungen.

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
git clone -b macos https://github.com/TomRehbein/dev ~/personal/dev
cd ~/personal/dev

# 2. Alle Tools installieren (runs/01 bis runs/17)
./run

# Einzelne Schritte, z. B. nur die Casks
./run 15-casks

# 3. Dotfiles und Configs deployen
./dev-env

# 4. Neue Shell öffnen oder:
source ~/.zprofile
```

`./run --dry` und `./dev-env --dry` zeigen, was passieren würde, ohne etwas zu ändern.

---

## Installierte Tools

| Schritt | Tool / Paket | Installationsweg |
|---|---|---|
| `01-libs` | git, ripgrep, jq, unzip, tmux, tree, htop, btop, git-delta, tlrc, gh, glab, shellcheck, tree-sitter-cli, wget, ffmpeg | `brew install`, fzf per git clone |
| `02-tmux` | tmux + TPM-Plugins (nach `~/.config/tmux/plugins`) | brew + git clone |
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
| `14-skhd` | skhd (Hotkey-Daemon) | brew tap + brew install |
| `15-casks` | GUI-Apps aus dem `Brewfile` | `brew bundle`, siehe unten |
| `16-personal-tools` | tscli (cargo), oc-threads (bun) | git clone per SSH, siehe unten |
| `17-macos-defaults` | macOS-Systemeinstellungen | `defaults write` |

### Hinweise zu einzelnen Schritten

- **`15-casks`** installiert die Apps aus dem `Brewfile`. Apps, die schon manuell in `/Applications` liegen, übernimmt `--adopt`. Auf CI wird der Schritt übersprungen. Arbeits-Apps stehen bewusst nicht im `Brewfile`.
- **`16-personal-tools`** klont die privaten Repos `tscli` und `oc-threads` per SSH nach `~/personal`. Ohne SSH-Zugang wird der Schritt übersprungen und die Installation läuft weiter. Braucht `06-rust` und `08-bun`, die vorher laufen.
- **`17-macos-defaults`** setzt nur Werte, die sich geändert haben. Dock und Finder werden nur neu gestartet, wenn sich dort etwas geändert hat. Gesetzt werden:
  - Dock: automatisch ausblenden
  - Tastatur: `KeyRepeat` 2, `InitialKeyRepeat` 25 (wirkt nach Logout)
  - Dark Mode
  - Natürliches Scrollen aus
  - Finder: Pfadleiste an, Listenansicht als Standard

---

## Nach der Installation, manuelle Schritte

```
1. Git-Identität eintragen:
   $EDITOR ~/.gitconfig.local

2. Optional: Commit-Template anpassen:
   $EDITOR ~/.gitmessage

3. Machine-spezifische Config anlegen (Secrets, Aliases):
   cp ~/personal/dev/env/.bash_profile.local.example ~/.bash_profile.local
   $EDITOR ~/.bash_profile.local

4. GitHub und GitLab anmelden:
   gh auth login
   glab auth login

5. Neue Shell öffnen (oder: source ~/.zprofile)

6. Ersten nvim-Start abwarten, lazy.nvim installiert alle Plugins automatisch.

7. skhd: Accessibility-Recht erteilen (Systemeinstellungen > Datenschutz & Sicherheit >
   Bedienungshilfen > /opt/homebrew/opt/skhd/bin/skhd), danach `./run 14-skhd`.
```

---

## Konfigurationen und Secrets

`./dev-env` spielt die Configs aus `env/` in das Home-Verzeichnis. Die wichtigsten Ziele:

- `~/.zprofile`, `~/.zshrc`, `~/.shell_common.sh` (aus `env/os/macos` und `env/`)
- `~/.config/nvim`, `~/.config/tmux/tmux.conf`, `~/.config/ghostty`, `~/.config/btop`
- `~/.config/skhd/skhdrc`. Die alte `~/.skhdrc` wird von skhd ignoriert.
- `~/.config/gh`, `~/.config/glab-cli`: Aliases und Config. Auth-Tokens (`hosts.yml`, `config.yml`) bleiben beim Deployen erhalten und sind nicht im Repo.
- `~/.config/opencode`: `AGENT.md` ist ein Symlink auf `~/.claude/CLAUDE.md`, die globalen Agent-Instruktionen gelten also für Claude Code und opencode.
- `~/.claude`: wird gemergt. Dateien werden kopiert, nichts wird gelöscht.

Secrets gehören nie ins Repo. Maschinenlokale Werte stehen in `~/.bash_profile.local`. Die Datei wird von `~/.shell_common.sh` geladen und damit von bash und zsh gleichermaßen.

`opencode.json` liest `OPENROUTER_API_KEY` und `TAVILY_API_KEY` über `{env:...}`. Beide Keys müssen also als Umgebungsvariablen gesetzt sein, typischerweise in `~/.bash_profile.local`.

---

## MCP-Server

Globale MCP-Server sind aus, damit sie keinen Kontext belegen. Die Definitionen liegen in `~/.claude/mcp-disabled/` (aktuell `godot.json`). Pro Projekt aktivierst du sie im Projektordner:

```bash
claude mcp add-json -s local godot "$(jq -c .mcpServers.godot ~/.claude/mcp-disabled/godot.json)"
```

Entfernen geht mit `claude mcp remove -s local godot`. Für eine einzelne Session reicht `claude --mcp-config ~/.claude/mcp-disabled/godot.json`.

---

## Migration von einem älteren Setup

Vor dem ersten `./dev-env` auf einem Rechner, der schon läuft:

1. Secrets und Aliases aus `~/.zshrc` nach `~/.bash_profile.local` verschieben. `./dev-env` überschreibt `~/.zshrc`. `~/.zshenv` bleibt unberührt.
2. API-Keys aus `~/.claude.json` nach `~/.bash_profile.local` verschieben.
3. Optional `~/.skhdrc` löschen.
4. Claude-Skills und -Commands, die aus dem Repo entfernt wurden, liegen weiter in `~/.claude`. `./dev-env` merged nur und löscht nichts. Diese Dateien von Hand löschen, falls sie nicht mehr gebraucht werden.

---

## Abweichungen gegenüber dem Ubuntu-Setup

### Ersetzte Tools

| Ubuntu | macOS | Grund |
|---|---|---|
| `apt` | `brew install` | Homebrew ist der Standard-Paketmanager auf macOS |
| `dpkg -s` | `brew list` | Paket-Check muss zum Paketmanager passen |
| `tldr` (Node-basiert) | `tlrc` via brew | `tldr` ist in Homebrew deaktiviert. `tlrc` stellt weiterhin das `tldr`-Binary bereit |
| `build-essential` | Xcode CLT + brew-Deps | macOS-Äquivalent. CLT stellt `clang`, `make` und `lldb` bereit |
| `apt install lua5.1` | `brew install lua` | Paketname auf macOS abweichend |

### Weggelassene Teile

| Element | Grund |
|---|---|
| WSL-Detection (in `99-checks`) | Nicht relevant auf macOS |
| WSL-Pfad-Checks (`/mnt/c/...`) | macOS hat kein WSL-Subsystem |
| `dircolors` in `.bashrc` | GNU-Tool, auf macOS nicht verfügbar. Farben laufen über `LSCOLORS` (BSD) |
| Debian-spezifische `.bashrc`-Blöcke | Durch OS-Guards deaktiviert. zsh ist primäre Shell |
| `lesspipe` (apt) | Auf macOS via brew verfügbar, aber nicht im Standard-Setup enthalten |

### Strukturelle Unterschiede

- **Shell**: zsh statt bash. Die Login-Config liegt in `~/.zprofile`, das `~/.shell_common.sh` lädt. Interaktive Config in `~/.zshrc`. Bash-spezifische Blöcke in `.bashrc` sind durch OS-Guards deaktiviert.
- **Homebrew-Pfad**: Fix `/opt/homebrew` (Apple Silicon). `lib/os.sh` → `ensure_brew()` evaluiert `brew shellenv`, wenn brew nicht auf PATH ist.
- **Neovim-Installationspfad**: Source-Build installiert nach `/opt/homebrew` (statt `/usr/local` auf Ubuntu/Arch).
- **Shell-Common**: `env/.shell_common.sh` enthält den Homebrew-Block mit `[ -x /opt/homebrew/bin/brew ]`-Guard, damit die Datei auch ohne brew sourcebar bleibt.
- **find-Syntax**: `./run` verwendet `-perm -u+x` statt GNU-`-executable` (BSD-`find`-Kompatibilität).
- **ls-Farben**: `LSCOLORS` (BSD) statt `LS_COLORS` + `dircolors` (GNU).

---

## Bekannte Stolperfallen

- **Homebrew nicht auf PATH**: Tritt auf, wenn `brew shellenv` noch nicht in der Shell evaluiert wurde. `lib/os.sh::ensure_brew()` behebt das für alle `runs/`-Skripte automatisch.
- **zsh als Default**: Wenn bash explizit gestartet wird, greifen die zsh-Configs nicht. Die Basis-Config (`~/.shell_common.sh`) funktioniert in beiden Shells.
- **Xcode CLT Update nach macOS-Upgrade**: Nach einem macOS-Majorupdate müssen die CLT neu installiert werden: `xcode-select --install`.
- **nvm in Nicht-interaktiven Shells**: nvm ist eine Shell-Funktion, kein Binary. `runs/13-playwright-cli` setzt den Node-PATH explizit, damit npm-Globals auch in Subshells funktionieren.
- **skhd ohne Accessibility-Recht**: Ohne die Freigabe startet der Dienst nicht. `runs/14-skhd` gibt dann eine Warnung aus.
- **BSD vs. GNU Coreutils**: `sed -i` benötigt auf macOS ein leeres Suffix: `sed -i '' ...`. `date`, `readlink`, `find` verhalten sich teilweise anders als die GNU-Varianten.
