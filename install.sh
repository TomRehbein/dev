#!/usr/bin/env bash

set -e

sudo apt -y update

if ! command -v git &> /dev/null; then
    sudo apt -y install git
fi

if [ ! -d "$HOME/personal" ]; then
    mkdir -p "$HOME/personal"
fi

if [ ! -d "$HOME/work" ]; then
    mkdir -p "$HOME/work"
fi

if [ ! -d "$HOME/personal/obsidian" ]; then
    mkdir "$HOME/personal/obsidian"
fi

if [ ! -d "$HOME/personal/dev" ]; then
    git clone https://github.com/TomRehbein/dev "$HOME/personal/dev"
fi

pushd "$HOME/personal/dev"
./run
./dev-env
popd
