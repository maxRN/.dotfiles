{ pkgs, ... }:
{
  home.shellAliases = {
    tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
  };

  home.packages = with pkgs; [
    coreutils-full
  ];
}
