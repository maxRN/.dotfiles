{ pkgs, ... }:
let
  berkeley-mono = pkgs.callPackage ../packages/berkeley-mono.nix { };
in
{
  home.packages = [
    pkgs.cascadia-code
    berkeley-mono
  ];

  fonts.fontconfig.enable = true;
}
