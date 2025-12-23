Init after fresh installation

```
#!/usr/bin/env bash
sudo apt -y update

if ! command -v git &> /dev/null; then
    sudo apt -y install git
fi

git clone https://github.com/TomRehbein/dev $HOME/dev

pushd $HOME/dev
./run
./dev-env
popd
```
