# My (new) dotfiles


## MacOS settings

- Disable language switcher pop-up: https://stackoverflow.com/questions/77248249/disable-macos-sonoma-text-insertion-point-cursor-caps-lock-indicator
```shell
sudo mkdir -p /Library/Preferences/FeatureFlags/Domain
sudo /usr/libexec/PlistBuddy -c "Add 'redesigned_text_cursor:Enabled' bool false" /Library/Preferences/FeatureFlags/Domain/UIKit.plist
```

## New device

- set keyboard layout to English - ABC
- generate ssh key
- login to github in browser and add ssh key
- install xcode tools
- install lix
- clone dotfiles
- add new host for new machine
    - find out hostname with 'scutil ...'
    - Or change it beforehand to a cooler name
    - adapt in config
- install nix-darwin: https://github.com/nix-darwin/nix-darwin

```shell
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#ohnezahn
```

- install karabiner elements from website: https://karabiner-elements.pqrs.org/
    - Make sure it has permissions in Private & Security > Input monitoring
    - and in General > Anmeldeobjekte & Erweiterungen

!!! Make sure that kanata is allowed/added in: !!!
- Make sure it has permissions in Private & Security > Input monitoring
- and in General > Anmeldeobjekte & Erweiterungen


- after setup steps:
- chsh -s to make fish default
- Run and setup aldente
- Run and configure raycast for app switching

## Config reference

- Kanata: https://jtroo.github.io/config.html#tap-hold
- Someone else's Kanata config: https://github.com/linkarzu/dotfiles-latest/blob/main/kanata/configs/macos.kbd
