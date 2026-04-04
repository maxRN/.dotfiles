{
  pkgs,
  pkgs-unstable,
  ...
}:
{
  imports = [
    ../../home/default.nix
    ../../home/darwin.nix
    ./ssh.nix
    ./hledger.nix
  ];

  home.packages =
    let
      unstable = with pkgs-unstable; [
      ];

      stable = with pkgs; [
        nixos-rebuild-ng
      ];
    in
    stable ++ unstable;
}
