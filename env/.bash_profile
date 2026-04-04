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
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH="$1:$PATH"
    fi
}

# User scripts and binaries
# ~/.local/bin is prepended unconditionally so the Linux binary always wins
# over any Windows equivalent already on the PATH (e.g. opencode.exe on WSL).
export PATH="$HOME/.local/bin:$PATH"
addToPathFront "$HOME/.local/scripts"
addToPathFront "$HOME/.local/apps"

# opencode — installed to ~/.opencode/bin by the upstream installer
addToPathFront "$HOME/.opencode/bin"

# nvm node — prepend the active node version's bin so it always wins
# over any Windows node/npm that may appear later in PATH.
if [ -d "$NVM_DIR/versions/node" ]; then
    _nvm_node=$(ls "$NVM_DIR/versions/node" 2>/dev/null | sort -V | tail -1)
    [ -n "$_nvm_node" ] && addToPathFront "$NVM_DIR/versions/node/$_nvm_node/bin"
    unset _nvm_node
fi

# Language runtimes
addToPathFront "$HOME/.pyenv/bin"
addToPath      "$HOME/.cargo/bin"
addToPath      "$HOME/.npm-global/bin"

# Tools
addToPath "$BUN_INSTALL/bin"

# ---- Tool inits (run once at login) ----

if [ -x "$PYENV_ROOT/bin/pyenv" ]; then
    eval "$(pyenv init -)"
fi

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

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

# ---- Local overrides (not committed) ----

[ -f ~/.bash_profile.local ] && source ~/.bash_profile.local

# ---- Source .bashrc for interactive login shells ----

[ -f ~/.bashrc ] && source ~/.bashrc
