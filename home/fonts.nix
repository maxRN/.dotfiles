{ pkgs, ... }:
let
  localPkgs = import ../pkgs { inherit pkgs; };
in
{
  home.packages = [
    pkgs.cascadia-code
    localPkgs.paper-mono
    localPkgs.paper-mono-slashed-zero
  ];

  fonts.fontconfig.enable = true;
}
