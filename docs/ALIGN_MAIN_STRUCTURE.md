# Plan: main strukturell an macos/arch angleichen

**Status:** offen
**Ziel:** `main` (Ubuntu/WSL) bekommt dasselbe Skelett wie die Branches `macos` und `arch`:
`lib/os.sh`-Abstraktion, `require_os`-Guards, `.shell_common.sh`. Danach unterscheiden
sich die Branches nur noch in Paketlisten und OS-Overrides — gemeinsame Fixes müssen
nicht mehr 3× manuell portiert werden.

**Warum:** Heute (2026-06-11) mussten identische Bugfixes (playwright-Paketname,
opencode-Installer, nvm-Fallback, …) einzeln auf alle drei Branches portiert werden.
Diffs zwischen den Branches sind durch die Struktur-Divergenz unnötig groß.

**Referenz:** Der `arch`-Branch ist die vollständigste Vorlage (sein `lib/os.sh` ist
ein Superset mit ubuntu-, macos- und arch-Case plus AUR-Helpern). Diff-Basis:

```bash
git diff main arch -- lib/ run dev-env env/.shell_common.sh runs/
```

---

## Schritt 1 — `lib/os.sh` übernehmen

```bash
git checkout arch -- lib/os.sh
```

- Der ubuntu-Case (`dpkg -s` + `apt install`) ist bereits eingebaut — keine Anpassung nötig.
- Referenz-Commit auf arch: `02cb0db` (feat(lib): os.sh abstraction).
- ⚠️ Danach den brew-dedup-Fix prüfen: macos/arch haben nur noch **einen**
  `brew list`-Call pro Paket (nicht zwei). Stand nach `fce2a57` (arch) übernehmen.

## Schritt 2 — `run` und `dev-env` anpassen

Vorlage: arch-Branch (`b9ae7d4` + spätere Fixes).

- [ ] `set -e` → `set -euo pipefail` (beide Dateien)
- [ ] Nach `script_dir`-Zeile einfügen:
  ```bash
  # shellcheck source=lib/os.sh
  source "$script_dir/lib/os.sh"
  require_os ubuntu
  ```
- [ ] `run`: `find ./runs ... -executable` → `-perm -u+x` (portabel GNU/BSD, hält die Branches diff-frei)
- [ ] `run`: `${filters[*]}` → `${filters[*]:-}` (set -u + leeres Array)
- [ ] `dev-env`: OS-Override-Hook vor den `copy_dir`-Aufrufen einfügen (von arch übernehmen):
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
  `env/os/ubuntu/` existiert nicht → No-op, aber Struktur ist da.

## Schritt 3 — `runs/`-Skripte umstellen

Pro Skript (Vorlage arch: `8ba33ba`, `ee6bf19`, `6fc2bce`):

- [ ] Header vereinheitlichen:
  ```bash
  set -euo pipefail   # Ausnahme 04-nvm + 05-pyenv: set -eo pipefail (nvm/pyenv nutzen unset vars)

  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=../lib/os.sh
  source "$SCRIPT_DIR/../lib/os.sh"
  require_os ubuntu
  ```
- [ ] `01-libs`: apt-Loop durch `pkg_install "${APT_PACKAGES[@]}"` ersetzen
- [ ] `02-tmux`: dpkg-Check durch `pkg_install tmux` ersetzen (idempotent)
- [ ] `03-oh-my-posh`: `sudo apt install unzip -y` → `pkg_install unzip`
- [ ] `05-pyenv`: apt-Block → `pkg_install make build-essential libssl-dev ...`
- [ ] `07-neovim`: apt-Build-Deps → `pkg_install` (Rest bleibt: /usr/local + sudo make install)
- [ ] Übrige Skripte (04, 06, 08–13): nur Header, Logik bleibt

## Schritt 4 — `.shell_common.sh` einführen (der heikle Teil)

Vorlage arch: `986026b` + `1739e3b`. **Betrifft das laufende WSL-Setup — auf
Test-Maschine oder in Container validieren, bevor `./dev-env` lokal läuft.**

- [ ] `env/.shell_common.sh` von arch übernehmen (shell-neutrale Login-Config:
      Env-Vars, PATH-Setup via `addToPath`/`addToPathFront`, pyenv/nvm-Init, Funktionen).
      Der brew-Block ist mit `[ -x /opt/homebrew/bin/brew ]` geguardet → No-op auf Linux.
- [ ] `env/.bash_profile` entschlacken: alles was nach `.shell_common.sh` gewandert
      ist raus, stattdessen `[ -f ~/.shell_common.sh ] && source ~/.shell_common.sh`
- [ ] `env/.bashrc`: Guard für Non-Login-Shells übernehmen (arch `1739e3b`):
  ```bash
  if [ -z "${_SHELL_COMMON_LOADED:-}" ] && [ -f ~/.shell_common.sh ]; then
      source ~/.shell_common.sh
  fi
  ```
- [ ] `dev-env`: Deploy-Zeile ergänzen:
  ```bash
  copy_file "$script_dir/env/.shell_common.sh" "$HOME"
  ```
- [ ] ⚠️ WSL-Spezifika aus dem heutigen `.bash_profile`/`.bashrc` (Windows-PATH,
      Aliase etc.) NICHT in `.shell_common.sh` ziehen — die bleiben Ubuntu-/main-spezifisch
      in den bash-Dateien oder wandern nach `env/os/ubuntu/`.

## Schritt 5 — `99-checks` umstellen

- [ ] Header wie Schritt 3 (source + `require_os ubuntu`)
- [ ] `check_apt` intern auf `pkg_check` umstellen — **aber WSL-Logik behalten**
      (`IS_WSL`, `_windows_version`, /mnt-Pfad-Warnungen). Die gibt es auf
      macos/arch nicht, sie ist main-spezifisch und wertvoll.

## Schritt 6 — Validierung

- [ ] `./run --dry && ./dev-env --dry` lokal
- [ ] Push → `.github/workflows/test-ubuntu.yml` läuft (Dry-run + Full install + 99-checks)
- [ ] Erst nach grüner CI: `./dev-env` auf der eigenen WSL-Maschine

## Risiken

| Risiko | Mitigation |
|--------|-----------|
| `.bash_profile`/`.bashrc`-Umbau zerschießt laufendes WSL-Setup | CI validiert; lokales Deploy erst nach grüner CI; altes `~/.bash_profile` vorher sichern |
| `set -u` deckt latente unbound-Variablen in alten Skripten auf | Dry-run + CI fangen das; 04/05 bewusst ohne `-u` |
| WSL-Verhalten in CI nicht testbar (Runner ist kein WSL) | WSL-Pfade manuell auf der eigenen Maschine gegentesten |

## Nicht-Ziele

- Kein Merge der Branches — drei Branches bleiben (ein Branch pro OS, per Mission).
- Keine Paketlisten-Vereinheitlichung — apt/brew/pacman-Namen bleiben je Branch.
