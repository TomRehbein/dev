# lib/os.sh — OS detection + package-manager abstraction.
#
# Sourced (not executed) by install.sh and the runs/ scripts so that each
# script can stay OS-agnostic: call detect_os / pkg_install / pkg_check instead
# of hardcoding apt / brew / pacman. Keeping the OS logic here avoids per-script
# copy-paste and lets other branches (arch) reuse the same pattern.
#
# Usage:
#   source "<repo>/lib/os.sh"
#   require_os arch           # abort on the wrong OS
#   pkg_install ripgrep jq    # install only what's missing (idempotent)
#   aur_install tldr-git      # install AUR packages via yay (Arch only)
#   pkg_check rg              # 0 if available, 1 otherwise
#
# Apple Silicon only: Homebrew lives at /opt/homebrew.

# Resolve the directory this library lives in, so callers can source it
# regardless of their own location.
OS_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Fixed Homebrew prefix for Apple Silicon (per PORT_PLAN decision).
BREW_PREFIX="/opt/homebrew"

# AUR helper for Arch (per PORT_PLAN decision: yay).
AUR_HELPER="yay"

# detect_os — echo one of: ubuntu | macos | arch
# Result is cached in the _DETECTED_OS variable to avoid repeated probing.
detect_os() {
    if [ -n "${_DETECTED_OS:-}" ]; then
        echo "$_DETECTED_OS"
        return 0
    fi

    local os=""
    case "$(uname -s)" in
        Darwin)
            os="macos"
            ;;
        Linux)
            if [ -r /etc/os-release ]; then
                # shellcheck disable=SC1091
                . /etc/os-release
                case "${ID:-}:${ID_LIKE:-}" in
                    *arch*) os="arch" ;;
                    *ubuntu*|*debian*) os="ubuntu" ;;
                    *) os="${ID:-unknown}" ;;
                esac
            else
                os="unknown"
            fi
            ;;
        *)
            os="unknown"
            ;;
    esac

    _DETECTED_OS="$os"
    echo "$os"
}

# require_os <expected> — abort unless the running OS matches.
# Guards each script against running under the wrong package manager
# (e.g. a brew script on Linux, an apt script on macOS).
require_os() {
    local expected="$1"
    local actual
    actual="$(detect_os)"
    if [ "$actual" != "$expected" ]; then
        echo "ERROR: this script targets '$expected' but detected '$actual'. Aborting." >&2
        exit 1
    fi
}

# ensure_brew — make sure brew is on PATH for the current process (macOS).
# Apple Silicon: brew is not on the default PATH until shellenv is evaluated.
ensure_brew() {
    if ! command -v brew >/dev/null 2>&1; then
        if [ -x "$BREW_PREFIX/bin/brew" ]; then
            eval "$("$BREW_PREFIX/bin/brew" shellenv)"
        fi
    fi
}

# ensure_yay — make sure the yay AUR helper is available (Arch).
# Bootstraps yay from the AUR via base-devel + git when missing. Idempotent:
# does nothing if yay is already on PATH.
ensure_yay() {
    if command -v "$AUR_HELPER" >/dev/null 2>&1; then
        return 0
    fi
    echo "Bootstrapping $AUR_HELPER from the AUR..."
    # base-devel + git are required to build any AUR package.
    sudo pacman -S --needed --noconfirm base-devel git
    local build_dir
    build_dir="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay.git "$build_dir/yay"
    (cd "$build_dir/yay" && makepkg -si --noconfirm)
    rm -rf "$build_dir"
}

# aur_install <pkg...> — install AUR packages via yay, skipping any already
# installed (idempotent via pacman -Q check + yay --needed). Arch only.
aur_install() {
    [ "$#" -gt 0 ] || return 0
    local os
    os="$(detect_os)"
    if [ "$os" != "arch" ]; then
        echo "ERROR: aur_install is Arch-only (detected '$os')." >&2
        return 1
    fi
    ensure_yay
    local pkg missing=()
    for pkg in "$@"; do
        pacman -Q "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
    done
    if [ "${#missing[@]}" -gt 0 ]; then
        echo "$AUR_HELPER -S (AUR): ${missing[*]}"
        "$AUR_HELPER" -S --needed --noconfirm "${missing[@]}"
    else
        echo "$AUR_HELPER: all requested AUR packages already installed (${*})"
    fi
}

# pkg_install <pkg...> — install packages with the OS package manager,
# skipping any that are already present (idempotent).
pkg_install() {
    [ "$#" -gt 0 ] || return 0
    local os
    os="$(detect_os)"

    case "$os" in
        macos)
            ensure_brew
            local pkg missing=()
            for pkg in "$@"; do
                # `brew list` covers both formulae and casks.
                brew list "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
            done
            if [ "${#missing[@]}" -gt 0 ]; then
                echo "brew install: ${missing[*]}"
                brew install "${missing[@]}"
            else
                echo "brew: all requested packages already installed (${*})"
            fi
            ;;
        ubuntu)
            local pkg missing=()
            for pkg in "$@"; do
                dpkg -s "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
            done
            if [ "${#missing[@]}" -gt 0 ]; then
                echo "apt install: ${missing[*]}"
                sudo apt -y update
                sudo apt -y install "${missing[@]}"
            else
                echo "apt: all requested packages already installed (${*})"
            fi
            ;;
        arch)
            # --needed already skips up-to-date packages (idempotent).
            echo "pacman -S: ${*}"
            sudo pacman -S --needed --noconfirm "$@"
            ;;
        *)
            echo "ERROR: pkg_install: unsupported OS '$os'." >&2
            return 1
            ;;
    esac
}

# pkg_check <cmd> [pkg] — return 0 if the tool is available.
# Prefers a `command -v` check (works the same everywhere); falls back to the
# native package database when a command name is given that differs from the
# package name and the binary is not on PATH.
pkg_check() {
    local cmd="$1" pkg="${2:-$1}"
    if command -v "$cmd" >/dev/null 2>&1; then
        return 0
    fi
    local os
    os="$(detect_os)"
    case "$os" in
        macos)  ensure_brew; brew list "$pkg" >/dev/null 2>&1 ;;
        ubuntu) dpkg -s "$pkg" >/dev/null 2>&1 ;;
        arch)   pacman -Q "$pkg" >/dev/null 2>&1 ;;
        *)      return 1 ;;
    esac
}
