# Update-Strategie für run-Scripts

Dieses Dokument beschreibt, wie die bestehenden `runs/`-Scripts um eine
**Update-Logik** erweitert werden sollen: Jedes Script soll nicht nur prüfen,
ob ein Tool installiert ist, sondern auch ob eine neuere Version verfügbar ist
— und diese dann installieren, ohne wichtige Daten zu verlieren.

---

## Designprinzipien

1. **Idempotenz bleibt erhalten** — Scripts können weiterhin mehrfach laufen.
2. **Keine Datenverluste** — Konfigurationsdateien, Plugins, Projekte bleiben erhalten.
3. **Alte Versionen werden entfernt**, sofern der Installer das unterstützt oder
   ein sicherer Pfad bekannt ist.
4. **Kein blindes `rm -rf`** — Löschoperationen nur auf klar definierte Binary-Pfade,
   nie auf Konfig- oder Datenverzeichnisse.
5. **Konsistentes Muster** — Alle Scripts folgen demselben dreistufigen Ablauf:
   installieren → Version prüfen → updaten.

---

## Dreistufiger Ablauf (gilt für alle Scripts)

```
1. Ist das Tool installiert?
   └─ Nein → Frisch installieren, fertig.
   └─ Ja  →
        2. Ist eine neuere Version verfügbar?
           └─ Nein → "already up-to-date", fertig.
           └─ Ja  →
                3. Update durchführen
                   ├─ Alte Binary / alten Build entfernen (wenn sicher)
                   └─ Neue Version installieren
```

---

## Script-by-Script Analyse & Update-Strategie

### `01-libs` — apt-Pakete + fzf

#### apt-Pakete
- **Update-Mechanismus:** `sudo apt upgrade <paket>` — apt verwaltet Versionen selbst,
  alte Pakete werden automatisch ersetzt.
- **Versionscheck:** `apt list --upgradable 2>/dev/null | grep -E "^(paket)/"` zeigt
  upgradbare Pakete.
- **Datenverlust-Risiko:** keines — apt-Pakete haben keine nutzerspezifischen Daten
  im Paketpfad.

**Geplante Änderung:**
```bash
# Nach dem "already installed"-Check:
upgradable=$(apt list --upgradable 2>/dev/null | grep -E "^(git|ripgrep|jq|...)/")
if [ -n "$upgradable" ]; then
    echo "Upgrading apt packages..."
    sudo apt -y upgrade git ripgrep jq tldr unzip build-essential tmux tree htop btop git-delta
fi
```

#### fzf (git-basiert, `$HOME/personal/fzf`)
- **Update-Mechanismus:** `git -C "$HOME/personal/fzf" pull --ff-only` + `./install --all`
- **Versionscheck:** lokalen Tag mit `git describe --tags` gegen `git ls-remote --tags`
  vergleichen.
- **Datenverlust-Risiko:** keines — fzf hat keine nutzerspezifischen Daten im Repo.
- **Alte Version entfernen:** nicht nötig, git-pull überschreibt die Binary in-place.

---

### `02-tmux` — tmux (apt) + TPM

#### tmux
- Wird über apt installiert → gleiche Strategie wie apt-Pakete in `01-libs`.

#### TPM (Tmux Plugin Manager, `env/.config/tmux/plugins/tpm`)
- **Update-Mechanismus:** `git -C "$TPM_DIR" pull --ff-only`
- **Versionscheck:** `git -C "$TPM_DIR" fetch --dry-run 2>&1 | grep -q "."` (Änderungen vorhanden?)
- **Datenverlust-Risiko:** TPM-Plugins liegen in `plugins/` — diese werden **nicht**
  gelöscht, nur TPM selbst wird aktualisiert. Plugins updaten via `tpm update all`.
- **Alte Version entfernen:** nicht nötig (in-place git-pull).

**Geplante Änderung:**
```bash
# TPM aktualisieren
git -C "$TPM_DIR" pull --ff-only
# Installierte Plugins aktualisieren
"$TPM_DIR/bin/update_plugins" all
```

---

### `03-oh-my-posh` — Binary in `$HOME/.local/bin`

- **Update-Mechanismus:** Der offizielle Installer (`ohmyposh.dev/install.sh`) überschreibt
  die Binary, wenn man ihn erneut aufruft — er prüft selbst auf Updates.
- **Versionscheck:** Aktuelle Version via `oh-my-posh --version`, neueste via
  GitHub Releases API:
  ```bash
  latest=$(curl -s https://api.github.com/repos/JanDeDobbeleer/oh-my-posh/releases/latest \
      | grep '"tag_name"' | cut -d'"' -f4 | ltrim 'v')
  current=$("$HOME/.local/bin/oh-my-posh" --version)
  ```
- **Datenverlust-Risiko:** Theme-Dateien liegen in `env/.config/omp/` (im Repo) —
  kein Risiko. Font-Installation wird nicht wiederholt.
- **Alte Version entfernen:** Binary wird in-place überschrieben (`-d "$HOME/.local/bin"`
  beim Installer), kein manuelles Löschen nötig.

**Geplante Änderung:**
```bash
current=$("$HOME/.local/bin/oh-my-posh" --version 2>/dev/null)
latest=$(curl -s https://api.github.com/repos/JanDeDobbeleer/oh-my-posh/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
if [ "$current" != "$latest" ]; then
    echo "Updating oh-my-posh: $current → $latest"
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
fi
```

---

### `04-nvm` — Shell-Funktion in `$HOME/.nvm`

- **Update-Mechanismus:** nvm hat einen eingebauten Selbst-Update:
  ```bash
  nvm upgrade   # oder: curl -o- .../install.sh | bash (idempotent)
  ```
  Der Installer erkennt eine bestehende Installation und aktualisiert nur nvm selbst.
- **Versionscheck:** `nvm --version` vs. GitHub Releases API.
- **Datenverlust-Risiko:** Node-Versionen liegen in `$NVM_DIR/versions/node/` —
  diese werden **nicht** berührt. Nur `$NVM_DIR/nvm.sh` und Hilfsdateien werden
  aktualisiert.
- **Alte Version entfernen:** nvm-Installer überschreibt in-place, kein manuelles
  Löschen. Alte Node-Versionen können mit `nvm uninstall <version>` entfernt werden
  (optional, nicht automatisch).

**Geplante Änderung:**
```bash
# nvm selbst updaten
NVM_LATEST=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4)
current_nvm=$(nvm --version 2>/dev/null || echo "0")
if [ "v$current_nvm" != "$NVM_LATEST" ]; then
    echo "Updating nvm: $current_nvm → $NVM_LATEST"
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_LATEST}/install.sh" | bash
fi
# LTS Node aktuell halten
nvm install --lts   # installiert neue LTS falls vorhanden, überspringt sonst
```

---

### `05-pyenv` — `$HOME/.pyenv`

- **Update-Mechanismus:** pyenv ist ein git-Repo → `git -C "$PYENV_ROOT" pull --ff-only`.
- **Versionscheck:** `git -C "$PYENV_ROOT" fetch` + `git status -uno` zeigt ob Updates
  vorhanden.
- **Datenverlust-Risiko:** Python-Versionen liegen in `$PYENV_ROOT/versions/` —
  werden **nicht** gelöscht. Nur pyenv-Kern-Dateien werden aktualisiert.
- **Alte Version entfernen:** git-pull überschreibt in-place. Alte Python-Versionen
  können mit `pyenv uninstall <version>` entfernt werden (optional).

**Geplante Änderung:**
```bash
echo "Updating pyenv..."
git -C "$PYENV_ROOT" pull --ff-only

# Neueste Python-Version installieren (falls noch nicht vorhanden)
LATEST_PYTHON=$(pyenv install --list | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d '[:space:]')
if ! pyenv versions --bare | grep -qF "$LATEST_PYTHON"; then
    echo "Installing Python $LATEST_PYTHON..."
    pyenv install "$LATEST_PYTHON"
    pyenv global "$LATEST_PYTHON"
fi
pip install --upgrade pip
```

---

### `06-rust` — rustup + Toolchain

- **Update-Mechanismus:** `rustup update` — aktualisiert rustup selbst und alle
  installierten Toolchains (stable, nightly, …).
- **Versionscheck:** `rustup check` zeigt verfügbare Updates ohne zu installieren.
- **Datenverlust-Risiko:** Cargo-Projekte und `~/.cargo/registry` bleiben erhalten.
  Alte Toolchain-Komponenten werden von rustup selbst bereinigt.
- **Alte Version entfernen:** rustup verwaltet das vollständig selbst — alte
  Toolchain-Versionen werden nach dem Update automatisch entfernt.

**Geplante Änderung:**
```bash
echo "Checking for rust/rustup updates..."
"$HOME/.cargo/bin/rustup" update stable
# rustup update bereinigt alte Toolchain-Versionen automatisch
```

---

### `07-neovim` — aus Source gebaut, `/usr/local/bin/nvim`

- **Update-Mechanismus:** `git -C "$HOME/personal/neovim" pull --ff-only` + rebuild.
- **Versionscheck:** Lokalen Commit-Hash / Tag gegen `git ls-remote` prüfen.
  Alternativ: `nvim --version` gegen GitHub Releases API.
- **Datenverlust-Risiko:**
  - Neovim-Konfig liegt in `env/.config/nvim/` (im Repo) — sicher.
  - Plugin-Daten in `~/.local/share/nvim/` — werden **nicht** berührt.
  - Build-Artefakte in `$HOME/personal/neovim/build/` — werden beim Rebuild
    überschrieben.
- **Alte Version entfernen:** `sudo make uninstall` im neovim-Verzeichnis entfernt
  die alte Binary aus `/usr/local/bin/` vor dem Neuinstallieren.

**Geplante Änderung:**
```bash
local_tag=$(git -C "$HOME/personal/neovim" describe --tags --abbrev=0 2>/dev/null || echo "unknown")
remote_tag=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4)

if [ "$local_tag" != "$remote_tag" ]; then
    echo "Updating neovim: $local_tag → $remote_tag"
    git -C "$HOME/personal/neovim" pull --ff-only
    cd "$HOME/personal/neovim"
    make CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make uninstall   # entfernt alte Binary sauber
    sudo make install
fi
```

---

### `08-bun` — `$HOME/.bun/bin/bun`

- **Update-Mechanismus:** `bun upgrade` — eingebauter Selbst-Update-Befehl.
- **Versionscheck:** `bun upgrade --dry-run` (falls verfügbar) oder Version gegen
  GitHub Releases API prüfen.
- **Datenverlust-Risiko:** Bun-Projekte und globale Pakete in `~/.bun/install/` bleiben
  erhalten. Nur die Binary wird ersetzt.
- **Alte Version entfernen:** `bun upgrade` überschreibt die Binary in-place.

**Geplante Änderung:**
```bash
echo "Checking for bun updates..."
"$HOME/.bun/bin/bun" upgrade
# bun upgrade ersetzt die Binary in-place, keine manuelle Bereinigung nötig
```

---

### `09-uv` — `$HOME/.local/bin/uv`

- **Update-Mechanismus:** `uv self update` — eingebauter Selbst-Update.
- **Versionscheck:** `uv self update` prüft selbst und gibt "already up-to-date" aus.
- **Datenverlust-Risiko:** uv-Cache in `~/.cache/uv/` und virtuelle Umgebungen
  bleiben erhalten.
- **Alte Version entfernen:** in-place Update durch `uv self update`.

**Geplante Änderung:**
```bash
echo "Checking for uv updates..."
uv self update
```

---

### `10-opencode` — Binary in `$HOME/.local/bin`

- **Update-Mechanismus:** Der offizielle Installer (`opencode.ai/install`) ist
  idempotent und überschreibt die Binary.
- **Versionscheck:** Aktuelle Version via `opencode --version`, neueste via
  GitHub Releases API (Repository: `sst/opencode`).
- **Datenverlust-Risiko:** Opencode-Konfig liegt in `env/.config/opencode/` (im Repo)
  — kein Risiko.
- **Alte Version entfernen:** Binary wird in-place überschrieben.

**Geplante Änderung:**
```bash
current=$("$HOME/.local/bin/opencode" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
latest=$(curl -s https://api.github.com/repos/sst/opencode/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
if [ "$current" != "$latest" ]; then
    echo "Updating opencode: $current → $latest"
    curl -fsSL https://opencode.ai/install | bash -s -- -d "$HOME/.local/bin"
fi
```

---

### `11-claude-code` — Binary in `$HOME/.local/bin`

- **Update-Mechanismus:** Der offizielle Installer (`claude.ai/install.sh`) oder
  `claude update` (falls der CLI das unterstützt).
- **Versionscheck:** `claude --version` gegen den Installer / npm-Registry prüfen.
  Claude Code ist ein npm-Paket (`@anthropic-ai/claude-code`) — daher:
  ```bash
  latest=$(npm view @anthropic-ai/claude-code version 2>/dev/null)
  ```
- **Datenverlust-Risiko:** Keine nutzerspezifischen Daten im Binary-Pfad.
- **Alte Version entfernen:** Binary wird in-place überschrieben.

**Geplante Änderung:**
```bash
# Versionscheck über npm-Registry (claude ist ein npm-Paket)
current=$("$HOME/.local/bin/claude" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
# Update via Installer (idempotent)
if [ -n "$current" ]; then
    echo "Checking for claude updates (current: $current)..."
    curl -fsSL https://claude.ai/install.sh | bash
fi
```

---

### `13-playwright-cli` — npm global

- **Update-Mechanismus:** `npm install -g @playwright/cli@latest` — bereits im Script
  mit `@latest` — ist also schon ein Update-fähiger Befehl.
- **Versionscheck:** `npm outdated -g @playwright/cli` zeigt ob ein Update verfügbar ist.
- **Datenverlust-Risiko:** Playwright-Browser-Binaries in `~/.cache/ms-playwright/`
  bleiben erhalten (werden nicht von npm verwaltet).
- **Alte Version entfernen:** npm ersetzt die alte Version automatisch beim
  `install -g @latest`.

**Geplante Änderung:**
```bash
# Bereits mit @latest — nur Versionsausgabe ergänzen
current=$(playwright-cli --version 2>/dev/null || echo "unknown")
echo "Updating playwright-cli (current: $current)..."
npm install -g @playwright/cli@latest
```

---

## Gemeinsames Hilfsmuster: `needs_update()`

Um den Versionsvergleich zu vereinheitlichen, kann eine gemeinsame Hilfsfunktion
in ein neues Script `runs/00-helpers` (oder als Source-Datei) ausgelagert werden:

```bash
# Vergleicht zwei Semver-Strings. Gibt 0 zurück wenn $1 < $2 (Update nötig).
# Verwendung: needs_update "1.2.3" "1.3.0" && echo "update available"
needs_update() {
    local current="$1" latest="$2"
    [ "$current" = "$latest" ] && return 1   # gleich → kein Update
    # sort -V: version sort; wenn current != latest und current kommt zuerst → Update nötig
    [ "$(printf '%s\n%s' "$current" "$latest" | sort -V | head -1)" = "$current" ]
}
```

---

## Sicherheitsgrenzen — Was wird NIE gelöscht

| Verzeichnis / Datei | Grund |
|---|---|
| `~/.nvm/versions/node/` | Installierte Node-Versionen — nur nvm selbst updaten |
| `~/.pyenv/versions/` | Installierte Python-Versionen — nur pyenv-Kern updaten |
| `~/.cargo/registry/` | Cargo-Cache — rustup verwaltet das selbst |
| `~/.local/share/nvim/` | Neovim-Plugin-Daten (lazy.nvim etc.) |
| `~/.config/` | Alle Konfigurationsdateien |
| `~/personal/` (außer Build-Artefakte) | Projekte und Repos |
| `env/.config/tmux/plugins/` (außer tpm selbst) | TPM-Plugins |

---

## Implementierungsreihenfolge

| Priorität | Script | Aufwand | Risiko |
|---|---|---|---|
| 1 | `06-rust` | minimal | sehr niedrig — `rustup update` ist offiziell |
| 2 | `08-bun` | minimal | sehr niedrig — `bun upgrade` ist offiziell |
| 3 | `09-uv` | minimal | sehr niedrig — `uv self update` ist offiziell |
| 4 | `01-libs` (apt) | gering | niedrig — apt ist stabil |
| 5 | `02-tmux` (TPM) | gering | niedrig — git pull |
| 6 | `05-pyenv` | gering | niedrig — git pull, Versionen bleiben |
| 7 | `03-oh-my-posh` | mittel | niedrig — API-Check + Installer |
| 8 | `04-nvm` | mittel | niedrig — Installer ist idempotent |
| 9 | `10-opencode` | mittel | niedrig — API-Check + Installer |
| 10 | `11-claude-code` | mittel | niedrig — Installer ist idempotent |
| 11 | `07-neovim` | hoch | mittel — Build aus Source, `make uninstall` nötig |
| 12 | `13-playwright-cli` | minimal | niedrig — bereits `@latest` |

---

## Checkliste für jedes Script nach der Änderung

- [ ] Idempotenz-Test: Script zweimal hintereinander ausführen → kein Fehler
- [ ] "already up-to-date"-Pfad gibt klare Meldung aus
- [ ] Update-Pfad gibt alte und neue Version aus (`alt → neu`)
- [ ] Keine Konfigurationsdateien werden gelöscht
- [ ] `set -e` bleibt aktiv — Fehler beim Update bricht ab
- [ ] Fehlermeldungen gehen nach stderr (`>&2`)
- [ ] `99-checks` läuft nach dem Update ohne Fehler durch
