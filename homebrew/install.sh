#!/bin/bash


update_homebrew() {
    echo 'Updating Homebrew...'
    brew update
}

list_installables_from() {
    local directory=$1
    for file in 'versioned.txt' 'local.txt'
    do
        local path="$directory/$file"
        if [ -f $path ]
        then
            while read line
            do
                echo $line
            done < $path
        fi
    done
}

is_tap_installed() {
    local tap=$1
    [[ $(brew tap | grep "$tap") ]]
}

install_tap() {
    local tap=$1
    if ! is_tap_installed "$tap"
    then
        echo "Tapping $tap..."
        brew tap "$tap"
    fi
}

install_taps() {
    for tap in $(list_installables_from taps)
    do
        install_tap "$tap"
    done
}

prepare_homebrew_cask() {
    install_tap 'caskroom/cask'
    echo 'Updating Homebrew Cask...'
    brew cask update
}

is_cask_available() {
    local cask=$1
    [[ -z $(brew cask info "$cask" 2>&1 | grep -i 'error: no available cask') ]]
}

is_cask_installed() {
    local cask=$1
    [[ -z $(brew cask info "$cask" 2>&1 | grep -i 'not installed') ]]
}

install_cask() {
    local cask=$1
    if ! is_cask_available "$cask"
    then
        echo "Error: No available Cask for $cask" >&2
    elif is_cask_installed "$cask"
    then
        echo "Cask $cask: OK"
    else
        echo "Installing Cask $cask..."
        brew cask install --appdir=/Applications "$cask"
    fi
}

install_casks() {
    prepare_homebrew_cask
    for cask in $(list_installables_from casks)
    do
        install_cask "$cask"
    done
}

is_bottle_available() {
    local bottle=$1
    [[ -z $(brew info "$bottle" 2>&1 | grep -i 'error: no available formula') ]]
}

is_bottle_installed() {
    local bottle=$1
    [[ -z $(brew info "$bottle" 2>&1 | grep -i 'not installed') ]]
}

install_bottle() {
    local bottle=$1
    if ! is_bottle_available "$bottle"
    then
        echo "Error: No available Bottle for $bottle" >&2
    elif is_bottle_installed "$bottle"
    then
        echo "Bottle $bottle: OK"
    else
        echo "Installing Bottle $bottle..."
        brew install "$bottle"
    fi
}

install_bottles() {
    for bottle in $(list_installables_from bottles)
    do
        install_bottle "$bottle"
    done
}

main() {
    update_homebrew
    install_taps
    install_casks
    install_bottles
}

main
