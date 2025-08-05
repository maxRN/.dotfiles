{
  pkgs,
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
    ../../modules/darwin-settings.nix
    ../../modules/kanata/kanata.nix
  ];

  time.timeZone = "Europe/Berlin";

  programs = {
    fish.enable = true;
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  networking = {
    hostName = hostname;
    computerName = hostname;
  };

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

  environment.shells = [ pkgs.fish ];
  services.kanata = {
    enable = true;
    user = username;
    configs = [ "/Users/maxrn/.config/kanata/macbook.kbd" ];
  };
}
