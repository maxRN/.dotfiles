{ pkgs, ... }:
{
  home.packages = [
    pkgs.cascadia-code
    (pkgs.callPackage ../pkgs/paper-mono { })
    (pkgs.callPackage ../pkgs/paper-mono { slashedZero = true; })
  ];

  fonts.fontconfig.enable = true;
}
