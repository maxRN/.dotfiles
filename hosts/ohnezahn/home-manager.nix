{
  pkgs,
  pkgs-unstable,
  ...
}:
{
  imports = [
    ../../home/default.nix
    ../../home/darwin.nix
  ];

  home.packages =
    let
      unstable = with pkgs-unstable; [
        opencode
        claude-code
      ];

      stable = with pkgs; [
        nixos-rebuild-ng
      ];
    in
    stable ++ unstable;
}
