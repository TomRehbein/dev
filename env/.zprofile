# ~/.zprofile — sourced for login shells only (zsh equivalent of .bash_profile)
# Sets up environment variables, PATH, and tools that only need to run once.
# Sources ~/.zshrc at the end for interactive login shells.

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

# Homebrew (macOS) — must be set up before anything else so brew is available
if [ "$(uname -s)" = "Darwin" ] && [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    # GNU coreutils (sort -V, etc.) — prepend gnubin so GNU versions win
    if [ -d "$(brew --prefix coreutils 2>/dev/null)/libexec/gnubin" ]; then
        addToPathFront "$(brew --prefix coreutils)/libexec/gnubin"
    fi
fi

# User scripts and binaries
export PATH="$HOME/.local/bin:$PATH"
addToPathFront "$HOME/.local/scripts"
addToPathFront "$HOME/.local/apps"

# opencode — installed to ~/.opencode/bin by the upstream installer
addToPathFront "$HOME/.opencode/bin"

# nvm node — prepend the active node version's bin so it always wins
# sort -V is GNU-only; use gsort on macOS (coreutils) when available.
if [ -d "$NVM_DIR/versions/node" ]; then
    _sort_v() { command -v gsort &>/dev/null && gsort -V || sort -V; }
    _nvm_node=$(ls "$NVM_DIR/versions/node" 2>/dev/null | _sort_v | tail -1)
    [ -n "$_nvm_node" ] && addToPathFront "$NVM_DIR/versions/node/$_nvm_node/bin"
    unset _nvm_node
    unset -f _sort_v
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
# Defined as zle widgets in .zshrc (bindkey requires zle which is only
# available in interactive shells — so keybindings live in .zshrc).

# ---- Functions ----

git-clone-work() {
    read "url?(work) SSH URL: "
    [ -z "$url" ] && return 1
    read "name?(work) Custom name (optional): "
    ~/.local/scripts/git-cloner work "$url" "$name"
}

git-clone-personal() {
    read "url?(personal) SSH URL: "
    [ -z "$url" ] && return 1
    read "name?(personal) Custom name (optional): "
    ~/.local/scripts/git-cloner personal "$url" "$name"
}

# ---- Local overrides (not committed) ----

[ -f ~/.zprofile.local ] && source ~/.zprofile.local

# ---- Source .zshrc for interactive login shells ----

[ -f ~/.zshrc ] && source ~/.zshrc
