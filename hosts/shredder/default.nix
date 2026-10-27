{ pkgs-unstable, ... }:
let
  hostname = "shredder";
in
{
  imports = [
    ../../modules/darwin-common.nix
    ./homebrew.nix
  ];

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

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local = {
    touchIdAuth = true;
  };

  # The 1Password app only integrates with an op installed at /usr/local/bin/op.
  programs._1password = {
    enable = true;
    package = pkgs-unstable._1password-cli;
  };

}
