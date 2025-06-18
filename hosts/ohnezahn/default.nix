{
  pkgs,
  lib,
  config,
  ...
}:
let
  hostname = "Max-MacBook-Air";
  username = "maxrn";
  sshkey = key: {
    name = key;
    value = {
      owner = config.users.users.maxrn.name;
      path = config.users.users.maxrn.home + "/.ssh/" + key;
      sopsFile = ../../secrets/ssh.yaml;
    };
  };
  pssh = keys: builtins.listToAttrs (map sshkey keys);
in
{
  imports = [
    ../../modules/fish-fix.nix
  ];

  time.timeZone = "Europe/Berlin";

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "ffmpeg-full"
    ];

  homebrew = {
    enable = true;
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

  sops = {
    # This will add secrets.yml to the nix store
    # You can avoid this by adding a string to the full path instead, i.e.
    # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
    defaultSopsFile = ../secrets/secrets.yaml;

    age = {
      # This will automatically import SSH keys as age keys
      sshKeyPaths = [ (config.users.users.maxrn.home + "/.ssh/main") ];
      generateKey = true;
      # This is using an age key that is expected to already be in the filesystem
      keyFile = config.users.users.maxrn.home + ".config/sops/age/keys.txt";
    };

    # This is the actual specification of the secrets.
    secrets = pssh [
      "scone_masterthesis"
      "github"
      "codeberg"
      "parents_pi2w"
      "raspi"
      "se-gitlab"
      "mn_gitlab"
    ];
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
