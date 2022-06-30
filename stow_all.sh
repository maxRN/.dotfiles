#!/bin/bash
# see https://github.com/ThePrimeagen/.dotfiles/blob/4a8d2a7fe12293db872f7b932dae339442de0b2f/clean-env

STOW_FOLDERS="alacritty bat nvim tmux git zsh iterm"

for folder in ${STOW_FOLDERS}; do
    echo "re-stowing $folder"
    stow --restow $folder
done

