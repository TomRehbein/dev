# ~/.zshrc — sourced for interactive shells
# Aliases, prompt, shell options, completions, and per-session tool setup.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ---- History ----

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# ---- Shell options ----

setopt AUTO_CD
setopt CORRECT
setopt NO_BEEP

# ---- Completions ----

autoload -Uz compinit && compinit

# Homebrew completions
if [ -r "$(brew --prefix 2>/dev/null)/share/zsh/site-functions" ]; then
    fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi

# ---- Colors ----

export CLICOLOR=1
export LSCOLORS="ExGxFxDxCxDxDxhbhdacEc"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# ---- Aliases ----

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases

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

# ---- nvm (per-session, needed in interactive shells) ----

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# ---- Keybindings ----

# Ctrl-f → tmux-sessionizer
_tmux_sessionizer() { ~/.local/scripts/tmux-sessionizer; }
zle -N _tmux_sessionizer
bindkey "^f" _tmux_sessionizer

# Ctrl-g Ctrl-w → git-clone-work
_git_clone_work() { git-clone-work; }
zle -N _git_clone_work
bindkey "^g^w" _git_clone_work

# Ctrl-g Ctrl-p → git-clone-personal
_git_clone_personal() { git-clone-personal; }
zle -N _git_clone_personal
bindkey "^g^p" _git_clone_personal

# ---- Prompt: oh-my-posh ----

if command -v oh-my-posh &>/dev/null; then
    eval "$(oh-my-posh init zsh --config "${XDG_CONFIG_HOME:-$HOME/.config}/omp/the-unnamed.omp.json")"
fi
