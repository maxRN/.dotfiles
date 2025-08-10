{ config, ... }:
{
  nix = {
    enable = true;
    settings = {
      trusted-users = [ config.system.primaryUser ];
      experimental-features = "nix-command flakes";
    };
  };
}
