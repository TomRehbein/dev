# Mission: Portierung des Ubuntu-Dev-Setups auf macOS und Arch Linux

## Kontext
Dieses Repository enthält ein Ubuntu-basiertes Entwicklungs-Setup:
- Tools werden über `apt`, `curl` und `git`/`make` installiert.
- Installations-Skripte liegen als Bash-Skripte in `./Runs`.
- In `./env` liegen Konfigurationen (neovim, tmux, `.bashrc`, `.bash_profile`,
  `.inputrc` u.a.), die ins Home-Verzeichnis ausgespielt werden.
- Helfer-Skripte im Hauptverzeichnis automatisieren das Ausspielen.

## Ziel
Erstelle getrennte Branches, mit denen das Setup auf **macOS** und **Arch Linux**
genauso reibungslos läuft wie das Ubuntu-Setup auf `main`. `main` bleibt unverändert.
Die Struktur soll erweiterbar bleiben, sodass weitere Systeme später leicht ergänzbar sind.

## Rollen / Subagenten
- **orchestrator** (Opus): koordiniert, erstellt den Plan, delegiert an Subagenten,
  ändert selbst keinen Branch-Code und merged nichts nach `main`.
- **analyzer** (Sonnet, read-only): erstellt das Inventar des `main`-Branch (Phase 0).
- **macos-porter** (Opus): verantwortet Branch `macos` end-to-end.
- **arch-porter** (Opus): verantwortet Branch `arch` end-to-end.
- **docs-writer** (Sonnet): aktualisiert README/Doku je Branch (Phase 5).

## Ablauf

### Phase 0 – Analyse (analyzer)
Inventar erstellen, ohne etwas zu ändern:
- installierte Tools je Methode (apt / curl / git+make)
- Skripte in `./Runs`: Inhalt, Ausführungsreihenfolge, Abhängigkeiten
- `./env`: welche Datei wird wohin ausgespielt (Symlink vs. Copy)
- Funktion der Helfer-Skripte im Hauptverzeichnis
Ergebnis als kurzes, strukturiertes Analyse-Dokument, bevor Code geändert wird.

### Phase 1 – Plan & Mapping (orchestrator)
- OS-unabhängig vs. OS-spezifisch sauber trennen.
- Mapping-Tabelle: Ubuntu-Paket → Homebrew → Arch/AUR. Fehlende oder abweichende Tools
  markieren und Alternativen vorschlagen.
- Strukturkonzept festlegen: gemeinsame Configs **nicht** duplizieren
  (geteilte Basis + OS-spezifische Overrides statt Copy-Paste).

### Phase 2 – Portierung (macos-porter, arch-porter)
Je Subagent: Branch von `main` erstellen → `./Runs`-Skripte portieren (Paketmanager
und Kommandos ersetzen, Pfade anpassen, fehlende Tools lösen) → Helfer-/Deploy-Skripte
an OS-Pfade und Default-Shell anpassen → nur die wirklich nötigen `env`-Configs anpassen.

### Phase 3 – OS-Stolperfallen (beachten)
**macOS:** kein `apt` → Homebrew (`brew install`, GUI via `--cask`); Homebrew-Pfad zur
Laufzeit erkennen (`/opt/homebrew` Apple Silicon vs. `/usr/local` Intel); Default-Shell
`zsh` (`.zshrc`/`.zprofile`) bzw. bash explizit setzen; BSD- statt GNU-Coreutils
(`sed -i`, `readlink`, `date`).
**Arch:** `pacman -S --needed`; AUR-Pakete via `yay`/`paru`; abweichende Paketnamen
gegenüber Ubuntu; Rolling Release; Build-Abhängigkeiten via `base-devel`.

### Phase 4 – Validierung
Skripte idempotent (mehrfaches Ausführen unschädlich); `set -euo pipefail` und saubere
Fehlerbehandlung; OS-/Architektur-Check am Anfang jedes Skripts (abbrechen bei falschem OS);
wenn möglich Trockenlauf in Container/VM und Ergebnis dokumentieren.

### Phase 5 – Doku (docs-writer)
README je Branch: Voraussetzungen, Installation, Abweichungen zu Ubuntu.
Liste ersetzter oder weggelassener Tools inkl. kurzer Begründung.

## Rahmenbedingungen
- `main` bleibt unangetastet; genau ein Branch pro OS.
- Kleine, aussagekräftige Commits.
- Keine unnötige Duplizierung gemeinsamer Configs.
- Verständliche Kommentare bei OS-spezifischen Workarounds.
