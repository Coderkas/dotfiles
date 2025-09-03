#!/usr/bin/env bash
if ! cd ~/dotfiles; then
    echo "dotfiles directory couldn't be changed into"
    exit
fi

if [[ "$1" == 1 ]]; then
    git add . && nh os switch ~/dotfiles -H "$2"
elif [[ "$1" == 2 ]]; then
    if ! git diff --quiet; then
        echo -e "\033[0;95mwarning:\033[0m there are untracked files so the update was abborted"
    elif ! git diff --cached --quiet; then
        echo -e "\033[0;95mwarning:\033[0m there are uncommited files so the updated was aborted"
    else
        nix flake update && git commit -a -m 'flake update' && sudo nixos-rebuild switch --flake ~/dotfiles#"$2" --upgrade
    fi
fi
