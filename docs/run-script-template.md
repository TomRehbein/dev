# Run-Script Template

Allgemeines Template für neue Scripts unter `runs/`. Deckt die drei häufigsten
Installationswege ab, die im Repo vorkommen.

---

## Wann welche Variante?

| Variante | Installationsweg | Beispiel im Repo |
|---|---|---|
| **A — apt** | System-Paket via `apt` | `01-libs`, `02-tmux` |
| **B — fester Pfad** | Binary landet an bekanntem Pfad (`~/.local/bin`, `~/.cargo/bin`, …) | `10-opencode`, `11-claude-code` |
| **C — command -v** | Binary landet irgendwo im PATH (Installer setzt PATH selbst) | `08-bun`, `09-uv` |

---

## Variante A — apt-Paket

```bash
#!/usr/bin/env bash

set -e

# ---------------------------------------------------------------------------
# NN-<name> — installiert <tool> via apt
# ---------------------------------------------------------------------------

if dpkg -s "<package>" &>/dev/null; then
    echo "<tool> already installed: $(dpkg -s "<package>" | grep Version)"
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
# NN-<name> — installiert <tool> nach $HOME/.local/bin
# ---------------------------------------------------------------------------

INSTALL_DIR="$HOME/.local/bin"
BINARY="$INSTALL_DIR/<tool>"

if [ -x "$BINARY" ]; then
    echo "<tool> already installed: $("$BINARY" --version 2>/dev/null || echo 'unknown version')"
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
# NN-<name> — installiert <tool>
# ---------------------------------------------------------------------------

if command -v <tool> &>/dev/null; then
    echo "<tool> already installed: $(<tool> --version)"
    exit 0
fi

# Installer-Befehl hier:
curl -fsSL https://example.com/install | bash
export PATH="$HOME/.local/bin:$PATH"
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
