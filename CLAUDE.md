# Repo: Multi-OS Dev-Setup (Ubuntu/WSL · macOS · Arch Linux)

## Kontext
Dieses Repository enthält ein Entwicklungs-Setup:
- Installations-Skripte als Bash-Skripte in `./runs` (Ausführung via `./run`).
- `./env`: Konfigurationen (neovim, tmux, shell, git u.a.), die per `./dev-env`
  ins Home-Verzeichnis kopiert werden.
- `./lib/os.sh`: OS-Erkennung + Paketmanager-Abstraktion
  (`detect_os`, `pkg_install`, `pkg_check`).
- `./install.sh`: Bootstrap-Einstieg (`curl | bash`).

## Ziel-Architektur (beschlossen 2026-06-11)
**Ein Branch (`main`), ein Einstiegs-Skript, alles weitere automatisch:**
- `install.sh` erkennt das OS selbst und bootstrappt den jeweiligen
  Paketmanager (Ubuntu/WSL → apt, macOS → Xcode CLT + Homebrew, Arch → pacman).
- Alle `runs/`-Skripte sind OS-neutral: `lib/os.sh` abstrahiert die
  Paketmanager, OS-spezifische Paketlisten/Pfade über `case "$(detect_os)"`.
- Gemeinsame Configs liegen einmal in `env/`; OS-spezifische Overrides in
  `env/os/<os>/` (werden von `dev-env` automatisch deployt).
- CI testet alle drei OS auf `main` (ubuntu-latest nativ, archlinux-Container,
  macos-latest).

**Historie:** Das Setup war ursprünglich auf drei Branches verteilt
(`main` = Ubuntu, `macos`, `arch`). Diese Trennung ist aufgehoben —
der Migrationsplan steht in `docs/UNIFY_SINGLE_BRANCH.md`. Bis zum Abschluss
der Migration existieren `macos` und `arch` als Legacy-Branches; neue Arbeit
passiert auf `main`.

## Rahmenbedingungen
- `main` ist der einzige aktive Branch und darf bearbeitet werden.
- Skripte idempotent (mehrfaches Ausführen unschädlich).
- `set -euo pipefail` in allen Skripten (Ausnahme: `04-nvm`, `05-pyenv`
  ohne `-u`, da nvm/pyenv intern unset-Variablen nutzen).
- Keine Duplizierung gemeinsamer Configs — geteilte Basis + OS-Overrides.
- OS-spezifische Workarounds verständlich kommentieren.
- Kleine, aussagekräftige Commits (Conventional Commits).
- WSL-Spezifika (Windows-PATH-Erkennung, `/mnt/`-Pfade) gehören zum
  Ubuntu-Case und dürfen nicht entfernt werden.

## OS-Stolperfallen
**macOS:** Homebrew-Prefix `/opt/homebrew` (Apple Silicon); Default-Shell `zsh`
(`.zshrc`/`.zprofile` in `env/os/macos/`); BSD- statt GNU-Coreutils
(`sed -i`, `readlink`, `date`, `find -perm -u+x` statt `-executable`).
**Arch:** `pacman -S --needed --noconfirm`; AUR via `yay` (nur `install.sh`-Bootstrap,
kein `runs/`-Skript braucht AUR); Build-Deps via `base-devel`; Rolling Release.
**Ubuntu/WSL:** Windows-Binaries (`*.exe`, `/mnt/c/...`) können `command -v`
täuschen — explizite Linux-Pfade prüfen (siehe `runs/99-checks`).
