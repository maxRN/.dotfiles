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
        jdk24
        _1password-gui
        _1password-cli
      ];

      stable = with pkgs; [
        nixos-rebuild-ng
      ];
    in
    stable ++ unstable;
}
