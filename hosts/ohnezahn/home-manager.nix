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
      unstable = with pkgs-unstable; [ ];
      stable = with pkgs; [
      ];
    in
    stable ++ unstable;
}
