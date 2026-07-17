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

### Enable the Kanata service on macOS

The launchd service runs Kanata through the stable
`/run/current-system/sw/bin/kanata` path so its macOS Input Monitoring
permission survives changes to the versioned Nix store path.

1. Build and activate the host configuration so the stable path exists:

    ```shell
    sudo darwin-rebuild switch --flake .#shredder
    ```

2. Open **System Settings → Privacy & Security → Input Monitoring**.
3. Click `+`, press `Shift-Command-G` in the file picker, and enter:

    ```text
    /run/current-system/sw/bin/kanata
    ```

4. Select Kanata and enable its toggle. Also ensure Kanata is allowed under
   **General → Login Items & Extensions** if macOS lists it there.
5. Stop any Kanata process that was started manually, then restart the service:

    ```shell
    sudo launchctl kickstart -k system/org.nixos.kanata
    ```

6. Verify that launchd reports a running process:

    ```shell
    launchctl print system/org.nixos.kanata | rg 'state = running|pid ='
    ```

If launchd reports `Abort trap: 6` or the macOS logs contain
`TCC deny IOHIDDeviceOpen`, remove Kanata from Input Monitoring, add the stable
path again, and restart the service.


- after setup steps:
- chsh -s to make fish default
- Run and setup aldente
- Optionally install tailscale if needed

## Config reference

- Kanata: https://jtroo.github.io/config.html#tap-hold
- Someone else's Kanata config: https://github.com/linkarzu/dotfiles-latest/blob/main/kanata/configs/macos.kbd
