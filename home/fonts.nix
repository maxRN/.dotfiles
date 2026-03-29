{ pkgs, ... }:
{
  home.packages = [
    pkgs.cascadia-code
  ];

  fonts.fontconfig.enable = true;
}
