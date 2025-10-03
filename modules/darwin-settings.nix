{ config, ... }:
{
  system = {
    primaryUser = "maxrn";
    stateVersion = 6;
    defaults = {
      smb.NetBIOSName = config.networking.hostName;
      trackpad.Clicking = true; # enable tap to click
      dock = {
        autohide = true;
        magnification = true;
        tilesize = 64;
        show-recents = false;
        largesize = 80;
      };
      NSGlobalDomain = {
        # allow pressing Cmd + Control to drag window while clicking anywhere
        NSWindowShouldDragOnGesture = true;
        # show hidden files in Finder
        AppleShowAllFiles = true;
      };
      finder = {
        # delete files in bin after 30 days
        FXRemoveOldTrashItems = true;
        # when searching in Finder, use the current folder by default (defaults to entire mac otherwise)
        FXDefaultSearchScope = "SCcf";
      };
      # Customize settings that not supported by nix-darwin directly
      # see the source code of this project to get more undocumented options:
      #    https://github.com/rgcr/m-cli
      #
      # https://daiderd.com/nix-darwin/manual/index.html
      # All custom entries can be found by running `defaults read` command.
      # or `defaults read xxx` to read a specific domain.
      CustomUserPreferences = {
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
      };
    };
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    reattach = true;
  };
}
