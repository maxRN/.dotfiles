# Shared by every host. Hostnames and host-specific behaviour stay in hosts/<name>.
{
  pkgs,
  config,
  ...
}:
let
  username = config.system.primaryUser;
in
{
  imports = [
    ./fish-fix.nix
    ./darwin-settings.nix
    ./nix-gc-optimise.nix
    ./common-options.nix
    ./homebrew.nix
    ./kanata/kanata.nix
    ./aerospace.nix
  ];

  time.timeZone = "Europe/Berlin";

  programs = {
    fish.enable = true;
  };

  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
    shell = pkgs.fish;
  };

  environment.shells = [ pkgs.fish ];
}
