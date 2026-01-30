export XDG_CONFIG_HOME=$HOME/.config
VIM="nvim"

PERSONAL=$HOME/personal
WORK=$HOME/work
DEV_ENV=$PERSONAL/dev

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export GIT_EDITOR=$VIM
export DEV_ENV_HOME="$HOME/personal/dev"
export PYENV_ROOT="$HOME/.pyenv"

bind -x '"\C-f": "~/.local/scripts/tmux-sessionizer"' 2> /dev/null

git-clone-work() {
    read -p "(work) SSH URL: " url
    if [ -z "$url" ]; then
        return 1
    fi
    read -p "(work) Custom name (optional): " name
    ~/.local/scripts/git-cloner work "$url" "$name"
}

git-clone-personal() {
    read -p "(personal) SSH URL: " url
    if [ -z "$url" ]; then
        return 1
    fi
    read -p "(personal) Custom name (optional): " name
    ~/.local/scripts/git-cloner personal "$url" "$name"
}
bind -x '"\C-g\C-w": git-clone-work'
bind -x '"\C-g\C-p": git-clone-personal'

alias bco="npm run build-css-once && ~/csd2-linux --cssFile=./assets/packaged/index.min.css --output"

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
addToPathFront $HOME/.pyenv/bin
addToPathFront $HOME/.nvm

addToPath $HOME/.cargo/bin
addToPath $HOME/.local/personal
addToPath $HOME/.npm-global/bin

eval "$(pyenv init -)"

[ -f ~/.bashrc ] && source ~/.bashrc
