# Dev-Setup – Arch Linux

Arch-Port des Ubuntu-Dev-Setups. Paketmanager: pacman (+ AUR via yay/paru).
Default-Shell: bash. Rolling Release.

---

## Voraussetzungen

| Anforderung | Mindestversion / Hinweis |
|---|---|
| Arch Linux | Rolling Release, aktuell gehalten |
| `base-devel` | wird von `install.sh` automatisch installiert |
| `git` | wird von `install.sh` automatisch installiert |
| Internetzugang | für alle Installer erforderlich |

> `base-devel` enthält gcc, make, pkg-config u.a. – entspricht Ubuntus `build-essential`.

---

## Installation (One-liner)

```bash
curl -fsSL https://raw.githubusercontent.com/TomRehbein/dev/arch/install.sh | bash
```

Das Skript:
1. Prüft ob Arch Linux erkannt wird (bricht andernfalls ab).
2. Installiert `base-devel` und `git` via pacman, falls nicht vorhanden.
3. Klont dieses Repo nach `~/personal/dev`.
4. Führt `./run` (alle `runs/`-Skripte) und `./dev-env` (Configs) aus.

---

## Manuelle Installation (Schritt für Schritt)

```bash
# 1. Voraussetzungen
sudo pacman -S --needed base-devel git

# 2. Repo klonen
git clone https://github.com/TomRehbein/dev ~/personal/dev
cd ~/personal/dev

# 3. Alle Tools installieren (runs/01 bis runs/13)
./run

# 4. Dotfiles und Configs deployen
./dev-env

# 5. Neue Shell öffnen oder:
source ~/.bashrc
```

---

## Installierte Tools

| Schritt | Tool / Paket | Installationsweg |
|---|---|---|
| `01-libs` | git, ripgrep, jq, tealdeer, unzip, tmux, tree, htop, btop, git-delta, lldb | `pacman -S --needed` |
| `02-tmux` | tmux + TPM-Plugins | pacman + git clone |
| `03-oh-my-posh` | oh-my-posh, Meslo-Font | curl-Installer |
| `04-nvm` | nvm, Node.js LTS + latest | curl-Installer |
| `05-pyenv` | pyenv, Python (latest stable) | curl-Installer |
| `06-rust` | rustup, cargo | curl-Installer (rustup.rs) |
| `07-neovim` | neovim (aus Source) | git clone + make, nach `/usr/local` |
| `08-bun` | bun | curl-Installer (bun.sh) |
| `09-uv` | uv | curl-Installer (astral.sh) |
| `10-opencode` | opencode | curl-Installer |
| `11-claude-code` | claude (Claude Code CLI) | npm global |
| `12-opencode-dispatch` | opencode-dispatch | npm global |
| `13-playwright-cli` | playwright-cli | npm global |

---

## Nach der Installation – manuelle Schritte

```
1. Git-Identität eintragen:
   $EDITOR ~/.gitconfig.local

2. Optional: Commit-Template anpassen:
   $EDITOR ~/.gitmessage

3. Machine-spezifische Config anlegen:
   cp ~/personal/dev/env/.bash_profile.local.example ~/.bash_profile.local
   $EDITOR ~/.bash_profile.local

4. MCP-Server für Claude/opencode einrichten:
   cp ~/personal/dev/env/.claude.json.example ~/.claude.json
   $EDITOR ~/.claude.json   # TAVILY_API_KEY eintragen

5. Neue Shell öffnen (oder: source ~/.bashrc)

6. Ersten nvim-Start abwarten – lazy.nvim installiert alle Plugins automatisch.
```

---

## Abweichungen gegenüber dem Ubuntu-Setup

### Ersetzte Tools / Paketnamen

| Ubuntu | Arch | Grund |
|---|---|---|
| `apt` | `pacman -S --needed` | pacman ist der native Paketmanager |
| `dpkg -s` | `pacman -Q` | Paket-Check muss zum Paketmanager passen |
| `build-essential` | `base-devel` | Arch-Äquivalent; Gruppe statt Meta-Paket |
| `tldr` (Node-basiert) | `tealdeer` (pacman) | Rust-Client in offiziellen Repos; kein AUR nötig |
| `lua5.1` / `liblua5.1-0-dev` | `lua51` | Paketname auf Arch abweichend |
| `lldb` | `lldb` | gleicher Name, offizielles Repo |

### Weggelassene Teile

| Element | Grund |
|---|---|
| WSL-Detection (in `99-checks`) | Nicht relevant auf nativem Arch Linux |
| WSL-Pfad-Checks (`/mnt/c/...`) | Arch hat kein WSL-Subsystem |
| Homebrew-Block in `.shell_common.sh` | Guard `[ -x /opt/homebrew/bin/brew ]` – auf Arch immer No-op |
| `dircolors` + `LS_COLORS` in `.bashrc` | Bleibt erhalten (GNU-Tool, auf Arch verfügbar) |

### Strukturelle Unterschiede

- **Shell**: bash (wie Ubuntu). `.bashrc` und `.bash_profile` werden unverändert genutzt. Homebrew-spezifische Blöcke sind durch OS-Guards deaktiviert.
- **Shell-Common**: `env/.shell_common.sh` ist branch-übergreifend geteilt. Der Homebrew-Block ist mit `[ -x /opt/homebrew/bin/brew ]` geguardet – auf Arch immer No-op.
- **Neovim-Installationspfad**: Source-Build installiert nach `/usr/local` (Ubuntu-Parität). pacman's eigenes `neovim`-Paket landet in `/usr` – bewusst getrennt.
- **find-Syntax**: `./run` verwendet `-perm -u+x` statt `-executable` (BSD-Kompatibilität, funktioniert auch mit GNU-find).
- **pkg_install / pkg_check**: `lib/os.sh` stellt diese Wrapper bereit. Auf Arch rufen sie `pacman -S --needed` bzw. `command -v` mit `pacman -Q`-Fallback auf.
- **base-devel als Precondition**: Die Gruppe wird von `install.sh` installiert, nicht von einzelnen `runs/`-Skripten. Alle Build-Deps (cmake, make, gcc) sind damit immer verfügbar.

---

## Bekannte Stolperfallen

- **Rolling Release**: Gelegentlich breaking changes nach `pacman -Syu`. System vor Ausführung von `./run` vollständig aktuell halten.
- **AUR**: Dieses Setup benötigt kein AUR. Alle Pakete stammen aus den offiziellen Repos oder werden via curl-Installer bezogen. yay/paru sind optional.
- **neovim Build-Abhängigkeiten**: `cmake`, `gettext`, `lua51` werden von `runs/07-neovim` via `pkg_install` installiert. Der Build braucht ~5 Min und `sudo` für `make install` nach `/usr/local`.
- **nvm in Nicht-interaktiven Shells**: nvm ist eine Shell-Funktion, kein Binary. `runs/13-playwright-cli` setzt den Node-PATH explizit, damit npm-Globals auch in Subshells funktionieren.
- **pacman Keyring**: Bei frischer Installation ggf. `sudo pacman-key --init && sudo pacman-key --populate archlinux` nötig, bevor `pacman -S` zuverlässig funktioniert.
