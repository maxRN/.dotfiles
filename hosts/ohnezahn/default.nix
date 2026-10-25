{
  pkgs,
  config,
  ...
}:
let
  hostname = "ohnezahn";
  username = config.system.primaryUser;
in
{
  imports = [
    ../../modules/fish-fix.nix
    ./homebrew.nix
    ../../modules/darwin-settings.nix
    ../../modules/nix-gc-optimise.nix
    ../../modules/common-options.nix
    ../../modules/server.nix

    ../shredder/kanata.nix
    ../shredder/aerospace.nix
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

  environment.shells = [ pkgs.fish ];

  server.sshAuthorizedKeys = [
    # GitHub key 128219878 (SHA256:Kh5Wwk40…); not ohnezahn's own id_ed25519.
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmA3oF7BrsfW4eCyrSngTCfzfq8Gx8jfzMwQny+Asip"
  ];

  security.pam.services.sudo_local = {
    # I'm using this as kind of a server now so I want to prompted by password.
    touchIdAuth = false;
  };
}
