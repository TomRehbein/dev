#!/usr/bin/env bash
# ~/.bash_profile — sourced for login shells only
# Sets up environment variables, PATH, and tools that only need to run once.
# Sources ~/.bashrc at the end for interactive login shells.

export XDG_CONFIG_HOME="$HOME/.config"
export GIT_EDITOR="nvim"
export PYENV_ROOT="$HOME/.pyenv"
export NVM_DIR="$HOME/.nvm"
export BUN_INSTALL="$HOME/.bun"

export PERSONAL="$HOME/personal"
export WORK="$HOME/work"
export DEV_ENV_HOME="$PERSONAL/dev"

# ---- PATH helpers ----

addToPath() {
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH="$PATH:$1"
    fi
}

addToPathFront() {
    # Force prepend if $2 is set, otherwise only if not already in PATH
    if [[ -n "$2" ]] || [[ "$PATH" != *"$1"* ]]; then
        export PATH="$1:$PATH"
    fi
}

# User scripts and binaries
addToPathFront "$HOME/.local/bin"
addToPathFront "$HOME/.local/scripts"
addToPathFront "$HOME/.local/apps"

# Language runtimes
addToPathFront "$HOME/.pyenv/bin"
addToPath      "$HOME/.cargo/bin"
addToPath      "$HOME/.npm-global/bin"

# Tools
addToPath "$BUN_INSTALL/bin"
addToPath "$HOME/.opencode/bin"

# ---- Tool inits (run once at login) ----

eval "$(pyenv init -)"

# ---- Keybindings ----

bind -x '"\C-f": "~/.local/scripts/tmux-sessionizer"' 2>/dev/null
bind -x '"\C-g\C-w": git-clone-work' 2>/dev/null
bind -x '"\C-g\C-p": git-clone-personal' 2>/dev/null

# ---- Functions ----

git-clone-work() {
    read -rp "(work) SSH URL: " url
    [ -z "$url" ] && return 1
    read -rp "(work) Custom name (optional): " name
    ~/.local/scripts/git-cloner work "$url" "$name"
}

git-clone-personal() {
    read -rp "(personal) SSH URL: " url
    [ -z "$url" ] && return 1
    read -rp "(personal) Custom name (optional): " name
    ~/.local/scripts/git-cloner personal "$url" "$name"
}

alias bco="npm run build-css-once && ~/csd2-linux --cssFile=./assets/packaged/index.min.css --output"

# ---- Local overrides (not committed) ----

[ -f ~/.bash_profile.local ] && source ~/.bash_profile.local

# ---- Source .bashrc for interactive login shells ----

[ -f ~/.bashrc ] && source ~/.bashrc
