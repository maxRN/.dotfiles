{ pkgs, ... }:
let
  hostname = "MB-Q5JMWQ5VFD";
  username = "maxrn";
in
{
  imports = [
    ../../modules/configuration.nix
    ../../modules/sops.nix
  ];
  environment = {
    variables = {
      GOKU_EDN_CONFIG_FILE = "$HOME/.config/goku/karabiner.edn";
    };
  };

  homebrew = {
    enable = true;
    taps = [ "FelixKratz/formulae" ];
    brews = [
    ];
  };

  programs = {
    fish.enable = true;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system = {
    primaryUser = "Max Große";
    stateVersion = 4;
    defaults = {
      smb.NetBIOSName = hostname;
      dock = {
        autohide = true;
        magnification = true;
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

  nix.settings.trusted-users = [ username ];

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;
  environment.shells = [ pkgs.fish ];

}
