{ pkgs, ... }:
{

  home.packages = with pkgs; [
    coreutils-full
    gawk
    gnupatch
    gnused
  ];
}
