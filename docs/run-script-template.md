# Run-Script Template

Allgemeines Template für neue Scripts unter `runs/`. Deckt die drei häufigsten
Installationswege ab, die im Repo vorkommen — jeweils mit **Install-** und
**Update-Logik**.

---

## Wann welche Variante?

| Variante | Installationsweg | Beispiel im Repo |
|---|---|---|
| **A — apt** | System-Paket via `apt` | `01-libs`, `02-tmux` |
| **B — fester Pfad** | Binary landet an bekanntem Pfad (`~/.local/bin`, `~/.cargo/bin`, …) | `10-opencode`, `11-claude-code` |
| **C — command -v** | Binary landet irgendwo im PATH (Installer setzt PATH selbst) | `08-bun`, `09-uv` |
| **D — self-update** | Tool hat eingebauten Update-Befehl | `06-rust` (rustup), `08-bun`, `09-uv` |
| **E — git-repo** | Tool ist ein geklontes Git-Repo | `01-libs` (fzf), `05-pyenv`, `07-neovim` |

---

## Variante A — apt-Paket

```bash
#!/usr/bin/env bash

set -e

# ---------------------------------------------------------------------------
# NN-<name> — installiert/aktualisiert <tool> via apt
# ---------------------------------------------------------------------------

if dpkg -s "<package>" &>/dev/null; then
    # Prüfen ob ein Upgrade verfügbar ist
    if apt list --upgradable 2>/dev/null | grep -q "^<package>/"; then
        echo "<tool> update available, upgrading..."
        sudo apt -y install --only-upgrade "<package>"
    else
        echo "<tool> already up-to-date: $(dpkg -s "<package>" | grep Version)"
    fi
    exit 0
fi

sudo apt -y update
sudo apt -y install "<package>"
```

---

## Variante B — fester Installationspfad

Nutzen wenn der Installer die Binary an einem bekannten, festen Pfad ablegt
(z. B. `~/.local/bin`, `~/.cargo/bin`). Expliziter Pfad-Check schützt auf WSL
vor Windows-Binaries, die `command -v` täuschen könnten.

```bash
#!/usr/bin/env bash

set -e

# ---------------------------------------------------------------------------
# NN-<name> — installiert/aktualisiert <tool> nach $HOME/.local/bin
# ---------------------------------------------------------------------------

INSTALL_DIR="$HOME/.local/bin"
BINARY="$INSTALL_DIR/<tool>"

if [ -x "$BINARY" ]; then
    current=$("$BINARY" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
    latest=$(curl -s https://api.github.com/repos/<owner>/<repo>/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
    if [ -n "$latest" ] && [ "$current" != "$latest" ]; then
        echo "<tool> update available: $current → $latest"
        # Binary wird in-place überschrieben — kein manuelles Löschen nötig
        curl -fsSL https://example.com/install | bash -s -- -d "$INSTALL_DIR"
    else
        echo "<tool> already up-to-date: $current"
    fi
    exit 0
fi

mkdir -p "$INSTALL_DIR"
export PATH="$INSTALL_DIR:$PATH"

# Installer-Befehl hier:
curl -fsSL https://example.com/install | bash -s -- -d "$INSTALL_DIR"
```

---

## Variante C — command -v (PATH-basiert)

Nutzen wenn der Installer den PATH selbst setzt und der genaue Installationspfad
nicht relevant ist (kein WSL-Risiko).

```bash
#!/usr/bin/env bash

set -e

# ---------------------------------------------------------------------------
# NN-<name> — installiert/aktualisiert <tool>
# ---------------------------------------------------------------------------

if command -v <tool> &>/dev/null; then
    echo "<tool> already installed: $(<tool> --version)"
    # Hinweis: Update-Logik hier ergänzen, falls der Installer idempotent ist
    # (z. B. Variante D nutzen wenn ein self-update-Befehl verfügbar ist)
    exit 0
fi

# Installer-Befehl hier:
curl -fsSL https://example.com/install | bash
export PATH="$HOME/.local/bin:$PATH"
```

---

## Variante D — Self-Update (eingebauter Update-Befehl)

Nutzen wenn das Tool einen eigenen Update-Befehl mitbringt (`rustup update`,
`bun upgrade`, `uv self update`). Kein manuelles Löschen nötig.

```bash
#!/usr/bin/env bash

set -e

# ---------------------------------------------------------------------------
# NN-<name> — installiert/aktualisiert <tool> via self-update
# ---------------------------------------------------------------------------

BINARY="$HOME/.local/bin/<tool>"   # Pfad anpassen

if [ -x "$BINARY" ]; then
    echo "Checking for <tool> updates..."
    "$BINARY" <self-update-subcommand>   # z. B.: upgrade / update / self update
    exit 0
fi

# Erstinstallation:
curl -fsSL https://example.com/install | bash
export PATH="$HOME/.local/bin:$PATH"
```

---

## Variante E — Git-Repo (aus Source oder via git pull)

Nutzen wenn das Tool als geklontes Git-Repo verwaltet wird (fzf, pyenv, neovim).

```bash
#!/usr/bin/env bash

set -e

# ---------------------------------------------------------------------------
# NN-<name> — installiert/aktualisiert <tool> aus Git-Repo
# ---------------------------------------------------------------------------

REPO_DIR="$HOME/personal/<tool>"
BINARY="$REPO_DIR/bin/<tool>"

if [ -x "$BINARY" ]; then
    # Prüfen ob Remote-Änderungen vorhanden sind
    git -C "$REPO_DIR" fetch --quiet
    local_ref=$(git -C "$REPO_DIR" rev-parse HEAD)
    remote_ref=$(git -C "$REPO_DIR" rev-parse '@{u}' 2>/dev/null || echo "$local_ref")
    if [ "$local_ref" != "$remote_ref" ]; then
        echo "Updating <tool>..."
        git -C "$REPO_DIR" pull --ff-only
        # Rebuild / Reinstall hier (falls nötig):
        # "$REPO_DIR/install" --all
    else
        echo "<tool> already up-to-date: $("$BINARY" --version 2>/dev/null)"
    fi
    exit 0
fi

# Erstinstallation:
git clone https://github.com/<owner>/<tool>.git "$REPO_DIR"
"$REPO_DIR/install" --all   # Installer-Befehl anpassen
```

---

## Checkliste für neue Scripts

- [ ] Dateiname nach Schema `NN-<name>` (zweistellige Nummer, aufsteigend)
- [ ] Script ist ausführbar: `chmod +x runs/NN-<name>`
- [ ] Shebang `#!/usr/bin/env bash` in Zeile 1
- [ ] `set -e` in Zeile 3
- [ ] Idempotenz-Check am Anfang — Script kann ohne Fehler mehrfach laufen
- [ ] Alle Variablen gequotet: `"$var"`, `"$HOME/path"`
- [ ] Fehlermeldungen nach stderr: `echo "Error: …" >&2`
- [ ] Neues Tool in `99-checks` eintragen (passende `check_bin`/`check_apt`-Zeile)

## Checkliste für Update-Erweiterungen bestehender Scripts

- [ ] Update-Pfad gibt alte **und** neue Version aus: `"alt → neu"`
- [ ] "already up-to-date"-Pfad gibt klare Meldung aus (kein stilles Beenden)
- [ ] Keine Konfigurationsdateien oder Nutzerdaten werden gelöscht
- [ ] Löschen alter Binaries nur auf klar definierten Pfaden (nie `rm -rf` auf Verzeichnisse mit Nutzerdaten)
- [ ] Script zweimal hintereinander ausführen → kein Fehler (Idempotenz)
- [ ] `set -e` bleibt aktiv — Fehler beim Update bricht das Script ab
- [ ] `99-checks` läuft nach dem Update ohne Fehler durch
- [ ] Detaillierter Plan: siehe `docs/update-strategy.md`
