{ config, pkgs, ... }:
{

  home.packages = with pkgs; [
    coreutils-full
    gawk
    gnupatch
    gnused
  ];

  # The system nix.gc runs as root and never sees ~/.local/state/nix/profiles,
  # so home-manager generations (and the store paths they pin) pile up.
  # Not using home-manager's nix.gc: on darwin it passes options as a single
  # argv entry, which nix-collect-garbage rejects.
  launchd.agents.nix-gc = {
    enable = true;
    config = {
      ProgramArguments = [
        "${config.nix.package}/bin/nix-collect-garbage"
        "--delete-older-than"
        "30d"
      ];
      # Just before the system GC (Sunday 03:15).
      StartCalendarInterval = [
        {
          Weekday = 7;
          Hour = 3;
          Minute = 0;
        }
      ];
    };
  };
}
