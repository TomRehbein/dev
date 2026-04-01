# Code Review - Dev Environment Automation

## Kritisch (sofort fixen)

### 1. Kaputter Shebang in `dev-env`
- **Datei:** `dev-env`, Zeile 1
- `#/usr/bin/env bash` statt `#!/usr/bin/env bash` — das `!` fehlt
- Script wird bei direktem Aufruf (`./dev-env`) nicht korrekt ausgefuehrt

### 2. Fehlender Shebang in `runs/oh-my-posh`
- **Datei:** `runs/oh-my-posh`, Zeile 1
- Script hat keinen Shebang, startet direkt mit `if [ ! -d...`

### 3. Kaputte PATH-Erweiterung in `.bashrc`
- **Datei:** `env/.bashrc`, Zeilen 118-119
- `~.` statt `~/` — expandiert zu `$HOME` + literaler Punkt
- `$HOME./local/bin` existiert nicht
- Fix: `~/.local/bin` bzw. `$HOME/.local/bin`

### 4. Invertierte Filter-Logik in `run`
- **Datei:** `run`, Zeile 38
- `grep -qv` matched alles was NICHT dem Filter entspricht
- `./run pyenv` ueberspringt pyenv statt es auszufuehren
- Fix: `grep -q` statt `grep -qv`

---

## Schwerwiegend

### 5. Symlink wird sofort wieder geloescht in `runs/tmux`
- **Datei:** `runs/tmux`, Zeilen 14 und 19
- Zeile 14 erstellt Symlink, Zeile 19 loescht ihn direkt wieder
- Am Ende existiert keine tmux.conf

### 6. Unquoted Variables ueberall
- **Dateien:** `dev-env`, `run`, `install.sh`
- Variablen wie `$script_dir`, `$to/$dir`, `$HOME/personal` nicht gequoted
- Bricht bei Pfaden mit Leerzeichen

### 7. Kein `set -e` in kritischen Scripts
- **Dateien:** `install.sh`, `run`, `dev-env`
- Nur `git-cloner` hat `set -e`, alle anderen laufen bei Fehlern weiter
- z.B. wenn `git clone` in `runs/neovim` fehlschlaegt, wird `make` im falschen Verzeichnis ausgefuehrt

### 8. Hardcoded Pfade in `runs/tmux`
- **Datei:** `runs/tmux`, Zeilen 5, 16, 72
- `TMUX_DIR="$HOME/personal/dev/env/.config/tmux"` ist absolut
- Sollte relativ zum Script sein: `$(dirname "$0")/../env/.config/tmux`

### 9. ~~`xclip` nicht installiert aber in tmux.conf genutzt~~ ✓ DONE
- `copy-pipe-and-cancel 'xclip ...'` ersetzt durch `copy-selection-and-cancel`
- `tmux-yank` Plugin übernimmt Clipboard-Integration automatisch

---

## Portabilitaet (WSL -> Linux)

### 10. Keine Plattform-Erkennung
- Kein Script erkennt ob WSL oder natives Linux laeuft
- Zwischenablage braucht unterschiedliche Tools:
  - WSL: `clip.exe`
  - Wayland: `wl-copy`
  - X11: `xclip` / `xsel`
- Vorschlag: WSL-Erkennung via `grep -qi microsoft /proc/version`

### 11. Nur `apt` als Paketmanager
- Alle Scripts setzen Debian/Ubuntu voraus
- Auf Fedora/Arch funktioniert nichts
- Vorschlag: Distro-Erkennung via `/etc/os-release`

---

## Kleinere Probleme & Verbesserungen

### 12. ~~`addToPathFront` Logik unklar~~ ✓ DONE
- Force-Flag `$2` entfernt, Funktion prüft nur noch ob Pfad bereits in PATH ist

### 13. ~~Hardcoded NVM-Version~~ ✓ DONE
- Version wird jetzt dynamisch per GitHub API geholt (`releases/latest`)

### 14. `curl | bash` ohne Verifikation — bewusst nicht umgesetzt
- Kein offizieller Hash-Support durch die betroffenen Projekte
- Alle Scripts haben `set -e` und HTTPS; akzeptiertes Risiko für persönliches Dotfile-Repo

### 15. Persoenliche E-Mail im Repo
- **Datei:** `env/.gitconfig`, Zeilen 1-3
- `mastertomi01@googlemail.com` hardcoded
- Besser in `.gitconfig.local` auslagern und per `[include]` einbinden

### 16. ~~Filter in `run` akzeptiert nur letzten Parameter~~ ✓ DONE
- `filter` durch `filters=()` Array ersetzt; `./run foo bar` führt jetzt beide aus

### 17. Kein Error Handling in Installationsscripts
- **Dateien:** alle `runs/*`
- Fehler werden mit `2>/dev/null` verschluckt
- Debugging bei fehlgeschlagenen Installationen sehr schwierig

### 18. ~~Keine Input-Validierung in `git-cloner`~~ ✓ DONE
- Regex-Check für SSH-URL Format `git@host:user/repo.git` ergänzt

### 19. ~~Inkonsistente Error-Messages~~ ✓ DONE
- Alle Fehlermeldungen gehen jetzt nach stderr (`>&2`)
