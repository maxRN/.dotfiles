#!/bin/bash

if [ "$1" == "light" ]; then
    echo "switching to light theme..."

    # switch nvim
    gsed -i 's/set background=dark/set background=light/' $HOME/.dotfiles/nvim/.config/nvim/init.vim

    # switch alacritty theme
    ALACRITTY_CONFIG="$HOME/.dotfiles/alacritty/.config/alacritty/alacritty.yml"
    gsed -i "/# Colors begin/, /# Colors end/{//!d}" ${ALACRITTY_CONFIG}
    gsed -i "/# Colors begin/r $HOME/.dotfiles/colors/gruvbox_light.color" ${ALACRITTY_CONFIG}

    # switch bat theme
    gsed -i 's/--theme="gruvbox-dark"/--theme="gruvbox-light"/' $HOME/.dotfiles/bat/.config/bat/config
    echo "done"
elif [ "$1" == "dark" ]; then
    echo "switching to dark theme..."

    # switch nvim
    gsed -i 's/set background=light/set background=dark/' $HOME/.dotfiles/nvim/.config/nvim/init.vim

    # switch alacritty theme
    ALACRITTY_CONFIG="$HOME/.dotfiles/alacritty/.config/alacritty/alacritty.yml"
    gsed -i "/# Colors begin/, /# Colors end/{//!d}" ${ALACRITTY_CONFIG}
    gsed -i "/# Colors begin/r $HOME/.dotfiles/colors/gruvbox_dark.color" ${ALACRITTY_CONFIG}

    # switch bat theme
    gsed -i 's/--theme="gruvbox-light"/--theme="gruvbox-dark"/' $HOME/.dotfiles/bat/.config/bat/config 
    echo "done"
else
    echo "unknown or missing command ${1}"
fi

