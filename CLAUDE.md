# CLAUDE.md

Dev-Setup für macOS (Apple Silicon). Installiert Tools über Homebrew und Skripte und spielt Dotfiles und Configs ins Home-Verzeichnis aus.

## Branches

- `main`: Ubuntu-Variante. Nicht ändern.
- `macos`: diese Variante (macOS, Apple Silicon).
- `arch`: Arch Linux.

Ein Branch pro OS. Änderungen am OS-Branch gehen nicht nach `main`.

## Struktur

- `install.sh`: Bootstrap per `curl | bash`. Installiert CLT und Homebrew, klont das Repo, ruft `./run` und `./dev-env` auf.
- `run [filter...] [--dry]`: führt die ausführbaren `runs/NN-*`-Skripte in Reihenfolge aus. Filter wie `./run 15-casks` begrenzen den Lauf.
- `runs/NN-name`: ein Installer pro Thema. `99-checks` prüft den Stand.
- `dev-env [--dry]`: spielt `env/` nach `$HOME` und `$XDG_CONFIG_HOME` aus.
- `env/`: Dotfiles und Configs. `env/os/macos/` enthält die OS-Overrides (`.zprofile`, `.zshrc`).
- `lib/os.sh`: `require_os`, `pkg_install`, `pkg_check`, `ensure_brew`.
- `Brewfile`: GUI-Apps, installiert von `runs/15-casks`.

In `dev-env` gibt es drei Kopier-Varianten. `copy_dir` ersetzt ein Verzeichnis komplett und ist nur für Configs gedacht, die uns ganz gehören. `copy_dir_files_only` mergt, z. B. für `~/.claude`, `gh` und `opencode`. `copy_file_if_missing` legt Templates nur an, wenn sie fehlen.

## Konventionen für Skripte

- Shebang `#!/usr/bin/env bash`, `set -euo pipefail`.
- Am Anfang `source lib/os.sh` und `require_os macos`, damit ein falsches OS sofort abbricht.
- Idempotent: Vorhandenes überspringen (`pkg_install`, `command -v`, `[ ! -d ... ]`). Ein zweiter Lauf darf nichts kaputt machen.
- `--dry` behandeln `run` und `dev-env`. Einzelne `runs/`-Skripte brauchen kein eigenes `--dry`.
- Bei gesetztem `CI` überspringen GUI-Casks und der Neustart von Dock und Finder. Neue GUI-Schritte entsprechend absichern.
- Nicht kritische Schritte (z. B. `16-personal-tools`) warnen und machen weiter, statt mit `exit 1` abzubrechen.
- Kommentare nur bei OS-Workarounds und wo das Warum nicht offensichtlich ist.

## Regeln

- Keine Secrets im Repo. Maschinenlokale Werte gehören nach `~/.bash_profile.local` (Vorlage: `env/.bash_profile.local.example`).
- Keine Auth-Dateien committen (`gh/hosts.yml`, `glab-cli/config.yml`).
- Gemeinsame Configs nicht duplizieren. OS-Spezifisches liegt in `env/os/<os>/`, der Rest in `env/`.
- `dev-env` überschreibt `~/.zshrc`. Lokale Änderungen dort gehen verloren.
- `docs/PORT_*.md` sind historische Planungsdokumente aus der Portierung. Maßgeblich sind README und Skripte.
