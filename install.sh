#!/usr/bin/env bash

set -e

sudo apt -y update

if ! command -v git &> /dev/null; then
    sudo apt -y install git
fi

mkdir -p "$HOME/personal"
mkdir -p "$HOME/work"

git clone https://github.com/TomRehbein/dev "$HOME/personal/dev"

pushd "$HOME/personal/dev"
./run
./dev-env
popd
