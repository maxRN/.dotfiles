{ pkgs, ... }:
{
  nix.optimise.automatic = true;
  nix.gc.automatic = true;
  nix.package = pkgs.lixPackageSets.stable.lix;
}
