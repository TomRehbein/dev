# ~/.bashrc — sourced for interactive (non-login) shells
# Aliases, prompt, shell options, completions, and per-session tool setup.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# ---- Login env for non-login shells ----
# Arch terminal emulators open non-login interactive shells — .bash_profile is
# never sourced. Source .shell_common.sh here so PATH, tool inits, and env vars
# (pyenv, nvm, oh-my-posh, etc.) are available in every interactive session.
# The _SHELL_COMMON_LOADED guard prevents double-sourcing in login shells.
if [ -z "${_SHELL_COMMON_LOADED:-}" ] && [ -f ~/.shell_common.sh ]; then
    source ~/.shell_common.sh
fi

# ---- History ----

HISTCONTROL=ignoredups:ignorespace
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend

# ---- Shell options ----

shopt -s checkwinsize

# ---- Pager ----

# lesspipe is a Debian package living at /usr/bin/lesspipe — Linux only.
# Guard keeps macOS (no such binary) from erroring.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ---- Prompt (plain fallback, overridden by oh-my-posh below) ----

# /etc/debian_chroot only exists on Debian/Ubuntu — guard skips it elsewhere.
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color) color_prompt=yes ;;
esac

if [ -n "$force_color_prompt" ]; then
    # `command -v tput` instead of a hardcoded /usr/bin path (macOS differs).
    if command -v tput >/dev/null 2>&1 && tput setaf 1 >&/dev/null; then
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

# GNU coreutils path (Linux): dircolors + `ls --color`. Not present on macOS,
# whose BSD `ls` uses CLICOLOR/LSCOLORS instead (handled in the else branch).
if command -v dircolors >/dev/null 2>&1; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    export LS_COLORS='di=01;33:ln=01;35:so=01;32:pi=01;36:ex=01;31:bd=01;33:cd=01;33:su=01;35:sg=01;35:tw=01;32:ow=01;32:'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
else
    # macOS / BSD ls: enable ANSI colors via CLICOLOR.
    export CLICOLOR=1
    export LSCOLORS='ExGxFxdxCxegedabagaced'
fi

# ---- Aliases ----

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

[ -f ~/.bash_aliases ] && source ~/.bash_aliases

# ---- Completions ----

if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        # Linux (Debian/Ubuntu) location.
        source /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        source /etc/bash_completion
    elif [ -n "${HOMEBREW_PREFIX:-}" ] && [ -f "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]; then
        # macOS via Homebrew (HOMEBREW_PREFIX set by brew shellenv).
        source "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
    elif [ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
        source /opt/homebrew/etc/profile.d/bash_completion.sh
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

if command -v oh-my-posh >/dev/null 2>&1; then
    eval "$(oh-my-posh init bash --config "${XDG_CONFIG_HOME:-$HOME/.config}/omp/the-unnamed.omp.json")"
fi
