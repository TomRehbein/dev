# ~/.bashrc — sourced for interactive (non-login) shells
# Aliases, prompt, shell options, completions, and per-session tool setup.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# ---- History ----

HISTCONTROL=ignoredups:ignorespace
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend

# ---- Shell options ----

shopt -s checkwinsize

# ---- Pager ----

if [ -x /usr/bin/lesspipe ]; then
    eval "$(SHELL=/bin/sh lesspipe)"
fi

# ---- Prompt (plain fallback, overridden by oh-my-posh below) ----

if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color) color_prompt=yes ;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

case "$TERM" in
    xterm* | rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
esac

# ---- Colors ----

if [ "$(uname -s)" = "Darwin" ]; then
    # macOS: use built-in ls color support
    export CLICOLOR=1
    export LSCOLORS="ExGxFxDxCxDxDxhbhdacEc"
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
elif [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    export LS_COLORS='di=01;33:ln=01;35:so=01;32:pi=01;36:ex=01;31:bd=01;33:cd=01;33:su=01;35:sg=01;35:tw=01;32:ow=01;32:'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ---- Aliases ----

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

[ -f ~/.bash_aliases ] && source ~/.bash_aliases

# ---- Completions ----

if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        source /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        source /etc/bash_completion
    elif [ "$(uname -s)" = "Darwin" ]; then
        # Homebrew bash-completion@2
        if [ -r "$(brew --prefix 2>/dev/null)/etc/profile.d/bash_completion.sh" ]; then
            source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
        fi
    fi
fi

# ---- fzf ----

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

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

# ---- Prompt: oh-my-posh ----

# Use the native binary explicitly — on WSL, oh-my-posh.exe may be on the
# Windows PATH and would produce a broken prompt if used here.
_omp_bin=""
if [ -x "$HOME/.local/bin/oh-my-posh" ]; then
    _omp_bin="$HOME/.local/bin/oh-my-posh"
elif command -v oh-my-posh &>/dev/null; then
    _omp_bin="$(command -v oh-my-posh)"
fi

if [ -n "$_omp_bin" ]; then
    eval "$("$_omp_bin" init bash --config "${XDG_CONFIG_HOME:-$HOME/.config}/omp/the-unnamed.omp.json")"
fi
unset _omp_bin
