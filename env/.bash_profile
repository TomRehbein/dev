#!/usr/bin/env bash
# ~/.bash_profile — sourced for login shells only (bash).
# Shared shell-neutral setup lives in ~/.shell_common.sh; this file adds only
# the bash-specific bits (keybindings) and then sources ~/.bashrc.

# ---- Shared shell-neutral login config (env, PATH, tool inits, functions) ----
[ -f ~/.shell_common.sh ] && source ~/.shell_common.sh

# ---- Keybindings (bash-specific) ----

bind -x '"\C-f": "~/.local/scripts/tmux-sessionizer"' 2>/dev/null
bind -x '"\C-g\C-w": git-clone-work' 2>/dev/null
bind -x '"\C-g\C-p": git-clone-personal' 2>/dev/null

# ---- Source .bashrc for interactive login shells ----

[ -f ~/.bashrc ] && source ~/.bashrc
