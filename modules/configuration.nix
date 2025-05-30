{ pkgs, lib, ... }:
{
  services = {
  };

  nix = {
    enable = true;
    settings = {
      experimental-features = "nix-command flakes";
    };
    gc = {
      automatic = true;
    };
  };

  time.timeZone = "Europe/Berlin";
  fonts.packages = [ pkgs.pixel-code ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "ffmpeg-full"
    ];

}
