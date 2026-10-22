#!/usr/bin/env bash
# Sets up touchiq on a fresh macOS or Debian/Ubuntu machine. Safe to run again.
# Run it with: bash install.sh
set -Eeuo pipefail

REPO="git@github.com:TomRehbein/TouchIQ.git"
KEY="$HOME/.ssh/id_ed25519"

say() { printf '\n\033[1;34m==> %s\033[0m\n' "$1"; }
info() { printf '    %s\n' "$1"; }
die() {
  printf '\n\033[1;31mFehler: %s\033[0m\n' "$1" >&2
  printf 'Schick Tom einen Screenshot von diesem Fenster.\n' >&2
  exit 1
}
trap 'die "Schritt fehlgeschlagen (Zeile $LINENO)."' ERR

# Reads from the terminal, so the script also works when piped into bash.
ask() {
  local prompt="$1" default="${2:-}" answer
  if [ -n "$default" ]; then
    printf '%s [%s]: ' "$prompt" "$default" >/dev/tty
  else
    printf '%s: ' "$prompt" >/dev/tty
  fi
  read -r answer </dev/tty
  printf '%s' "${answer:-$default}"
}

wait_enter() {
  printf '\n%s ' "${1:-Drück Enter, wenn du so weit bist.}" >/dev/tty
  read -r _ </dev/tty
}

detect_os() {
  case "$(uname -s)" in
    Darwin) OS=mac ;;
    Linux)
      command -v apt-get >/dev/null || die "Nur Debian und Ubuntu werden unterstützt."
      OS=debian
      ;;
    *) die "Nur macOS, Debian und Ubuntu werden unterstützt." ;;
  esac
}

ask_details() {
  say "Ein paar Angaben"
  info "Name und E-Mail stehen später an deinen Änderungen im Repo."
  info "Nimm die E-Mail, mit der du bei GitHub angemeldet bist."
  NAME="$(ask "Dein Name" "$(git config --global user.name 2>/dev/null || true)")"
  while [ -z "$NAME" ]; do NAME="$(ask "Dein Name")"; done
  EMAIL="$(ask "Deine GitHub-E-Mail" "$(git config --global user.email 2>/dev/null || true)")"
  while [[ "$EMAIL" != *@*.* ]]; do EMAIL="$(ask "Bitte eine gültige E-Mail")"; done
  DIR="$(ask "Ordner für touchiq" "$HOME/TouchIQ")"
  DIR="${DIR/#\~/$HOME}"
}

# Asks for the password once and keeps sudo alive until the script ends.
sudo_once() {
  say "Admin-Passwort"
  info "Das ist das Passwort, mit dem du dich am Computer anmeldest."
  info "Beim Tippen siehst du keine Zeichen. Das ist normal."
  sudo -v
  (
    trap - ERR
    while kill -0 "$$" 2>/dev/null; do sudo -n true || true; sleep 50; done
  ) 2>/dev/null &
}

install_mac() {
  if [ ! -x /opt/homebrew/bin/brew ] && [ ! -x /usr/local/bin/brew ]; then
    say "Homebrew installieren (dauert ein paar Minuten)"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  local brew=/usr/local/bin/brew
  [ -x /opt/homebrew/bin/brew ] && brew=/opt/homebrew/bin/brew
  eval "$("$brew" shellenv)"
  if ! grep -qs 'brew shellenv' "$HOME/.zprofile"; then
    printf '\neval "$(%s shellenv)"\n' "$brew" >>"$HOME/.zprofile"
  fi

  say "git und ffmpeg installieren"
  brew install git ffmpeg

  if [ ! -d "/Applications/Google Chrome.app" ]; then
    say "Google Chrome installieren"
    brew install --cask google-chrome
  fi
}

install_debian() {
  say "git, ffmpeg und Build-Tools installieren"
  sudo apt-get update
  sudo apt-get install -y git curl unzip ffmpeg build-essential openssh-client ca-certificates
  if ! command -v google-chrome >/dev/null && ! command -v chromium >/dev/null; then
    info "Kein Chrome gefunden. touchiq läuft in Chrome, installier ihn von google.com/chrome."
  fi
}

install_bun() {
  export PATH="$HOME/.bun/bin:$PATH"
  local version major minor
  version="$(bun --version 2>/dev/null || echo 0.0)"
  IFS=. read -r major minor _ <<<"$version"
  if [ "$major" -lt 1 ] || { [ "$major" -eq 1 ] && [ "$minor" -lt 4 ]; }; then
    say "Bun installieren"
    curl -fsSL https://bun.sh/install | bash
  fi
  version="$(bun --version)"
  IFS=. read -r major minor _ <<<"$version"
  if [ "$major" -lt 1 ] || { [ "$major" -eq 1 ] && [ "$minor" -lt 4 ]; }; then
    die "Bun $version ist zu alt, touchiq braucht 1.4 oder neuer. Eine ältere Installation liegt vor $HOME/.bun/bin im PATH."
  fi
}

install_rust() {
  [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
  if command -v rustup >/dev/null; then
    say "Rust aktualisieren"
    rustup update stable
  else
    say "Rust installieren"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
    . "$HOME/.cargo/env"
  fi
}

setup_git() {
  git config --global user.name "$NAME"
  git config --global user.email "$EMAIL"
  git config --global pull.ff only
}

# ssh -T exits with 1 even when GitHub accepts the key, so check the message.
github_ok() {
  local out
  out="$(ssh -T -o StrictHostKeyChecking=accept-new -o BatchMode=yes git@github.com 2>&1 || true)"
  [[ "$out" == *"successfully authenticated"* ]]
}

copy_to_clipboard() {
  if command -v pbcopy >/dev/null; then pbcopy <"$1"
  elif command -v wl-copy >/dev/null; then wl-copy <"$1"
  elif command -v xclip >/dev/null; then xclip -selection clipboard <"$1"
  else return 1
  fi
}

open_url() {
  if [ "$OS" = mac ]; then open "$1"; else xdg-open "$1" >/dev/null 2>&1 || true; fi
}

setup_ssh() {
  say "Verbindung zu GitHub"
  if [ ! -f "$KEY" ]; then
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY" -N "" -q
    info "Neuer SSH-Schlüssel angelegt: $KEY"
  fi
  if github_ok; then
    info "GitHub kennt diesen Computer schon."
    return
  fi

  local copied=no
  copy_to_clipboard "$KEY.pub" && copied=yes
  cat <<EOF

    GitHub muss diesen Computer einmal kennenlernen. So geht's:

    1. Gleich öffnet sich github.com im Browser. Melde dich an, falls nötig.
    2. Bei "Title" trägst du einen Namen für den Computer ein, z.B. "Mein Laptop".
    3. "Key type" bleibt "Authentication Key".
    4. Ins große Feld "Key" fügst du den Schlüssel ein.
EOF
  if [ "$copied" = yes ]; then
    info "   Er ist schon kopiert, also nur einfügen (Cmd+V bzw. Strg+V)."
  else
    info "   Kopier dafür diese ganze Zeile:"
    printf '\n%s\n' "$(cat "$KEY.pub")"
  fi
  cat <<EOF

    5. Klick auf "Add SSH key". GitHub fragt evtl. nochmal nach deinem Passwort.

    Der Schlüssel ist öffentlich, den darfst du ruhig weitergeben.
    Die Datei ohne ".pub" bleibt auf diesem Computer.
EOF
  wait_enter "Drück Enter, um github.com zu öffnen."
  open_url "https://github.com/settings/ssh/new"
  wait_enter "Drück Enter, wenn du auf \"Add SSH key\" geklickt hast."
  until github_ok; do
    info "GitHub erkennt den Schlüssel noch nicht."
    info "Prüf, ob du ihn komplett eingefügt und gespeichert hast."
    wait_enter "Drück Enter, um es nochmal zu versuchen."
  done
  info "Verbindung zu GitHub steht."
}

clone_repo() {
  if [ -d "$DIR/.git" ]; then
    say "touchiq aktualisieren"
    git -C "$DIR" pull --ff-only
  elif [ -e "$DIR" ] && [ -n "$(ls -A "$DIR")" ]; then
    die "$DIR existiert schon und ist nicht leer. Starte das Script neu und nimm einen anderen Ordner."
  else
    say "touchiq herunterladen"
    git clone "$REPO" "$DIR"
  fi
}

build() {
  say "touchiq bauen (beim ersten Mal ein paar Minuten)"
  (cd "$DIR/app" && bun install)
  (cd "$DIR" && cargo build --release)
  mkdir -p "$DIR/data/matches"
}

desktop_launcher() {
  local launcher="$HOME/Desktop/$1.command"
  printf '#!/bin/bash\nexec bash "%s/scripts/%s"\n' "$DIR" "$2" >"$launcher"
  chmod +x "$launcher"
}

main() {
  detect_os
  printf '\033[1mtouchiq einrichten\033[0m\n'
  printf 'Das Script installiert alles Nötige und fragt nur, wenn es dich braucht.\n'
  ask_details
  sudo_once
  if [ "$OS" = mac ]; then install_mac; else install_debian; fi
  install_bun
  install_rust
  setup_git
  setup_ssh
  clone_repo
  build
  if [ "$OS" = mac ]; then
    desktop_launcher "TouchIQ starten" start.sh
    desktop_launcher "TouchIQ aktualisieren" update.sh
  fi

  say "Fertig"
  if [ "$OS" = mac ]; then
    info "Starten: Doppelklick auf \"TouchIQ starten\" auf dem Schreibtisch."
    info "Aktualisieren: Doppelklick auf \"TouchIQ aktualisieren\"."
  else
    info "Starten: bash \"$DIR/scripts/start.sh\""
    info "Aktualisieren: bash \"$DIR/scripts/update.sh\""
  fi
  info "Die Spiele kommen nach $DIR/data/matches/."
}

main "$@"
