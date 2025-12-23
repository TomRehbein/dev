export XDG_CONFIG_HOME=$HOME/.config
VIM="nvim"

PERSONAL=$HOME/personal
DEV_ENV=$PERSONAL/dev

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export GIT_EDITOR=$VIM
export DEV_ENV_HOME="$HOME/personal/dev"

# bind -x '"\C-f": tmux-sessionizer\n'
# bind -x '"\C-f": tmux display-popup -E -w 80% -h 80% "bash -lc ~/.local/scripts/tmux-sessionizer"'

addToPath() {
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH=$PATH:$1
    fi
}

addToPathFront() {
    if [[ ! -z "$2" ]] || [[ "$PATH" != *"$1"* ]]; then
        export PATH=$1:$PATH
    fi
}

addToPathFront $HOME/.local/apps
addToPathFront $HOME/.local/scripts
addToPathFront $HOME/.local/bin
addToPathFront $HOME/.local/npm/bin

addToPath $HOME/.cargo/bin
addToPath $HOME/.local/personal
addToPath $HOME/.npm-global/bin

[ -f ~/.bashrc ] && source ~/.bashrc
