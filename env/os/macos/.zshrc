# ~/.zshrc — sourced for interactive zsh shells (macOS default shell).
# zsh counterpart to ~/.bashrc. The shared login config (PATH, tool inits) is
# loaded by ~/.zprofile via ~/.shell_common.sh, so this file only holds the
# interactive bits, written in zsh syntax.

# ---- History ----

HISTSIZE=1000
SAVEHIST=2000
HISTFILE="$HOME/.zsh_history"
setopt hist_ignore_dups hist_ignore_space append_history share_history

# ---- Colors (macOS / BSD ls) ----

export CLICOLOR=1
export LSCOLORS='ExGxFxdxCxegedabagaced'

# ---- Aliases ----

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

[ -f ~/.bash_aliases ] && source ~/.bash_aliases

# ---- Completions ----

# Homebrew-provided zsh completions, then init the completion system.
if [ -n "${HOMEBREW_PREFIX:-}" ] && [ -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]; then
    fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
fi
autoload -Uz compinit && compinit

# ---- fzf ----

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ---- pyenv (per-session, needed in non-login interactive shells) ----

export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
if [[ ":$PATH:" != *":$PYENV_ROOT/bin:"* ]]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
fi
if [ -x "$PYENV_ROOT/bin/pyenv" ]; then
    eval "$(pyenv init -)"
fi

# ---- nvm (per-session) ----

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

# ---- Keybindings ----

# Ctrl-f → tmux-sessionizer (mirrors the bash binding in ~/.bash_profile).
_tmux_sessionizer() { ~/.local/scripts/tmux-sessionizer; }
zle -N _tmux_sessionizer
bindkey '^f' _tmux_sessionizer

# ---- Prompt: oh-my-posh ----

if command -v oh-my-posh >/dev/null 2>&1; then
    eval "$(oh-my-posh init zsh --config "${XDG_CONFIG_HOME:-$HOME/.config}/omp/the-unnamed.omp.json")"
fi
