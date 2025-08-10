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
    ../../modules/darwin-settings.nix
    ../../modules/kanata/kanata.nix
    ../../modules/nix-gc-optimise.nix
    ../../modules/common-options.nix
  ];

  time.timeZone = "Europe/Berlin";

  nixpkgs.hostPlatform = "aarch64-darwin";

  programs = {
    fish.enable = true;
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
  services.kanata = {
    enable = true;
    user = username;
    configs = [ "/Users/${username}/.config/kanata/macbook.kbd" ];
  };
}
