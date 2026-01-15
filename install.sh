sudo apt -y update

if ! command -v git &> /dev/null; then
    sudo apt -y install git
fi

if [ ! -d $HOME/.config ]; then
    mkdir $HOME/.config
fi

if [ ! -d $HOME/personal ]; then
    mkdir $HOME/personal
fi

if [ ! -d $HOME/work ]; then
    mkdir $HOME/work
fi

git clone https://github.com/TomRehbein/dev $HOME/personal/dev

pushd $HOME/personal/dev
./run
./dev-env
popd
