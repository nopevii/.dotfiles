#!/bin/sh

logger() {
    printf "[SETUP] $1\n"
}

setup_firefox() {
    repo="https://raw.githubusercontent.com/arkenfox/user.js/master"

    logger "installing required packages if missing..."
    sudo pacman -S --noconfirm --needed unzip > /dev/null 2> /dev/null

    logger "creating firefox default profile if not exists"
    [ -d $HOME/.mozilla ] || {
        firefox --headless &
        sleep 1
        pkill firefox
    }

    logger "going to default profile dir"
    cd $HOME/.mozilla/firefox/*.default-release/

    logger "downloading arkenfox scripts and user overrides..."
    [ -f updater.sh ] || { curl -sLO $repo/updater.sh; chmod 700 updater.sh; }
    [ -f prefsCleaner.sh ] || { curl -sLO $repo/prefsCleaner.sh; chmod 700 prefsCleaner.sh; }
    cp $HOME/.dotfiles/user-overrides.js .

    logger "running arkenfox scripts..."
    echo y | ./updater.sh
    echo 1 | ./prefsCleaner.sh

    logger "installing extensions..."
    [ -d ./extensions ] || mkdir ./extensions

    addons="ublock-origin istilldontcareaboutcookies darkreader vimium-c"

    for addon in $addons; do
        logger "installing $addon..."
        [ "$addon" = "ublock-origin" ] \
            && url="$(curl -sL https://api.github.com/repos/gorhill/uBlock/releases/latest | grep -E "browser_download_url.*\.firefox.*\.xpi" | cut -d "\"" -f 4)" \
            || url="$(curl --silent "https://addons.mozilla.org/en-US/firefox/addon/${addon}/" | grep -o "https://addons.mozilla.org/firefox/downloads/file/[^\"]*")"
        file="${url##*/}"
        curl -LOs $url > $file
        id="$(unzip -p $file manifest.json | grep "\"id\"")"
        id="${id%\"*}"
        id="${id##*\"}"
        mv $file ./extensions/$id.xpi
    done

    logger "returning to the previous dir"
    cd -
}

error=""

ping -c 1 -W 1 google.com > /dev/null || error="internet connection is missing"
grep -qi "arch linux" /etc/os-release || error="linux distro must be arch"

[ -z "$error" ] || { logger "$error"; exit 1; }

sudo pacman -S --noconfirm --needed git

git clone https://github.com/nopevii/.dotfiles $HOME/.dotfiles 2> /dev/null || { cd $HOME/.dotfiles; git pull origin main; cd; }

sudo pacman -S --noconfirm --needed - < $HOME/.dotfiles/pacman.txt

cd $HOME/.dotfiles && stow -v --target=$HOME */

setup_firefox

[ "$SHELL" = /usr/bin/zsh ] || sudo chsh --shell /usr/bin/sh $USER

[ "$(readlink /bin/sh)" = dash ] || sudo ln -sf dash /bin/sh

sudo systemctl enable --now ufw.service && sudo ufw enable

sudo systemctl enable --now docker.service

sudo usermod -aG docker $USER

rm -f $HOME/.bash*

cd

nvim --headless +qa

rustup install stable

sudo killall -u $USER
