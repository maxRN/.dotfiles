{
  pkgs,
  lib,
  config,
  ...
}:
let
  hostname = "ohnezahn";
  username = "maxrn";
in
{
  imports = [
    ../../modules/fish-fix.nix
    ./homebrew.nix
  ];

  time.timeZone = "Europe/Berlin";

  # environment.launchDaemons = {
  #   "com.maxrn.kanata.plist" = {
  #     text = builtins.readFile ./com.maxrn.kanata.plist;
  #   };
  # };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "ffmpeg-full"
    ];

  programs = {
    fish.enable = true;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system = {
    primaryUser = "maxrn";
    stateVersion = 4;
    defaults = {
      smb.NetBIOSName = hostname;
      trackpad.Clicking = true; # enable tap to click
      dock = {
        autohide = true;
        magnification = true;
        tilesize = 64;
        show-recents = false;
        largesize = 80;
      };
      NSGlobalDomain = {
        NSWindowShouldDragOnGesture = true;
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

  nixpkgs.hostPlatform = "aarch64-darwin";

  networking = {
    hostName = hostname;
    computerName = hostname;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
    shell = pkgs.fish;
  };

  nix = {
    enable = false;
    settings = {
      trusted-users = [ username ];
      # experimental-features = "nix-command flakes";
    };
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;
  environment.shells = [ pkgs.fish ];

}
