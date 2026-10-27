# Local packages, used by the flake's `packages` output and by home-manager.
{ pkgs }:
{
  pi = pkgs.callPackage ./pi { };
  paper-mono = pkgs.callPackage ./paper-mono { };
  paper-mono-slashed-zero = pkgs.callPackage ./paper-mono { slashedZero = true; };
}
// pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
  secretive = pkgs.callPackage ./secretive { };
}
