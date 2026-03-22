{
  pkgs,
  config,
  ...
}:
let
  hostname = "shredder";
  username = config.system.primaryUser;
in
{
  imports = [
    ../../modules/fish-fix.nix
    ./homebrew.nix
    ./aerospace.nix
    ./kanata.nix
    ../../modules/darwin-settings.nix
    ../../modules/nix-gc-optimise.nix
    ../../modules/common-options.nix
  ];

  time.timeZone = "Europe/Berlin";

  nixpkgs.hostPlatform = "aarch64-darwin";

  programs = {
    fish.enable = true;
  };

  launchd.user.agents.turn-night-shift-on = {
    serviceConfig = {
      Label = "org.nixos.turn-night-shift-on";
      ProgramArguments = [
        "/usr/bin/shortcuts"
        "run"
        "Turn Night Shift On"
      ];
      StartCalendarInterval = {
        Hour = 6;
        Minute = 0;
      };
    };
  };

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

  environment.shells = [ pkgs.fish ];
}
