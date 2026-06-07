# Port Plan — Ubuntu → macOS + Arch Linux (Phase 1)

> Erstellt: 2026-06-07 · Basis: `docs/PORT_INVENTORY.md` · Zweck: Plan + Paket-Mapping + Strukturkonzept
> `main` (Ubuntu) bleibt unverändert. Genau ein Branch pro OS: `macos`, `arch`.

**Entscheidungen:**
- macOS-Ziel: **nur Apple Silicon** → fester Homebrew-Pfad `/opt/homebrew`.
- AUR-Helper: **yay**

---

## 1. OS-unabhängig vs. OS-spezifisch

### OS-unabhängig (gleiche Logik, identischer oder paralleler Installbefehl)
Funktioniert cross-OS — nur Paketmanager-Vorbedingungen unterscheiden sich:

| Komponente | Methode | Hinweis |
|------------|---------|---------|
| oh-my-posh, nvm, pyenv, rustup, bun, uv, opencode, claude CLI | curl-Installer | offizielle Installer sind cross-OS |
| Node.js (LTS+latest), Python (latest) | via nvm / pyenv | unverändert |
| tpm + tmux-Plugins | git + `install_plugins` | unverändert |
| fzf | git clone + `install --all` | unverändert |
| opencode-dispatch | git + `bun install/build/link` | braucht bun (08) |
| @playwright/cli | `npm install -g` | braucht node (04) |
| Configs ohne OS-Pfade | copy | nvim, tmux, omp, opencode, sessionizer, gitconfig |

### OS-spezifisch (Anpassung nötig)

| Stelle | Ubuntu | Anpassung macOS / Arch |
|--------|--------|------------------------|
| `install.sh` Z.5/8 | `apt update` + `apt install git` | brew / pacman |
| `runs/01-libs` | `apt install` (12 Tools) | brew / pacman, Namens-Mapping |
| `runs/02-tmux` | `apt install tmux` | brew / pacman |
| `runs/03-oh-my-posh` | `apt install unzip` | brew / pacman |
| `runs/05-pyenv` | 14 apt Build-Deps | macOS: meist System / Arch: Mapping |
| `runs/07-neovim` | `apt install` Build-Deps | brew / pacman (`lua`/`lua51`) |
| `runs/99-checks` | `dpkg -s` | `command -v` / `brew list` / `pacman -Q` |
| `.bashrc` | Debian-Pfade (s. §4) | OS-Guards |
| Default-Shell | bash | macOS: zsh (`.zshrc`/`.zprofile`) |
| WSL-Logik (03/10/11/99) | WSL-Workarounds | entfällt → saubere `command -v`-Checks |
| Coreutils | GNU | macOS: BSD (s. §6) |

---

## 2. Paket-Mapping-Tabelle (Ubuntu → Homebrew → Arch/AUR)

Status: ✅ identisch · 🔶 abweichend · ❌ kein Äquivalent (Workaround nötig)

| Ubuntu-Paket | Homebrew | Arch (repo/AUR) | Status | Anmerkung |
|--------------|----------|-----------------|--------|-----------|
| git | git | git | ✅ | |
| ripgrep | ripgrep | ripgrep | ✅ | |
| jq | jq | jq | ✅ | |
| tldr | tldr | tldr (AUR: tldr-git) | 🔶 | Arch evtl. AUR |
| unzip | unzip | unzip | ✅ | |
| tmux | tmux | tmux | ✅ | |
| tree | tree | tree | ✅ | |
| htop | htop | htop | ✅ | |
| btop | btop | btop | ✅ | |
| git-delta | git-delta | git-delta (AUR) / delta | 🔶 | Arch-Paketname prüfen |
| lldb | (Xcode CLT) | lldb | 🔶 | macOS: Teil der CLT, kein Extra-Paket |
| build-essential | (Xcode CLT) | base-devel | ❌/🔶 | macOS: `xcode-select --install`; Arch: Paketgruppe |
| cmake | cmake | cmake | ✅ | neovim Build-Dep |
| gettext | gettext | gettext | ✅ | neovim Build-Dep |
| lua5.1 / liblua5.1-0-dev | lua | lua51 | 🔶 | abweichende Namen |
| libssl-dev | (System) / openssl | openssl | 🔶 | pyenv Build-Dep |
| zlib1g-dev | (System) / zlib | zlib | 🔶 | pyenv |
| libbz2-dev | (System) / bzip2 | bzip2 | 🔶 | pyenv |
| libreadline-dev | readline | readline | ✅ | pyenv |
| libsqlite3-dev | sqlite | sqlite | 🔶 | pyenv |
| libncursesw5-dev | (System) | ncurses | 🔶 | macOS entfällt |
| libxml2-dev | (System) / libxml2 | libxml2 | 🔶 | pyenv |
| libxmlsec1-dev | libxmlsec1 | xmlsec | 🔶 | pyenv |
| libffi-dev | libffi | libffi | ✅ | pyenv |
| liblzma-dev | (System) / xz | xz | 🔶 | macOS entfällt |
| wget | wget | wget | ✅ | pyenv |
| xz-utils | xz | xz | 🔶 | pyenv |
| tk-dev | tcl-tk | tk | 🔶 | pyenv |
| lesspipe | ❌ kein Äquivalent | lesspipe (AUR) | ❌ | `.bashrc`-Block per Guard kapseln |

> Cross-Check: alle Tools aus `PORT_INVENTORY.md` §4 abgedeckt. curl/git/npm-Installer (oh-my-posh, nvm, pyenv, rustup, bun, uv, opencode, claude, fzf, tpm, opencode-dispatch, playwright) sind OS-unabhängig → kein Paketmanager-Mapping nötig.

---

## 3. Fehlende / abweichende Tools — Alternativen

- **build-essential** → macOS: Xcode Command Line Tools (`xcode-select --install`), kein einzelnes Brew-Paket. Arch: Meta-Gruppe `base-devel`.
- **lldb / lua5.1** → macOS: lldb in CLT enthalten; `lua` statt `lua5.1`. Arch: `lldb`, `lua51`.
- **lesspipe / dircolors / debian_chroot** → macOS ohne Äquivalent. Strategie: `.bashrc`-Blöcke **nicht löschen**, sondern in OS-Guards kapseln (nur auf Linux ausführen).
- **pyenv-Build-Deps** → macOS: zlib/bzip2/ssl/ncurses/lzma meist System (entfallen), Rest via brew (s. Mapping). Arch: 1:1 Paketnamen-Mapping.
- **WSL-Workarounds** (`runs/03,10,11,99`: Pfad-Check statt `command -v`, `/proc/version`, `/mnt/`) → auf macOS/Arch irrelevant → durch saubere `command -v`-Checks ersetzen.

---

## 4. `.bashrc` Debian-Stellen → OS-Guards

| Zeile | Stelle | Strategie |
|-------|--------|-----------|
| 20 | `/usr/bin/lesspipe` | Guard `[ -x /usr/bin/lesspipe ]` (greift nur Linux) |
| 24–25 | `$debian_chroot` / `/etc/debian_chroot` | Guard `[ -r /etc/debian_chroot ]` (existiert nur Debian) |
| 33 | `/usr/bin/tput` | `command -v tput` statt Hardcode (macOS: anderer Pfad) |
| 55–58 | `/usr/bin/dircolors` | macOS: BSD-`ls` nutzt `LSCOLORS`/`CLICOLOR`; GNU-Pfad per Guard |
| 74–79 | bash-completion Pfade | macOS: `/opt/homebrew/etc/profile.d/bash_completion.sh`; per OS-Branch |

> Prinzip: gemeinsame `.bashrc`, OS-spezifische Blöcke per Guard/`uname` — **keine Datei-Duplizierung**.

---

## 5. Strukturkonzept (geteilte Basis + OS-Overrides)

Ziel: gemeinsame Configs **nicht** duplizieren, Erweiterbarkeit für weitere OS.

- **OS-Detection-Helfer** `lib/os.sh`:
  - `detect_os()` → `ubuntu|macos|arch` (via `uname` + `/etc/os-release`)
  - Paketmanager-Abstraktion `pkg_install <pkg...>` → mappt intern auf `apt`/`brew`/`pacman`
  - `pkg_check <pkg>` → ersetzt `dpkg -s` durch OS-passenden Check
- **`runs/`-Skripte** bleiben nummeriert (01–99), rufen aber `pkg_install` statt hartem `apt` → ein Skript pro Tool, verzweigt intern nach OS. Minimiert Branch-Drift.
- **Configs (`env/`)**: gemeinsame Datei + OS-Guards (s. §4). OS-spezifische Overrides isoliert unter `env/os/<name>/` (z.B. `env/os/macos/.zprofile`, `env/os/macos/.zshrc`).
- **Deploy (`dev-env`)**: spielt geteilte Basis + passenden `env/os/<detected>/`-Override aus.
- **Branch-Strategie**: `main` Ubuntu unverändert. `macos`/`arch` erben Struktur, überschreiben nur OS-spezifische Teile via `lib/os.sh`-Pattern + `env/os/<name>/`. Neues OS = neuer Branch + `pkg_install`-Zweig + `env/os/<name>/`.
- **Hinweis Duplizierung**: CLAUDE.md fordert „genau ein Branch pro OS". Die geteilte Basis bleibt **innerhalb** jedes Branches dupliziert-frei durch `lib/os.sh` (gemeinsame Logik, kein Copy-Paste pro Skript).

---

## 6. macOS-Stolperfallen (Apple Silicon)

- **Homebrew**: fester Pfad `/opt/homebrew`. Init: `eval "$(/opt/homebrew/bin/brew shellenv)"`. GUI/Fonts via `--cask` bzw. `oh-my-posh font install meslo`.
- **Default-Shell zsh**: `.zshrc`/`.zprofile` nötig; gemeinsame bash-Basis explizit sourcen oder Shell-neutral schreiben.
- **BSD-Coreutils**: `sed -i ''` (leeres Backup-Arg), `readlink` ohne `-f`, abweichendes `date`. Lösung: GNU via `brew install coreutils` (g-Präfix) **oder** BSD-kompatibel schreiben.
- **Checks**: kein `dpkg -s` → `command -v` / `brew list`.
- **Build-Tools**: `xcode-select --install` als Vorbedingung (cmake, gettext zusätzlich via brew für neovim).

---

## 7. Arch-Stolperfallen

- `pacman -S --needed` (idempotent).
- AUR via **yay** AUR-Pakete: `tldr-git`, ggf. `git-delta`, `lesspipe`.
- `base-devel` als Build-Voraussetzung (ersetzt `build-essential`).
- Rolling Release → keine festen Versionen pinnen.
- Paketnamen-Abweichungen: `lua51`, `xz`, `ncurses`, `xmlsec` (s. Mapping).
- **Checks**: `pacman -Q <pkg>` statt `dpkg -s`.

---

## 8. Validierungs-Leitplanken (Vorgriff Phase 4)

- `set -euo pipefail` in allen Skripten.
- **Idempotenz**: mehrfaches Ausführen unschädlich (`pkg_check` vor Install).
- **OS-/Arch-Check** am Skriptanfang → Abbruch bei falschem OS.
- Trockenlauf in Container/VM (Arch) bzw. CI-Runner (macOS) — Ergebnis dokumentieren.
