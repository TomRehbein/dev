# Plan: Ein Branch für alle OS (Unifizierung)

**Status:** offen
**Ersetzt:** den früheren Plan „main strukturell angleichen" (ALIGN_MAIN_STRUCTURE.md) —
dessen Inhalt ist hier Phase 1.

## Ziel

Ein Branch (`main`), ein Einstieg, null manuelle Entscheidungen:

```bash
curl -fsSL https://raw.githubusercontent.com/TomRehbein/dev/main/install.sh | bash
```

- `install.sh` erkennt das OS (Ubuntu/WSL, macOS, Arch) und bootstrappt selbst.
- `runs/`-Skripte laufen auf allen drei OS; Unterschiede über `lib/os.sh` +
  `case "$(detect_os)"`.
- `dev-env` deployt geteilte Configs + `env/os/<os>/`-Overrides automatisch.
- CI testet alle drei OS bei jedem Push auf `main`.
- Branches `macos` und `arch` werden danach archiviert und gelöscht.

**Warum:** Gemeinsame Fixes mussten bisher 3× portiert werden; `env/`
(nvim, tmux, shell — der eigentliche Kern des Repos) driftet zwischen den
Branches stillschweigend auseinander.

**Vorgehensprinzip:** Die Branches `macos`/`arch` werden NICHT per `git merge`
zusammengeführt (Konflikte in fast jeder Datei, da gleiche Zeilen je OS
divergieren). Stattdessen: `main` ist die Basis, die Branches sind der
Steinbruch — gezielt Dateien/Blöcke übernehmen:

```bash
git checkout arch  -- lib/os.sh env/.shell_common.sh
git checkout macos -- env/os/macos/
git diff main arch -- runs/   # als Vorlage für die case-Blöcke
```

---

## Phase 1 — main strukturell vorbereiten

### 1.1 `lib/os.sh` übernehmen
```bash
git checkout arch -- lib/os.sh
```
- arch-Version ist das Superset (ubuntu-, macos-, arch-Case + yay-Helfer).
- Brew-dedup-Fix sicherstellen: nur **ein** `brew list`-Call pro Paket
  (Stand arch ≥ `fce2a57`).
- [ ] Neue Funktion `require_supported_os` ergänzen (ersetzt das bisherige
  branch-spezifische `require_os <os>`):
  ```bash
  # require_supported_os — abort unless detect_os returns a supported OS.
  require_supported_os() {
      case "$(detect_os)" in
          ubuntu|macos|arch) ;;
          *) echo "ERROR: unsupported OS '$(detect_os)'." >&2; exit 1 ;;
      esac
  }
  ```

### 1.2 `run` und `dev-env`
- [ ] `set -e` → `set -euo pipefail`
- [ ] `source "$script_dir/lib/os.sh"` + `require_supported_os`
- [ ] `run`: `find ... -executable` → `-perm -u+x` (BSD-kompatibel)
- [ ] `run`: `${filters[*]}` → `${filters[*]:-}` (set -u + leeres Array)
- [ ] `dev-env`: OS-Override-Hook (von arch übernehmen, identisch auf beiden Branches):
  ```bash
  os_override_dir="$script_dir/env/os/$(detect_os)"
  if [ -d "$os_override_dir" ]; then
      log "deploying OS overrides from $os_override_dir"
      for f in "$os_override_dir"/.[!.]* "$os_override_dir"/*; do
          [ -f "$f" ] || continue
          copy_file "$f" "$HOME"
      done
  fi
  ```

### 1.3 `.shell_common.sh` einführen (heikel — betrifft laufendes WSL-Setup)
Vorlage arch `986026b` + `1739e3b`:
- [ ] `git checkout arch -- env/.shell_common.sh` — Datei ist shell-neutral,
  brew-Block ist mit `[ -x /opt/homebrew/bin/brew ]` geguardet (No-op auf Linux).
- [ ] `env/.bash_profile`: Login-Config raus, stattdessen
  `[ -f ~/.shell_common.sh ] && source ~/.shell_common.sh`
- [ ] `env/.bashrc`: Guard für Non-Login-Shells:
  ```bash
  if [ -z "${_SHELL_COMMON_LOADED:-}" ] && [ -f ~/.shell_common.sh ]; then
      source ~/.shell_common.sh
  fi
  ```
- [ ] `dev-env`: `copy_file "$script_dir/env/.shell_common.sh" "$HOME"` ergänzen
- [ ] ⚠️ WSL-Spezifika (Windows-PATH, Aliase) NICHT in `.shell_common.sh` —
  bleiben in den bash-Dateien oder wandern nach `env/os/ubuntu/`.
- [ ] zsh-Overrides: `git checkout macos -- env/os/macos/` (.zshrc, .zprofile)

---

## Phase 2 — `runs/`-Skripte OS-neutral machen

Header-Muster für ALLE Skripte:
```bash
set -euo pipefail   # Ausnahme 04-nvm, 05-pyenv: set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/os.sh
source "$SCRIPT_DIR/../lib/os.sh"
require_supported_os
```

Paketlisten je OS als case-Block. Vorlage = Diff der drei Branch-Versionen:

- [ ] `01-libs`:
  ```bash
  case "$(detect_os)" in
      ubuntu) PKGS=(git ripgrep jq tldr unzip build-essential tmux tree htop btop git-delta lldb) ;;
      macos)  PKGS=(git ripgrep jq tlrc unzip tmux tree htop btop git-delta) ;;   # CLT liefert Toolchain+lldb
      arch)   PKGS=(git ripgrep jq tealdeer unzip tmux tree htop btop git-delta lldb) ;;
  esac
  pkg_install "${PKGS[@]}"
  ```
  fzf-Teil ist bereits OS-neutral.
- [ ] `02-tmux`: `pkg_install tmux` + TPM — bereits OS-neutral, nur Header.
- [ ] `03-oh-my-posh`: `pkg_install unzip`; Rest OS-neutral (CI-Font-Skip behalten).
- [ ] `04-nvm`, `06-rust`, `08-bun`, `09-uv`, `10-opencode`, `11-claude-code`,
  `12-opencode-dispatch`, `13-playwright-cli`: bereits OS-neutral (curl/git/npm) —
  nur Header. WSL-Binary-Checks in `10-opencode` behalten.
- [ ] `05-pyenv`: Build-Deps je OS:
  ```bash
  case "$(detect_os)" in
      ubuntu) pkg_install make build-essential libssl-dev zlib1g-dev libbz2-dev \
                  libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev \
                  xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev git ;;
      macos)  pkg_install openssl@3 readline sqlite3 xz tcl-tk libffi libxmlsec1 wget ;;
      arch)   pkg_install base-devel openssl zlib xz bzip2 readline sqlite ncurses \
                  libffi tk libxml2 xmlsec wget llvm ;;
  esac
  ```
- [ ] `07-neovim`: Build-Deps + Install-Prefix je OS:
  ```bash
  case "$(detect_os)" in
      ubuntu) NVIM_PREFIX="/usr/local"; SUDO_INSTALL=1; pkg_install cmake gettext lua5.1 ;;
      arch)   NVIM_PREFIX="/usr/local"; SUDO_INSTALL=1; pkg_install cmake gettext lua51 ;;
      macos)  NVIM_PREFIX="$BREW_PREFIX"; SUDO_INSTALL=0; pkg_install cmake gettext lua ;;
  esac
  ```

---

## Phase 3 — `install.sh` als Auto-Dispatcher

Ein Skript, erkennt OS inline (lib/os.sh ist beim `curl | bash` noch nicht da):

- [ ] OS-Detection inline (uname + /etc/os-release, wie heute je Branch)
- [ ] Bootstrap je OS:
  - **ubuntu**: `sudo apt -y update && sudo apt -y install git`
  - **macos**: Xcode CLT (`xcode-select --install` + Warteschleife),
    Homebrew nach `/opt/homebrew`, `brew shellenv`
  - **arch**: `sudo pacman -Sy --needed --noconfirm git base-devel`,
    yay-Bootstrap (root-Fall beachten, siehe arch `08bfb42`)
- [ ] Verzeichnisse anlegen (`~/personal`, `~/work`, `~/personal/obsidian`)
- [ ] `git clone https://github.com/TomRehbein/dev ~/personal/dev`
  — **ohne** `--branch` (main ist der einzige Branch; arch-Fix `dc2c031`
  wird damit obsolet)
- [ ] `./run && ./dev-env`
- [ ] Abschluss-Hinweise (gitconfig.local, .bash_profile.local, MCP-Keys) —
  Shell-Hinweis je OS (bash vs. zsh)

---

## Phase 4 — `99-checks`, README, CI

- [ ] `99-checks`: Header wie Phase 2; Paketliste + Toolchain-Check je OS:
  - ubuntu: `check_apt` (WSL-Logik komplett behalten!), build-essential
  - macos: brew-Pakete, `xcode-select -p`
  - arch: pacman-Pakete, `pacman -Q base-devel`
  - Rest (installer binaries, version managers, npm globals) ist OS-neutral.
- [ ] README: eine Datei mit OS-Abschnitten (Voraussetzungen je OS,
  ein Install-Befehl, Abweichungs-Tabelle apt/brew/pacman aus den
  Branch-READMEs zusammenführen).
- [ ] CI: ein Workflow `.github/workflows/test.yml` mit drei Jobs
  (ersetzt test-ubuntu/test-macos/test-arch):
  ```yaml
  jobs:
    ubuntu:  # runs-on: ubuntu-latest
    arch:    # runs-on: ubuntu-latest, container: archlinux:base-devel (+ sudo git prep)
    macos:   # runs-on: macos-latest (+ brew download cache, NICHT Cellar cachen!)
  ```
  Jeweils: dry-run → ./run → ./dev-env → 99-checks. `paths-ignore` für
  `**.md` + `docs/**` behalten.

---

## Phase 5 — Aufräumen

- [ ] `CLAUDE.md` der Legacy-Branches ist egal (Branches sterben) —
  `main`-Version ist bereits aktualisiert.
- [ ] Branches archivieren + löschen:
  ```bash
  git tag archive/macos macos && git tag archive/arch arch
  git push origin archive/macos archive/arch
  git push origin --delete macos arch feature/macos-support
  git branch -D macos arch feature/macos-support
  ```
- [ ] `docs/PORT_INVENTORY.md` / `docs/PORT_PLAN.md` (liegen auf den
  Legacy-Branches): bei Bedarf nach `main:docs/` übernehmen, sonst sind sie
  über die Archiv-Tags weiter erreichbar.

---

## Validierung (je Phase)

1. `./run --dry && ./dev-env --dry` lokal
2. Push → CI (nach Phase 4: alle drei OS in einem Lauf)
3. Lokales `./dev-env` auf der WSL-Maschine erst nach grüner CI;
   `~/.bash_profile`/`~/.bashrc` vorher sichern.

## Risiken

| Risiko | Mitigation |
|--------|-----------|
| `.bash_profile`/`.bashrc`-Umbau zerschießt laufendes WSL-Setup | CI zuerst; Backup; lokales Deploy zuletzt |
| case-Blöcke machen Skripte länger | Nur Paketlisten + Prefixe in cases; Logik bleibt OS-neutral |
| `set -u` deckt latente unbound-Variablen auf | Dry-run + CI; 04/05 bewusst ohne `-u` |
| WSL nicht in CI testbar | WSL-Pfade manuell auf eigener Maschine gegentesten |
| Übergangsphase: Legacy-Branches bekommen noch Fixes | Ab Start der Migration Feature-Freeze auf `macos`/`arch` |

## Definition of Done

- [ ] `curl ... install.sh | bash` läuft auf frischem Ubuntu, macOS und Arch
      ohne weitere Eingaben durch (CI-belegt für alle drei).
- [ ] Ein Branch (`main`), Legacy-Branches gelöscht, Archiv-Tags gepusht.
- [ ] Kein `require_os <einzelnes-OS>` mehr im Code, keine Branch-Verweise
      in README/CLAUDE.md.
